-- Keybindings (was: modules/keybinds.conf)
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

return function(programs, zen, minimize)

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(programs.menu))

hl.bind(mainMod .. " + CTRL + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"))

hl.bind(mainMod .. " + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + M", function() zen.toggle_monocle() end)
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + CTRL + SHIFT + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("CTRL + ALT + space", hl.dsp.layout("mfact exact 0.7"))
hl.bind(mainMod .. " + BACKSPACE", hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }))

hl.bind(mainMod .. " + O", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.window.move({ workspace = "r-1" }))

local mfactHalf = hl.dsp.layout("mfact exact 0.5")
local centerWindow = hl.dsp.window.center()
hl.bind(mainMod .. " + C", function()
    hl.dispatch(centerWindow)
    hl.dispatch(mfactHalf)
end)

hl.bind(mainMod .. " + U", hl.dsp.focus({ urgent_or_last = true }))

-- Minimize window (see lua/minimize.lua)
hl.bind(mainMod .. " + N", function() minimize.toggle() end)

-- Toggle zen gaps
hl.bind(mainMod .. " + SHIFT + P", function() zen.toggle_zen() end)

-- Cycle focus with mainMod + j/k, raising the focused window
local cycleNext = hl.dsp.layout("cyclenext")
local cyclePrev = hl.dsp.layout("cycleprev")
local bringToTop = hl.dsp.window.bring_to_top()
hl.bind(mainMod .. " + J", function()
    hl.dispatch(cycleNext)
    hl.dispatch(bringToTop)
end)
hl.bind(mainMod .. " + K", function()
    hl.dispatch(cyclePrev)
    hl.dispatch(bringToTop)
end)

hl.bind(mainMod .. " + TAB", hl.dsp.group.next())
hl.bind(mainMod .. " + H", hl.dsp.group.prev())

hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("swapnext"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.layout("swapprev"))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + ctrl + j/k on current monitor
hl.bind(mainMod .. " + CTRL + J", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.focus({ workspace = "m-1" }))

-- Scroll or create workspaces on current monitor
hl.bind(mainMod .. " + ALT + J", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + ALT + K", hl.dsp.focus({ workspace = "r-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0, y = 50, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ x = 50, y = 0, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ x = 0, y = 50, relative = true }),  { repeating = true })

hl.bind(mainMod .. " + left",  hl.dsp.window.move({ x = -100, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + right", hl.dsp.window.move({ x = 100, y = 0, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + down",  hl.dsp.window.move({ x = 0, y = 100, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + up",    hl.dsp.window.move({ x = 0, y = -100, relative = true }), { repeating = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Clipboard (was scripts/rofi_cliphist.sh as a rofi custom modi;
-- same flow as a plain dmenu pipeline, no selection → no-op)
hl.bind(mainMod .. " + V",
    hl.dsp.exec_cmd([[sel="$(cliphist list | rofi -dmenu -p clipboard -theme solarized -font "hack 14")" && [ -n "$sel" ] && printf %s "$sel" | cliphist decode | wl-copy]]))

-- Screenshots (requires: grimblast-git, hyprpicker, libnotify)
hl.bind(mainMod .. " + SHIFT + S",
    hl.dsp.exec_cmd("XDG_SCREENSHOTS_DIR=~/Pictures/Screenshots grimblast --notify --freeze copysave area"))
hl.bind("PRINT",
    hl.dsp.exec_cmd("XDG_SCREENSHOTS_DIR=~/Pictures/Screenshots grimblast --notify --freeze copysave output"))

-- Reload waybar
-- `hyprctl dispatch` parses its args as Lua in Lua-config mode, so
-- `hyprctl dispatch exec waybar` no longer works — spawn waybar directly.
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("pkill waybar && sleep 1 && waybar"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("waybar")) -- start waybar

-- Clear notifs
hl.bind("CTRL + space", hl.dsp.exec_cmd("makoctl dismiss -a"))

end
