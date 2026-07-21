-- https://wiki.hypr.land/Configuring/
--
-- Lua config entry point ($XDG_CONFIG_HOME/hypr/hyprland.lua).
--
-- require() here is Hyprland's customized version: paths resolve relative
-- to this file, and each required file runs in its own scope, so an error
-- in one module does not stop the others from loading.

-- any configuration here should be system agnostic
require("lua/monitors")
local programs = require("lua/programs")
require("lua/env_vars")
require("lua/look_and_feel")
require("lua/input")
local zen = require("lua/zen")
local minimize = require("lua/minimize")
require("lua/keybinds")(programs, zen, minimize)
require("lua/windows")
require("lua/autostart")

-- add any system specific overrides here (optional file)
pcall(require, "lua/overrides")
