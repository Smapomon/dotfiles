-- Look and feel (was: modules/look_and_feel.conf)
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 20,

        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "master",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a, -- was rgba(1a1a1aee)
        },

        blur = {
            enabled  = true,
            size     = 4,
            passes   = 2,

            vibrancy = 0.1691,
        },
    },

    animations = {
        enabled = false,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
    dwindle = {
        preserve_split = true, -- You probably want this
        force_split    = 2,    -- Always split on the right
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
    master = {
        new_status    = "slave",
        new_on_top    = true,
        new_on_active = "before",
    },

    misc = {
        force_default_wallpaper  = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        focus_on_activate        = true,
    },

    group = {
        groupbar = {
            font_size     = 18,
            rounding      = 8,
            height        = 32,
            render_titles = true,
            stacked       = false,

            gradients = false,

            -- colors (0xAARRGGBB)
            text_color_inactive = 0xff787c80,
            text_color          = 0xffe6e6e6, -- label color for both states
            col = {
                active   = 0x66ffff00, -- active tab background
                inactive = 0xff1f2430, -- inactive tabs background
            },
        },
    },
})
