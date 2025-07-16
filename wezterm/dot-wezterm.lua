-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.font = wezterm.font("JetBrains Mono")
config.font_size = 16.0
config.line_height = 1.2

-- Reccommended by claude
config.max_fps = 120
config.animation_fps = 60
config.cursor_blink_rate = 500
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" } -- Enable ligatures
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
-- Scrollback for AI output
config.scrollback_lines = 10000
-- Enable Kitty graphics protocol for image support
config.enable_kitty_graphics = true
-- Critical for Neovim: proper terminfo
-- config.term = "wezterm"
config.term = "xterm-256color"
-- Window padding
config.window_padding = {
	left = 5,
	right = 5,
	top = 5,
	bottom = 5,
}

-- config.color_scheme = 'Batman'
-- config.color_scheme = 'AdventureTime'
-- config.color_scheme = 'Catppuccin Macchiato'
-- config.color_scheme = 'Clone Of Ubuntu (Gogh)'
config.color_scheme = "Spacedust (Gogh)"
-- config.color_scheme = 'SpaceGray'
-- config.color_scheme = "SpaceGray Eighties"
-- config.color_scheme = 'SpaceGray Eighties Dull'

-- local path = 'wallpapers/an_astronaut_in_space_with_a_glowing_planet.png'

local path = "wallpapers/an_astronaut_in_space_with_a_satellite.png"

-- config.window_background_image = wezterm.home_dir .. "/" .. path
--
-- config.window_background_image_hsb = {
-- 	-- Darken the background image by reducing it to 1/3rd
-- 	brightness = 0.03,
--
-- 	-- You can adjust the hue by scaling its value.
-- 	-- a multiplier of 1.0 leaves the value unchanged.
-- 	hue = 1.0,
-- 	-- hue = 0.9,
--
-- 	-- You can adjust the saturation also.
-- 	saturation = 5.0,
-- }

config.automatically_reload_config = true

-- wezterm.on("update-status", function(window, pane)
-- 	local time = wezterm.strftime("%H:%M:%S")
-- 	window:set_right_status(wezterm.format({
-- 		{ Text = "🕒 " .. time },
-- 	}))
-- end)

local wallpaper_names = {
	"a_aerial_view_of_a_snowy_mountain_range_01.jpg",
	"a_car_parked_in_a_dark_alley.jpg",
	"a_drawing_of_an_astronaut_in_space_suit.jpg",
	"aerial_view_of_a_city_at_night_01.jpg",
	"a_foggy_mountain_with_trees.jpg",
	"a_house_in_a_field_with_trees.jpg",
	"a_house_in_the_snow.png",
	"a_moon_over_a_mountain.png",
	"a_mountain_landscape_with_trees_and_a_building_on_top.png",
	"a_mountain_with_snow_on_it.jpg",
	"an_astronaut_in_space_with_a_glowing_planet.png",
	"an_astronaut_in_space_with_a_satellite.png",
	"a_path_in_a_forest.jpg",
	"a_path_through_a_forest.jpg",
	"a_road_with_trees_and_a_mountain_in_the_background.png",
	"a_road_with_trees_on_either_side_of_it.jpg",
	"a_rocky_beach_with_trees_and_water.jpg",
	"a_room_with_a_desk_and_a_chair_and_a_skull_on_the_wall.jpg",
	"a_snowy_mountain_tops.jpg",
	"a_wooden_building_on_a_hill_with_trees_in_the_background.jpg",
}

if not wezterm.GLOBAL.wallpapers then
	wezterm.GLOBAL.bg_idx = 1
end

local function cycle_background(window)
	wezterm.GLOBAL.bg_idx = (wezterm.GLOBAL.bg_idx % #wallpaper_names) + 1
	local full_path = wezterm.home_dir .. "/wallpapers/" .. wallpaper_names[wezterm.GLOBAL.bg_idx]

	window:set_config_overrides({
		window_background_image = full_path,
	})
end

local function adjust_hue(window, delta)
	local bg = window:get_config_overrides().window_background_image_hsb
	bg.hue = bg.hue + delta
	window:set_config_overrides({
		window_background_image_hsb = bg,
	})
end

config.keys = {
	{
		key = "b",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local p = "wallpapers/an_astronaut_in_space_with_a_glowing_planet.png"
			window:set_config_overrides({
				window_background_image = wezterm.home_dir .. "/" .. p,
			})
		end),
	},
	{
		key = "s",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			cycle_background(window)
		end),
	},
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			adjust_hue(window, 0.1)
		end),
	},
}

config.window_decorations = "TITLE | RESIZE"

-- -- Set the window title to show the current working directory
-- wezterm.on("format-window-title", function(tab, pane, tabs, pane_config, window_config)
-- 	return "Custom - " .. pane.current_working_dir
-- end)

wezterm.on("format-window-title", function(tab, pane, tabs, pane_config, window_config)
	local cwd = pane.current_working_dir
	if cwd then
		local path = cwd.file_path or cwd
		-- Remove trailing slash if present
		path = path:gsub("/$", "")
		-- Extract the last component of the path (including hidden dirs with .)
		local dir_name = path:match("([^/]+)$") or path
		return dir_name
	end
	return "WezTerm"
end)

-- Prevent applications from setting the window title
config.set_environment_variables = {
	-- This prevents applications from changing the title
	DISABLE_AUTO_TITLE = "true",
}

return config
