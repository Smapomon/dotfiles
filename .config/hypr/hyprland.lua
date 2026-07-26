-- https://wiki.hypr.land/Configuring/
--
-- Lua config entry point ($XDG_CONFIG_HOME/hypr/hyprland.lua).
--
-- require() here is Hyprland's customized version: paths resolve relative
-- to this file, and each required file runs in its own scope, so an error
-- in one module does not stop the others from loading.

-- Modules that only provide values to keybinds. They emit no config
-- keywords at load, so their position here is free; the requires below
-- apply config in order and must stay in it.
local programs = require("lua/programs")
local zen      = require("lua/zen")
local minimize = require("lua/minimize")

-- any configuration here should be system agnostic
require("lua/monitors")
require("lua/env_vars")
require("lua/look_and_feel")
require("lua/input")
require("lua/keybinds")(programs, zen, minimize)
require("lua/windows")
require("lua/graphical_session")
require("lua/autostart")

-- add any system specific overrides here (optional file)
pcall(require, "lua/overrides")
