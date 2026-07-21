-- Window and layer rules (was: modules/windows.conf)
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ match = { namespace = "waybar" }, blur_popups = true })
hl.layer_rule({ match = { namespace = "waybar" }, ignore_alpha = 0.4 })

hl.window_rule({ match = { class = "^com.mitchellh.ghostty$" }, opacity = "0.90" })
hl.window_rule({ match = { class = "(fcitx)" }, pseudo = true })

hl.window_rule({ match = { class = "^(Brave-browser-beta)$" }, maximize = true })
hl.window_rule({ match = { class = "^(nemo)$" }, float = true })
hl.window_rule({ match = { class = "^(nvidia-settings)$" }, float = true })
hl.window_rule({ match = { class = "^(solaar)$" }, float = true })
hl.window_rule({ match = { class = "^(org.gnome.Calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(Postman)$" }, float = true })
hl.window_rule({ match = { class = "^(1Password)$" }, float = true })
hl.window_rule({ match = { class = "^(1password)$" }, float = true })
hl.window_rule({ match = { class = "^(io.missioncenter.MissionCenter)$" }, float = true })
hl.window_rule({ match = { class = "^(blueberry.py)$" }, float = true })
hl.window_rule({ match = { class = "^(Emulator)$" }, float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal-gtk)$" }, float = true })
hl.window_rule({ match = { class = "^(cursor)$" }, float = true })
hl.window_rule({ match = { class = "^(jetbrains-studio)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$" }, float = true })

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Window placement rules
hl.window_rule({ match = { class = "(solaar)" },             workspace = "1" })
hl.window_rule({ match = { class = "(nvidia-settings)" },    workspace = "1" })
hl.window_rule({ match = { class = "(Brave-browser-beta)" }, workspace = "2" })
hl.window_rule({ match = { class = "(ticktick)" },           workspace = "3" })
hl.window_rule({ match = { class = "(discord-ptb)" },        workspace = "4" })
hl.window_rule({ match = { class = "(discord)" },            workspace = "4" })
hl.window_rule({ match = { class = "(Slack)" },              workspace = "4" })
hl.window_rule({ match = { class = "(slack)" },              workspace = "4" })
hl.window_rule({ match = { class = "(Ferdium)" },            workspace = "5" })
hl.window_rule({ match = { class = "(ferdium)" },            workspace = "5" })
hl.window_rule({ match = { class = "(brave-.*-Default)" },   workspace = "5" })
hl.window_rule({ match = { class = "(obsidian)" },           workspace = "6" })
