--[[

     Awesome WM configuration template
     github.com/lcpz

--]]

-- SYSTEM VARIABLES
local monitor_index = 1

-- {{{ Required libraries

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local gears         = require("gears")
local awful         = require("awful")
require("awful.autofocus")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
local mytable       = awful.util.table or gears.table -- 4.{0,1} compatibility

-- }}}

--{{{ Naughty Defaults
naughty.config.defaults['icon_size'] = 100
naughty.config.defaults['screen'] = monitor_index
--}}}

-- {{{ Error handling

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify {
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors
  }
end

-- Handle runtime errors after startup
do
  local in_error = false

  awesome.connect_signal("debug::error", function (err)
    if in_error then return end

    in_error = true

    naughty.notify {
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err)
    }

    in_error = false
  end)
end

-- }}}

-- {{{ Autostart windowless processes

-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
  for _, cmd in ipairs(cmd_arr) do
    awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
  end
end

run_once({ "urxvtd", "unclutter -root" }) -- comma-separated entries

awful.screen.set_auto_dpi_enabled(true)

-- This function implements the XDG autostart specification
--[[
awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";' ..
    -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
    'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
)
--]]

-- }}}

-- {{{ Variable definitions

local modkey       = "Mod4"
local altkey       = "Mod1"
local terminal     = "wezterm"
local vi_focus     = false -- vi-like client focus https://github.com/lcpz/awesome-copycats/issues/275
local cycle_prev   = true  -- cycle with only the previously focused client or all https://github.com/lcpz/awesome-copycats/issues/274
local editor       = os.getenv("EDITOR") or "nvim"
local browser      = "brave-browser-beta"

awful.util.terminal = terminal
awful.util.tagnames = { "1", "2", "3", "4", "5" }
awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.floating,
  awful.layout.suit.spiral,
  awful.layout.suit.max,
}

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = 2
lain.layout.cascade.tile.offset_y      = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

awful.util.taglist_buttons = mytable.join(
  awful.button({ }, 1, function(t) t:view_only() end),
  awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

awful.util.tasklist_buttons = mytable.join(
  awful.button({ }, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else
      c:emit_signal("request::activate", "tasklist", { raise = true })
    end
  end),
  awful.button({ }, 3, function()
    awful.menu.client_list({ theme = { width = 250 } })
  end),
  awful.button({ }, 4, function() awful.client.focus.byidx(1) end),
  awful.button({ }, 5, function() awful.client.focus.byidx(-1) end)
)

beautiful.init(string.format("%s/.config/awesome/themes/theme.lua", os.getenv("HOME")))

-- }}}

-- {{{ Menu

-- Create a launcher widget and a main menu
local myawesomemenu = {
  { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
  { "Manual", string.format("%s -e man awesome", terminal) },
  { "Edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
  { "Lock", function() awful.spawn.with_shell(os.getenv("HOME") .."/shell_scripts/set_lockscreen.sh") end },
  { "Restart", awesome.restart },
  { "Quit", function() awesome.quit() end },
}

awful.util.mymainmenu = freedesktop.menu.build {
  before = {
    { "Awesome", myawesomemenu, beautiful.awesome_icon },
    -- other triads can be put here
  },
  after = {
    { "Open terminal", terminal },
    -- other triads can be put here
  }
}

-- }}}

-- {{{ Screen

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
  local only_one = #s.tiled_clients == 1
  for _, c in pairs(s.clients) do
    c.border_width = 0
    --if only_one and not c.floating or c.maximized or c.fullscreen then
    --else
    --c.border_width = beautiful.border_width
    --end
  end
end)

awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)

-- }}}

-- {{{ Mouse bindings

root.buttons(mytable.join(
  awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
))

-- }}}

