-- Minimize/restore a window via the special:magic workspace.
-- Replaces scripts/minimize_or_restore_window.sh.
--
-- Only handles one hidden window at a time, and restore does not
-- necessarily respect the previous layout (same semantics as the
-- old script).

local SPECIAL = "special:magic"
local SPECIAL_SHORT = SPECIAL:gsub("^special:", "")

local M = {}

local function hidden_window()
    for _, w in ipairs(hl.get_windows()) do
        local ok, name = pcall(function() return w.workspace.name end)
        if ok and name == SPECIAL then
            return w
        end
    end
    return nil
end

function M.toggle()
    local hidden = hidden_window()
    if hidden then
        -- Restore the hidden window to the current workspace and focus it
        local ws = hl.get_active_workspace().id
        hl.dispatch(hl.dsp.window.move({ workspace = ws, silent = true, window = hidden }))
        hl.dispatch(hl.dsp.focus({ window = hidden }))
    else
        -- Hide the active window to the special workspace (silently,
        -- no workspace toggle)
        hl.dispatch(hl.dsp.window.move({ workspace = SPECIAL, silent = true }))
        -- If that was the last window on the workspace, focus follows it
        -- and pulls the special overlay up over the current workspace —
        -- dismiss it.
        local sp = hl.get_active_special_workspace()
        if sp and sp.name == SPECIAL then
            hl.dispatch(hl.dsp.workspace.toggle_special(SPECIAL_SHORT))
        end
    end
end

return M
