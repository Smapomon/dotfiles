-- Input, cursor and per-device settings (was: modules/input.conf)

hl.config({
    cursor = {
        hide_on_key_press    = true,
        no_hardware_cursors  = true,
    },

    input = {
        kb_layout  = "fi",
        kb_variant = "",
        kb_model   = "",
        kb_options = "caps:escape",
        kb_rules   = "",

        follow_mouse = 2,

        sensitivity = 0,

        emulate_discrete_scroll = 0,
    },
})

hl.device({
    name        = "logitech-usb-receiver-mouse", -- home MX3
    sensitivity = -0.8,
})

hl.device({
    name        = "logitech-mx-master-3-1", -- office MX3
    sensitivity = -0.8,
})

hl.device({
    name        = "logitech-pro-2-mouse-1",
    sensitivity = -0.75,
})