-- {{{ Key bindings
-- Cycle clients through tags
local gmath = require("gears.math")

local function cycle_client_tag(dir)
  local c = client.focus
  if not c then return end

  dir = dir or 1

  local t = c.screen.selected_tag
  local tags = c.screen.tags
  local idx = t.index
  local newtag = tags[gmath.cycle(#tags, idx + dir)]
  c:move_to_tag(newtag)

  if dir == 1 then
    awful.tag.viewnext()
  else
    awful.tag.viewprev()
  end
end

globalkeys = mytable.join(
  awful.key({ "Control" }, "space",
    function()
      naughty.destroy_all_notifications()
    end,
    {description = "destroy all notifications", group = "hotkeys"}),

  awful.key({ modkey }, "l",
    function ()
      awful.screen.focus(monitor_index)
      naughty.notify {
        title    = "Lock Script",
        text     = "Locking screen...",
        position = "top_middle"
      }

      awful.util.spawn(os.getenv("HOME") .."/shell_scripts/set_lockscreen.sh")
    end,
    {description = "lock screen", group = "hotkeys"}),

  awful.key({ modkey }, "s", hotkeys_popup.show_help, {description="show help", group="awesome"}),

  -- Tag browsing
  awful.key({ modkey }, "Escape", awful.tag.history.restore,
    {description = "go back", group = "tag"}),
  awful.key({ modkey }, "Tab", awful.tag.viewnext,
    {description = "view next", group = "tag"}),
  awful.key({ modkey, "Control" }, "k",   awful.tag.viewprev,
    {description = "view previous", group = "tag"}),
  awful.key({ modkey, "Control" }, "j",  awful.tag.viewnext,
    {description = "view next", group = "tag"}),


  -- Default client focus
  awful.key({ modkey, }, "j", function () awful.client.focus.byidx( 1) end,
    {description = "focus next by index", group = "client"}),

  awful.key({ altkey, }, "Tab", function () awful.client.focus.byidx( 1) end,
    {description = "focus next by index", group = "client"}),

  awful.key({ modkey, }, "k", function () awful.client.focus.byidx(-1) end,
    {description = "focus previous by index", group = "client"}),

  awful.key({ altkey, }, "Right", function () awful.client.focus.byidx(1) end,
    {description = "focus next by index", group = "client"}),

  awful.key({ altkey, }, "Left", function () awful.client.focus.byidx(-1) end,
    {description = "focus previous by index", group = "client"}),



  -- Menu
  awful.key({ modkey,           }, "w", function () awful.util.mymainmenu:show() end,
    {description = "show main menu", group = "awesome"}),

  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
    {description = "swap with next client by index", group = "client"}),
  awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
    {description = "swap with previous client by index", group = "client"}),
  awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
    {description = "jump to urgent client", group = "client"}),

  -- Show/hide wibox
  awful.key({ modkey }, "b",
    function ()
      for s in screen do
        s.mywibox.visible = not s.mywibox.visible
        if s.mybottomwibox then
          s.mybottomwibox.visible = not s.mybottomwibox.visible
        end
      end
    end,
    {description = "toggle wibox", group = "awesome"}),

  -- Dynamic tagging
  awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag() end,
    {description = "add new tag", group = "tag"}),

  awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end,
    {description = "rename tag", group = "tag"}),

  awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end,
    {description = "move tag to the left", group = "tag"}),

  awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end,
    {description = "move tag to the right", group = "tag"}),

  awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end,
    {description = "delete tag", group = "tag"}),

  -- Standard program
  awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
    {description = "open a terminal", group = "launcher"}),
  awful.key({ modkey, "Control" }, "r", awesome.restart,
    {description = "reload awesome", group = "awesome"}),
  awful.key({ modkey, "Shift"   }, "q", awesome.quit,
    {description = "quit awesome", group = "awesome"}),

  awful.key({ modkey, altkey    }, "l",     function () awful.tag.incmwfact( 0.05)          end,
    {description = "increase master width factor", group = "layout"}),
  awful.key({ modkey, altkey    }, "h",     function () awful.tag.incmwfact(-0.05)          end,
    {description = "decrease master width factor", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
    {description = "increase the number of master clients", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
    {description = "decrease the number of master clients", group = "layout"}),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
    {description = "increase the number of columns", group = "layout"}),
  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
    {description = "decrease the number of columns", group = "layout"}),

  -- Add resize commands with arrows
  awful.key({ modkey, "Control" }, "Right",     function () awful.tag.incmwfact( 0.05) end,
    {description = "increase master width factor", group = "layout"}),
  awful.key({ modkey, "Control" }, "Left",     function () awful.tag.incmwfact(-0.05) end,
    {description = "decrease master width factor", group = "layout"}),
  awful.key({ modkey, "Control" }, "Up",     function () awful.client.incwfact(-0.05) end,
    {description = "increase the number of master clients", group = "layout"}),
  awful.key({ modkey, "Control" }, "Down",     function () awful.client.incwfact(0.05) end,
    {description = "decrease the number of master clients", group = "layout"}),
  awful.key({ altkey, "Control" }, "space",     function ()
    awful.screen.focused().selected_tag.master_width_factor = 0.65
  end, {description = "set master col size", group = "layout"}),



  awful.key({ modkey, "Control" }, "n", function ()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
      c:emit_signal("request::activate", "key.unminimize", {raise = true})
    end
  end, {description = "restore minimized", group = "client"}),

  -- Dropdown application
  awful.key({ modkey, }, "z", function () awful.screen.focused().quake:toggle() end,
    {description = "dropdown application", group = "launcher"}),

  -- Widgets popups
  awful.key({ modkey, }, "e", function () if beautiful.fs then beautiful.fs.show(7) end end,
    {description = "show filesystem", group = "widgets"}),

  -- Screen brightness
  awful.key({ }, "XF86MonBrightnessUp", function () os.execute("xbacklight -inc 10") end,
    {description = "+10%", group = "hotkeys"}),
  awful.key({ }, "XF86MonBrightnessDown", function () os.execute("xbacklight -dec 10") end,
    {description = "-10%", group = "hotkeys"}),

  -- ALSA volume control
  --awful.key({ altkey }, "Up",
  awful.key({ }, "XF86AudioRaiseVolume",
    function ()
      local cmd = "pactl set-sink-volume 0 +1%"
      os.execute(cmd)
      os.execute("sleep 0.05")
      update_volume(volume_widget)
    end,
    {description = "volume up", group = "hotkeys"}),
  --awful.key({ altkey }, "Down",
  awful.key({ }, "XF86AudioLowerVolume",
    function ()
      local cmd = "pactl set-sink-volume 0 -1%"
      os.execute(cmd)
      os.execute("sleep 0.05")
      update_volume(volume_widget)
    end,
    {description = "volume down", group = "hotkeys"}),
  --awful.key({ altkey }, "m",
  awful.key({ }, "XF86AudioMute",
    function ()
      os.execute("pactl set-sink-mute 0 toggle")
      os.execute("sleep 0.1")
      update_volume(volume_widget)
    end,
    {description = "toggle mute", group = "hotkeys"}),

  awful.key({ }, "XF86AudioPlay",
    function ()
      awful.util.spawn_with_shell("playerctl play-pause")
    end),
  awful.key({ }, "XF86AudioPause",
    function ()
      awful.util.spawn_with_shell("playerctl play-pause")
    end),
  awful.key({ }, "XF86AudioNext",
    function ()
      awful.util.spawn_with_shell("playerctl next")
    end),
  awful.key({ }, "XF86AudioPrev",
    function ()
      awful.util.spawn_with_shell("playerctl previous")
    end),

  -- Open diodon for clipboard histroy
  awful.key({ modkey }, "v", function () awful.spawn.with_shell("/usr/bin/diodon") end,
    {description = "copy gtk to terminal", group = "hotkeys"}),

  -- User programs
  awful.key({ modkey }, "q", function () awful.spawn(browser) end,
    {description = "run browser", group = "launcher"}),

  -- rofi
  -- check https://github.com/DaveDavenport/rofi for more details
  awful.key({ modkey }, "p", function ()
    awful.screen.focus(monitor_index)
    os.execute(string.format('rofi -combi-modi window,drun,ssh -theme solarized -font "hack 14" -show combi -icon-theme "Papirus" -show-icons',
      'combi'))
  end,
    {description = "show rofi", group = "launcher"}),
  -- Prompt
  awful.key({ modkey }, "r", function () awful.spawn.with_shell(os.getenv("HOME") .. "/shell_scripts/set_monitor.sh") end,
    {description = "Reset Monitors", group = "hotkeys"}),
  --]]

  -- Screenshot snip
  awful.key({ modkey, "Shift" }, "s",
    function ()
      awful.util.spawn_with_shell("FILE=" .. os.getenv("HOME") .. "/Pictures/Screenshots/snapshot-$(date +%Y-%m-%dT%H-%M-%S).png && maim -s --hidecursor $FILE && sleep 0.5 && xclip -selection clipboard $FILE -t image/png && paplay /home/smapo/Music/sound_effects/camera-shutter.mp3")
    end,
    {description = "Grab a screenshot of selected area", group = "awesome"})
)

