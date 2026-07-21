-- Zen mode + per-workspace monocle toggle.
-- Replaces scripts/toggle_gaps.sh and scripts/toggle_layout.sh.
--
-- The old bash version expressed zen gaps through conditional workspace
-- selectors (`w[tv1]` / `f[1]`), which Hyprland 0.56.0 re-evaluates
-- per-window mid-recalculation with stale visibility (upstream PR #15382),
-- resetting gaps on one client while cycling in monocle. This module keeps
-- zen/monocle state explicitly per workspace and only ever emits
-- unconditional `r[id-id]` rules, so nothing depends on visibility counts
-- during layout recalculation.
--
-- State is per-session: a config reload exits zen mode everywhere.

-- css_gap fields accept an integer or a table with named
-- top/right/bottom/left fields; anything else (strings, array tables)
-- raises an uncatchable error from the C side, bypassing pcall.
local DEFAULT_GAPS_OUT = 20
local ZEN_GAPS_OUT     = { top = 100, right = 500, bottom = 100, left = 500 }
local GAPS_IN          = 5

local state = {} -- [ws id] = { zen = bool, monocle = bool }
local rules = {} -- [ws id] = last workspace_rule handle (disabled before re-issuing)

local function st(id)
    if not state[id] then
        state[id] = { zen = false, monocle = false }
    end
    return state[id]
end

local function notify(text)
    local ok = pcall(hl.notification.create, { text = text, duration = 2000 })
    if not ok then
        pcall(hl.exec_cmd, "notify-send -u normal 'ZEN MODE' " .. string.format("%q", text))
    end
end

local function active_ws_id()
    local ok, id = pcall(function() return hl.get_active_workspace().id end)
    if ok and type(id) == "number" then
        return id
    end
    return nil
end

-- Count non-floating windows on a workspace; nil if the API surface differs
-- from expectations (callers must degrade gracefully).
local function tiled_count(id)
    local ok, wins = pcall(hl.get_workspace_windows, id)
    if not ok or type(wins) ~= "table" then
        ok, wins = pcall(function() return hl.get_workspace_windows(hl.get_workspace(id)) end)
    end
    if not ok or type(wins) ~= "table" then
        return nil
    end
    local n = 0
    for _, w in ipairs(wins) do
        local okf, floating = pcall(function() return w.floating end)
        if not (okf and floating == true) then
            n = n + 1
        end
    end
    return n
end

-- Zen gaps should only be in effect while the workspace shows a single
-- window: monocle layout, or at most one tiled window in master.
-- (Same semantics the old w[tv1] selector provided, minus the bug.)
local function single_visible(id)
    if st(id).monocle then
        return true
    end
    local n = tiled_count(id)
    return n ~= nil and n <= 1
end

local function apply(id)
    local s = st(id)
    local zen_active = s.zen and single_visible(id)

    if rules[id] then
        pcall(function() rules[id]:set_enabled(false) end)
        rules[id] = nil
    end

    local rule = {
        workspace = "r[" .. id .. "-" .. id .. "]",
        layout    = s.monocle and "monocle" or "master",
        gaps_in   = GAPS_IN,
        gaps_out  = zen_active and ZEN_GAPS_OUT or DEFAULT_GAPS_OUT,
    }

    local ok, handle = pcall(hl.workspace_rule, rule)
    if ok then
        rules[id] = handle
    end
end

local function recompute_all()
    for id in pairs(state) do
        apply(id)
    end
end

-- Window count changes can flip single_visible() for zen workspaces.
-- Handlers ignore event payloads on purpose: recomputing every tracked
-- workspace is cheap and independent of payload shapes.
for _, ev in ipairs({ "window.open", "window.close", "window.move_to_workspace" }) do
    pcall(hl.on, ev, function() recompute_all() end)
end

-- Workspace ids get reused; drop state when a workspace dies.
pcall(hl.on, "workspace.removed", function(ws)
    local ok, id = pcall(function() return ws.id end)
    if not (ok and type(id) == "number") then
        return
    end
    if rules[id] then
        pcall(function() rules[id]:set_enabled(false) end)
    end
    state[id] = nil
    rules[id] = nil
end)

local M = {}

function M.toggle_zen()
    local id = active_ws_id()
    if not id then
        return
    end
    local s = st(id)
    s.zen = not s.zen
    apply(id)
    notify(s.zen and "Zen mode is on..." or "Zen mode is off...")
end

function M.toggle_monocle()
    local id = active_ws_id()
    if not id then
        return
    end
    local s = st(id)
    s.monocle = not s.monocle
    apply(id)
end

return M
