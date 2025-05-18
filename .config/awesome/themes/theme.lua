local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi

local os       = os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
local theme    = {}

-- MONITOR ORDER (number is index)
local monitor_center = 1
local monitor_left   = 2
local monitor_right  = 3

theme.wallpaper = function(s)
  -- get wp based on screen index
  local wallpapers = {
    --"/home/smapo/wallpapers/Trump-Wrong-1024.png",
    "/home/smapo/wallpapers/Duckful (2).png",
    "/home/smapo/wallpapers/Duckful (2).png",
    "/home/smapo/wallpapers/reckful-everland.jpg",
  }

  return wallpapers[s.index]
end

theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes"
theme.font                                      = "Iosevka 11"
theme.taglist_font                              = "FuraCode Nerd Font"
theme.menubar_bg_normal                         = "#282a36"
theme.menubar_bg_focus                          = "#404357"
theme.fg_normal                                 = "#ffffff"
theme.fg_focus                                  = "#A77AC4"
theme.fg_urgent                                 = "#b74822"
theme.bg_normal                                 = "#282a36"
theme.bg_focus                                  = "#c9c9ff"
theme.bg_urgent                                 = "#3F3F3F"
theme.taglist_fg_focus                          = "#282a36"
theme.tasklist_bg_focus                         = "#000000"
theme.tasklist_fg_focus                         = "#1fb1b1"
theme.border_width                              = 1
theme.border_normal                             = "#282a36"
theme.border_focus                              = "#F07178"
theme.border_marked                             = "#CC9393"
theme.notification_opacity                      = 80
theme.notification_shape                        = gears.shape.rounded_rect
theme.menu_height                               = dpi(16)
theme.menu_width                                = dpi(130)
theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.awesome_icon                              = theme.dir .."/icons/awesome.png"
theme.taglist_squares_sel                       = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"
theme.layout_tile                               = theme.dir .. "/icons/tile.png"
theme.layout_spiral                             = theme.dir .. "/icons/spiral.png"
theme.layout_max                                = theme.dir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.dir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.dir .. "/icons/floating.png"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = dpi(10)

awful.util.tagnames   = { "ƀ", "Ƅ", "Ɗ", "ƈ", "ƙ" }

local markup     = lain.util.markup
local separators = lain.util.separators
local white      = theme.fg_focus
local gray       = "#858585"

-- Textclock
local mytextclock = wibox.widget.textclock(
  markup(white, " %d.") .. markup(white, "%m.") .. markup(white, "%Y - ") ..  markup(white, "%H:%M:%S ")
)
mytextclock.font    = theme.font
mytextclock.refresh = 1

-- Calendar
theme.cal = lain.widget.cal({
  -- calendar props
  followtag           = true,
  week_start          = 2,
  week_number         = "left",
  three               = true,
  attach_to           = { mytextclock },
  notification_preset = {
    font            = "Terminus 11",
    fg              = white,
    bg              = theme.bg_normal
  }})


music_player = wibox.widget.textbox()

function update_music_player()
  local command = "playerctl metadata --format '{{emoji(status)}} {{artist}} - {{title}}  {{duration(position)}}/{{duration(mpris:length)}}'"
  awful.spawn.easy_async(command, function(stdout)
    music_player:set_text(stdout)
  end)
end

-- Last active app
active_app = wibox.widget.textbox()
function update_active_app(widget, current_client)
  local current_app  = current_client.class
  local client_state = 'tiled'

  if current_client.floating then
    client_state = 'floating'
  end

  if current_client.maximized then
    client_state = 'maximized'
  end

  widget:set_markup(markup.font(theme.font, markup(gray, current_app) .. markup(gray, ' > ') .. markup(gray, client_state)))
end

