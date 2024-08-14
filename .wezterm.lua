local wezterm = require 'wezterm'
local config  = wezterm.config_builder()
local act     = wezterm.action

-- STYLE
config.font                         = wezterm.font 'Iosevka'
config.font_size                    = 13
config.window_background_opacity    = 0.85
config.hide_tab_bar_if_only_one_tab = true

config.window_frame = {
  font                 = wezterm.font { family = 'Roboto', weight = 'Bold' },
  font_size            = 12.0,
  active_titlebar_bg   = '#000000',
  inactive_titlebar_bg = '#000000',
}
config.colors = {
  tab_bar = {
    inactive_tab_edge = '#000000',
    active_tab = {
      bg_color = '#101010',
      fg_color = '#A0A0A0',
    },
    inactive_tab = {
      bg_color = '#000000',
      fg_color = '#505050',
    },
    new_tab = {
      bg_color = '#000000',
      fg_color = '#A0A0A0',
    },
    new_tab_hover = {
      bg_color = '#101010',
      fg_color = '#F0F0F0',
      italic = true,
    },
  },
}

-- KEY BINDS
config.keys = {
  { key = 'k', mods = 'CTRL|SHIFT',   action = act.ScrollByLine(-1) },
  { key = 'j', mods = 'CTRL|SHIFT',   action = act.ScrollByLine(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ShowTabNavigator },
}

return config
