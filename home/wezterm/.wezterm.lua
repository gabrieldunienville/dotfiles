-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.font = wezterm.font 'JetBrains Mono'

-- config.color_scheme = 'Batman'
-- config.color_scheme = 'AdventureTime'
-- config.color_scheme = 'Catppuccin Macchiato'
-- config.color_scheme = 'Clone Of Ubuntu (Gogh)'
-- config.color_scheme = 'Spacedust (Gogh)'
-- config.color_scheme = 'SpaceGray'
config.color_scheme = 'SpaceGray Eighties'
-- config.color_scheme = 'SpaceGray Eighties Dull'

-- local path = 'wallpapers/an_astronaut_in_space_with_a_glowing_planet.png'
local path = 'wallpapers/an_astronaut_in_space_with_a_satellite.png'

config.window_background_image = wezterm.home_dir .. '/' .. path 
-- config.window_background_image = './wallpapers/an_astronaut_in_space_with_a_glowing_planet.png'
-- config.window_background_image = 'wallpapers/an_astronaut_in_space_with_a_glowing_planet.png'

config.window_background_image_hsb = {
  -- Darken the background image by reducing it to 1/3rd
  brightness = 0.03,

  -- You can adjust the hue by scaling its value.
  -- a multiplier of 1.0 leaves the value unchanged.
  hue = 1.0,
  -- hue = 0.9,

  -- You can adjust the saturation also.
  saturation = 5.0,
}

config.automatically_reload_config = true

return config
