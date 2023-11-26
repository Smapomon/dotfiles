--[[

     Dremora Awesome WM theme 2.0
     github.com/lcpz

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi

local os = os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/dremora"
theme.font                                      = "FuraCode Nerd Font 10.5"
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
theme.titlebar_bg_focus                         = "#3F3F3F"
theme.titlebar_bg_normal                        = "#3F3F3F"
theme.titlebar_bg_focus                         = theme.bg_normal
theme.titlebar_bg_normal                        = theme.bg_normal
theme.titlebar_fg_focus                         = theme.fg_focus
theme.notification_opacity                      = 80
theme.notification_shape                        = gears.shape.rounded_rect
theme.menu_height                               = dpi(16)
theme.menu_width                                = dpi(130)
theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.awesome_icon                              = theme.dir .."/icons/awesome.png"
theme.taglist_squares_sel                       = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"
theme.layout_tile                               = theme.dir .. "/icons/tile.png"
theme.layout_tileleft                           = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom                         = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop                            = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv                              = theme.dir .. "/icons/fairv.png"
theme.layout_fairh                              = theme.dir .. "/icons/fairh.png"
theme.layout_spiral                             = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle                            = theme.dir .. "/icons/dwindle.png"
theme.layout_max                                = theme.dir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.dir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.dir .. "/icons/floating.png"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = dpi(10)
theme.titlebar_close_button_focus               = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme.dir .. "/icons/titlebar/close_normal.png"
theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_maximized_button_focus_active    = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.dir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/titlebar/maximized_normal_inactive.png"


-- MONITOR ORDER (number is index)
local monitor_left   = 2
local monitor_center = 1
local monitor_right  = 3

theme.wallpaper = function(s)
  -- get wp based on screen index
  local wallpapers = {
    --"/home/smapo/wallpapers/Trump-Wrong-1024.png",
    "/home/smapo/wallpapers/Duckful (2).png",
    "/home/smapo/wallpapers/reckful-everland.jpg",
    "/home/smapo/wallpapers/byron-last-wave-dark.jpg",
  }

  return wallpapers[s.index]
end


awful.util.tagnames   = { "ƀ", "Ƅ", "Ɗ", "ƈ", "ƙ" }

local markup     = lain.util.markup
local separators = lain.util.separators
local white      = theme.fg_focus
local gray       = "#858585"

-- Textclock
local mytextclock = wibox.widget.textclock(
    markup(gray, " | ") .. markup(white, " %d.") .. markup(white, "%m.") .. markup(white, "%Y - ") ..  markup(white, "%H:%M:%S ")
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

-- Mail IMAP check
--[[ to be set before use
theme.mail = lain.widget.imap({
    timeout  = 180,
    server   = "server",
    mail     = "mail",
    password = "keyring get mail",
    notification_preset = { fg = white }
    settings = function()
        mail  = ""
        count = ""

        if mailcount > 0 then
            mail = "Mail "
            count = mailcount .. " "
        end

        widget:set_markup(markup.font(theme.font, markup(gray, mail) .. markup(white, count)))
    end
})
--]]

-- MPD
theme.mpd = lain.widget.mpd({
    settings = function()
        mpd_notification_preset.fg = white
        artist = mpd_now.artist .. " "
        title  = mpd_now.title  .. " "

        if mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        elseif mpd_now.state == "stop" then
            artist = ""
            title  = ""
        end

        widget:set_markup(markup.font(theme.font, markup(gray, artist) .. markup(white, title)))
    end
})

-- /home fs
--[[ commented because it needs Gio/Glib >= 2.54
theme.fs = lain.widget.fs({
    notification_preset = { fg = white, bg = theme.bg_normal, font = "Terminus 10.5" },
    settings  = function()
        fs_header = ""
        fs_p      = ""

        if fs_now["/home"].percentage >= 90 then
            fs_header = " Hdd "
            fs_p      = fs_now["/home"].percentage
        end

        widget:set_markup(markup.font(theme.font, markup(gray, fs_header) .. markup(white, fs_p)))
    end
})
--]]

-- Battery
local bat = lain.widget.bat({
    settings = function()
        bat_header = " Bat "
        bat_p      = bat_now.perc .. " "
        widget:set_markup(markup.font(theme.font, markup(gray, bat_header) .. markup(white, bat_p)))
    end
})

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

  widget:set_markup(markup.font(theme.font, markup(gray, current_app) .. markup(gray, ' >>> ') .. markup(gray, client_state) .. markup(gray, ' | ')))
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

-- Weather
--[[ to be set before use
theme.weather = lain.widget.weather({
    --APPID =
    city_id = 2643743, -- placeholder (London)
    notification_preset = { fg = white }
})
--]]

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
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
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
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            active_app,
            wibox.widget.systray(),
            first,
            --theme.mpd.widget,
            --theme.mail.widget,
            --theme.fs.widget,
            --theme.volume.bar,
            volume_widget,
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