-- ALSA volume
--local volume_widget = wibox.container.background(volume.bar)
volume_widget = wibox.widget.textbox()
function update_volume(widget)
  -- Get volume for master with amixer
  local status = ''
  local volstring = "NO VOLUME DEVICE "
  awful.spawn.easy_async("amixer sget Master", function(stdout)
    status = stdout

    -- Parse volume
    local vol_num = tonumber(string.match(status, "(%d?%d?%d)%%"))

    -- Assign incase io stream is not read correctly for example
    if vol_num == nil then vol_num = 0 end

    local volume  = vol_num / 10 -- Might be a fukkuppy with number converion but vol is multiplied by 10
    status        = string.match(status, "%[(o[^%]]*)%]")

    -- Set volume to widget
    volstring = "Vol: "
    if type(status) == "string" and string.find(status, "on", 1, true)
    then
      local volint = math.floor(volume * 10)

      if volint > 0
      then
        volstring   = volstring .. volint .. "%"
      else
        volstring = volstring .. "muted"
      end
    else
      volstring = "NO VOLUME DEVICE"
    end

    widget:set_text(volstring)
  end)
end

theme.volume = lain.widget.alsa({
  --togglechannel = "IEC958,3",
  settings = function()
    header = " Vol "
    vlevel  = volume_now.level

    if volume_now.status == "off" then
      vlevel = vlevel .. "M "
    else
      vlevel = vlevel .. " "
    end

    widget:set_markup(markup.font(theme.font, markup(gray, header) .. markup(white, vlevel)))
  end
})

paru_updates_widget = wibox.widget.textbox()
LAST_UPDATE_TIME    = os.time()
LAST_PACKAGE_AMOUNT = nil
function update_package_count()
  local now            = os.time()
  local seconds_passed = now - LAST_UPDATE_TIME
  local minutes_passed = math.floor(seconds_passed / 60)
  local update_time    = ""

  if seconds_passed < 60 then
    update_time = string.format(" (%ds ago)", seconds_passed)
  else
    update_time = string.format(" (%dmin ago)", minutes_passed)
  end

  if (minutes_passed >= 10 or LAST_PACKAGE_AMOUNT == nil) then
    paru_updates_widget:set_markup(
      markup.font(theme.font,
        markup(gray, " ") ..
        markup(gray, "…") .. -- loading dots
        markup(gray, update_time)
      )
    )
    awful.spawn.easy_async_with_shell("paru -Qu | wc -l", function(stdout)
      update_time         = " (<1min ago)"
      LAST_UPDATE_TIME    = os.time()
      LAST_PACKAGE_AMOUNT = tonumber(stdout) or 0

      paru_updates_widget:set_markup(
        markup.font(theme.font,
          markup(gray, ' | ') ..
          markup(gray, " ") ..
          markup(gray, LAST_PACKAGE_AMOUNT) ..
          markup(gray, update_time)
        )
      )
    end)
  else
    paru_updates_widget:set_markup(
      markup.font(theme.font,
        markup(gray, " ") ..
        markup(gray, LAST_PACKAGE_AMOUNT) ..
        markup(gray, update_time)
      )
    )
  end
end

update_package_count()
update_music_player()

gears.timer {
  timeout = 10, -- seconds
  autostart = true,
  call_now = true,
  callback = update_package_count
}

gears.timer {
  timeout = 1, -- seconds
  autostart = true,
  call_now = true,
  callback = update_music_player
}

-- Separators
local first     = wibox.widget.textbox('<span font="Terminus 4">    </span>')
local arrl_pre  = separators.arrow_right("alpha", "#1A1A1A")
local arrl_post = separators.arrow_right("#1A1A1A", "alpha")

