-- Environment variables (was: modules/env_vars.conf)
-- Note: only take effect for processes spawned after startup.

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct") -- for Qt apps
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("HYPRSHOT_DIR", "Pictures/Screenshots")
hl.env("GTK_IM_MODULE", "simple")
hl.env("__GL_YIELD", "USLEEP")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE", "kvantum-dark")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
