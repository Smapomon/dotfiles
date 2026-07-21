-- Autostart (was: modules/autostart.conf)
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- exec-once equivalents: run once at compositor startup.
-- `started` guards against the event ever firing twice within one config
-- lifetime; a `hyprctl reload` builds a fresh Lua state whose subscription
-- never sees the (long past) startup event, so these do not re-run.
local started = false
hl.on("hyprland.start", function()
    if started then
        return
    end
    started = true

    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("waybar & hyprpaper")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=secrets,ssh &")
    hl.exec_cmd("nvidia-settings & solaar")
    hl.exec_cmd("ticktick")
    hl.exec_cmd("discord-ptb & ferdium & slack")
    hl.exec_cmd("wl-paste --watch cliphist store")
end)

-- exec equivalents: top-level code re-runs on every config reload,
-- matching hyprlang `exec` semantics. All idempotent.
hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"')
hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
hl.exec_cmd("setxkbmap fi -option caps:escape")