function theme.at_screen_connect(s)
  -- Quake application
  s.quake = lain.util.quake({ app = awful.util.terminal })

  -- If wallpaper is a function, call it with the screen
  local wallpaper = theme.wallpaper
  if type(wallpaper) == "function" then
    wallpaper = wallpaper(s)
  end
  gears.wallpaper.maximized(wallpaper, s, true)

  -- Tags
  local custom_tags    = { "ƀ", "Ƅ", "Ɗ", "ƈ", "ƙ" }

  -- LEFT MONITOR
  if(s.index == monitor_left)
  then
    awful.tag.add("MUSIC", {
      icon               = "/home/smapo/.config/awesome/icons/music.png",
      layout             = awful.layout.layouts[1],
      screen             = s,
      selected           = true
    })

    -- CENTER MONITOR
  elseif(s.index == monitor_center)
  then
    awful.tag.add("MAIN", {
      icon     = "/home/smapo/.config/awesome/icons/home-icon.png",
      layout   = awful.layout.layouts[1],
      screen   = s,
      selected = true
    })

    awful.tag.add("CODE", {
      icon   = "/home/smapo/.config/awesome/icons/terminal.png",
      layout = awful.layout.layouts[1],
      screen = s,
    })

    awful.tag.add("NOTES", {
      layout = awful.layout.layouts[1],
      screen = s,
    })

    -- RIGHT MONITOR
  elseif(s.index == monitor_right)
  then
    awful.tag.add("WEB & CHAT", {
      icon   = "/home/smapo/.config/awesome/icons/web-icon.png",
      layout = awful.layout.layouts[1],
      screen = s,
      selected = true
    })
  else
    awful.tag(custom_tags, s, awful.layout.layouts[1])
  end


  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(my_table.join(
    awful.button({}, 1, function () awful.layout.inc( 1) end),
    awful.button({}, 2, function () awful.layout.set( awful.layout.layouts[1] ) end),
    awful.button({}, 3, function () awful.layout.inc(-1) end),
    awful.button({}, 4, function () awful.layout.inc( 1) end),
    awful.button({}, 5, function () awful.layout.inc(-1) end)))
  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist {
    -- configs for tasks
    screen  = s,
    filter  = awful.widget.tasklist.filter.currenttags,
    buttons = awful.util.tasklist_buttons,

    style    = {
      shape_border_width = 1,
      shape_border_color = '#777777',
      shape              = gears.shape.rounded_bar,
    },

    layout   = {
      spacing = 25,
      spacing_widget = {
        {
          forced_width = 5,
          shape        = gears.shape.circle,
          widget       = wibox.widget.separator
        },
        valign = 'center',
        halign = 'center',
        widget = wibox.container.place,
      },
      layout  = wibox.layout.fixed.horizontal
    },
    -- Notice that there is *NO* wibox.wibox prefix, it is a template,
    -- not a widget instance.
    widget_template = {
      {
        {
          {
            {
              forced_height = 1,
              forced_width = 1,
              {
                id     = 'clienticon',
                widget = awful.widget.clienticon,
              },
              margins = 5,
              widget  = wibox.container.margin
            },
            margins = 2,
            widget  = wibox.container.margin,
          },
          {
            id     = 'text_role',
            widget = wibox.widget.textbox,
          },
          layout = wibox.layout.fixed.horizontal,
        },
        left   = 10,
        right  = 10,
        width  = 300,
        widget = wibox.container.constraint
      },
      id           = 'background_role',
      widget       = wibox.container.background,
    },
  }

  -- Create the wibox
  s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(18), bg = theme.bg_normal, fg = theme.fg_normal })

  local separator = wibox.widget.textbox(markup(gray, " | "))
  local updates_widget = nil
  local music_widget = nil
  local cond_separator = nil
  if(s.index == monitor_center) then
    updates_widget = paru_updates_widget
    music_widget = music_player
    cond_separator = separator
  end

  -- Add widgets to the wibox
  s.mywibox:setup {
    expand = "none",
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      first,
      s.mytaglist,
      arrl_pre,
      s.mylayoutbox,
      arrl_post,
      s.mypromptbox,
      first,
      music_widget,
      first,
    },
    s.mytasklist, -- Middle widget
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      active_app,
      separator,
      wibox.widget.systray(),
      cond_separator,
      volume_widget,
      separator,
      updates_widget,
      cond_separator,
      mytextclock,
    },
  }

  -- Force widgets to main monitor
  if(s.index == monitor_center)
  then
    local tray = wibox.widget.systray()
    tray:set_screen(s)
  end

end

return theme
