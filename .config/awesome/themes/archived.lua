-- THIS IS ARCHIVED MONITOR CONFIG LOGIC
--
-- Do not use or modify.


-- LEFT MONITOR
if (s.index == monitor_left)
then
  awful.tag.add("MUSIC", {
    icon     = "/home/smapo/.config/awesome/icons/music.png",
    layout   = awful.layout.layouts[1],
    screen   = s,
    selected = true
  })

  -- CENTER MONITOR
elseif (s.index == monitor_center)
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

  awful.tag.add("WORK", {
    icon   = "/home/smapo/.config/awesome/icons/terminal.png",
    layout = awful.layout.layouts[1],
    screen = s,
  })

  awful.tag.add("NOTES", {
    layout = awful.layout.layouts[1],
    screen = s,
  })

  -- RIGHT MONITOR
elseif (s.index == monitor_right)
then
  awful.tag.add("WEB & CHAT", {
    icon     = "/home/smapo/.config/awesome/icons/web-icon.png",
    layout   = awful.layout.layouts[1],
    screen   = s,
    selected = true
  })
else
  awful.tag(custom_tags, s, awful.layout.layouts[1])
end