clientkeys = mytable.join(
  awful.key({ altkey, "Shift"   }, "m", lain.util.magnify_client, {description = "magnify client", group = "client"}),
  awful.key({ modkey }, "space", awful.client.floating.toggle, {description = "toggle floating", group = "client"}),

  awful.key({ modkey }, "f",
    function (c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    {description = "toggle fullscreen", group = "client"}),

  awful.key({ modkey, "Control"   }, "c",
    function (c)
      c:kill()
    end,
    {description = "close", group = "client"}),

  awful.key({ modkey, "Control" }, "Return",
    function (c)
      c:swap(awful.client.getmaster())
    end,
    {description = "move to master", group = "client"}),

  awful.key({ modkey }, "o", function() cycle_client_tag() end,
    {description = "Cycle client through tags", group = "client"}),

  awful.key({ modkey }, "c", awful.placement.centered,
    {description = "Center tag", group = "client"}),


  awful.key({ modkey }, "n",
    function (c)
      c.minimized = true
    end ,
    {description = "minimize", group = "client"}),

  awful.key({ modkey,           }, "m",
    function (c)
      c.maximized = not c.maximized
      c:raise()
    end ,
    {description = "(un)maximize", group = "client"}),

  awful.key({ modkey, "Control" }, "m",
    function (c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
    end ,
    {description = "(un)maximize vertically", group = "client"}),

  awful.key({ modkey, "Shift"   }, "m",
    function (c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
    end ,
    {description = "(un)maximize horizontally", group = "client"}),

  -- Move client position
  awful.key({ modkey }, "Left",
    function(c)
      c:relative_move(-45, 0, 0, 0)
    end,
    {description = "move client", group = "client"}),

  awful.key({ modkey }, "Right",
    function(c)
      c:relative_move(45, 0, 0, 0)
    end,
    {description = "move client", group = "client"}),

  awful.key({ modkey }, "Up",
    function(c)
      c:relative_move(0, -45, 0, 0)
    end,
    {description = "move client", group = "client"}),

  awful.key({ modkey }, "Down",
    function(c)
      c:relative_move(0, 45, 0, 0)
    end,
    {description = "move client", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = mytable.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
      function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      {description = "view tag #"..i, group = "tag"}),

    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function ()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      {description = "move focused client to tag #"..i, group = "tag"})
  )
end

clientbuttons = mytable.join(
  awful.button({ }, 1, function (c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
  end),
  awful.button({ modkey }, 1, function (c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey }, 3, function (c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.resize(c)
  end)
)

-- Set keys
root.keys(globalkeys)

-- }}}

-- {{{ Rules

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
    properties = { border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      callback = awful.client.setslave,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap+awful.placement.no_offscreen,
      size_hints_honor = false
    }
  },

  -- Floating clients.
  { rule_any = {
    instance = {
      "DTA",  -- Firefox addon DownThemAll.
      "copyq",  -- Includes session name in class.
      "pinentry",
    },
    class = {
      "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
      "MessageWin",  -- kalarm.
      "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
      "Wpa_gui", "veromix", "xtightvncviewer", "WhatSie", "discord",
      "Slack", "teams", "Ferdium", "gnome-calculator", "Solaar",
      "1Password", "Nvidia-settings", "Postman", "Image Lounge",
      "dolphin", "steam", "Nemo", "qBittorrent", "Emulator", "kcharselect",
      "Cursor"
    },

    -- Note that the name property shown in xprop might be set slightly after creation of the client
    -- and the name shown there might not match defined rules here.
    name = {
      "Event Tester",  -- xev.
    },
    role = {
      "AlarmWindow",  -- Thunderbird's calendar.
      "ConfigManager",  -- Thunderbird's about:config.
      "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
    }
  }, properties = { floating = true }},

  -- Add titlebars to normal clients and dialogs
  { rule_any = {type = { "normal", "dialog" }
  }, properties = { titlebars_enabled = false }
  },

  {
    rule       = { class     = "Terminator" },
    properties = { maximized = false }
  },

  -- Never sticky windows on launch
  {
    rule_any = {
      -- Add classes that should not sticky
      -- might be best to just make client open function
      -- for this eventually since stickyness is cancer
      class = { "Terminator" }
    },
    properties = { sticky = false }
  },

  -- Don't float on launch
  {
    rule_any = {

      class = {
        "Google-chrome",
        "Brave-browser",
        "Brave-browser-beta",
        "Spotify"
      }
    },
    properties = { floating = false }
  },


  -- Set apps to always map on the correct tag on the correct screen
  {
    rule_any = {
      class = {
        "discord",
        "Slack",
        "ticktick"
      }
    },
    properties = { screen = monitor_index, tag = "WEB & CHAT" }
  },
  {
    rule_any = {
      class = {
        "obsidian",
      }
    },
    properties = { screen = monitor_index, tag = "NOTES" }
  },
  {
    rule_any = {
      class = {
        "Spotify",
        "Ferdium"
      }
    },
    properties = { screen = monitor_index, tag = "MUSIC" }
  },
}

-- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup
    and not c.size_hints.user_position
    and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end

  -- Set rounded corners
  --c.shape = gears.shape.rounded_rect
end)

client.connect_signal("focus", function(c)
  --For debugging
  --naughty.notify {
  --title = "Window Props",
  --text = c.class
  --}

  update_active_app(active_app, c)

  c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

client.connect_signal("property::floating", function(c)
  --awful.titlebar.show(c)
  update_active_app(active_app, c)
end)

client.connect_signal("property::maximized", function(c)
  --awful.titlebar.show(c)
  update_active_app(active_app, c)
end)

-- Autostart Applications
update_volume(volume_widget)

awful.spawn.with_shell(os.getenv("HOME") .. "/shell_scripts/set_mouse.sh")
awful.spawn.with_shell(os.getenv("HOME") .."/shell_scripts/set_caps_escape.sh")
awful.spawn.with_shell("picom")
awful.spawn.with_shell("nvidia-settings")
awful.spawn.with_shell(os.getenv("HOME") .. "/shell_scripts/set_monitor.sh")
awful.spawn.with_shell("nitrogen --restore")
awful.spawn.with_shell(os.getenv("HOME") .. "/shell_scripts/autostart_apps.sh")

-- Set autolock for display
awful.spawn.with_shell("xautolock -time 45 -locker " .. os.getenv("HOME") .."/shell_scripts/set_lockscreen.sh")

-- }}}
