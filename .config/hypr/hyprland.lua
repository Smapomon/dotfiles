-- https://wiki.hypr.land/Configuring/
--
-- Lua config entry point. When this file exists Hyprland loads it INSTEAD of
-- hyprland.conf (decided once at startup). Rollback: rename this file away
-- and restart Hyprland — the old .conf tree under modules/ is untouched.

local CFG = os.getenv("HOME") .. "/.config/hypr/lua/"

-- any configuration here should be system agnostic
dofile(CFG .. "monitors.lua")
local programs = dofile(CFG .. "programs.lua")
dofile(CFG .. "env_vars.lua")
dofile(CFG .. "look_and_feel.lua")
dofile(CFG .. "input.lua")
local zen = dofile(CFG .. "zen.lua")
local minimize = dofile(CFG .. "minimize.lua")
dofile(CFG .. "keybinds.lua")(programs, zen, minimize)
dofile(CFG .. "windows.lua")
dofile(CFG .. "autostart.lua")

-- add any system specific overrides here (optional file)
pcall(dofile, CFG .. "overrides.lua")
