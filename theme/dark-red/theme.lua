local colors = require( "theme.dark-red.colors" )
local themes_path = require( "gears.filesystem" ).get_themes_dir()
local theme_assets = require("beautiful.theme_assets")

local theme = {
    font = "JetBrains Regular 10",
    wallpaper = "/home/alex/Pictures/Wallpapers/217c548d2db8521a260e1c7f958af08e.jpg",

    -- bg
    bg_normal = colors.background1,
    bg_focus = colors.background3,
    bg_urgent = colors.color3,
    bg_minimize = colors.background2,

    -- fg
    fg_normal = colors.foreground,
    fg_focus = colors.foreground,
    fg_urgent = colors.foreground,
    fg_minimized = colors.foreground,

    -- border
    border_width = 0,

    -- fullscreen
    fullscreen_hide_border = true,

    -- gap
    useless_gap = 2,

    -- system tray
    systray_icon_spacing = 1,

    -- Tag list
    taglist_bg_urgent = colors.color2,
    taglist_bg_occupied = colors.background3,
    taglist_bg_focus = colors.background4,
    taglist_disable_icon = true,

    -- Icons
    titlebar_close_button_normal = themes_path .. "default/titlebar/close_normal.png",
    titlebar_close_button_focus = themes_path .. "default/titlebar/close_focus.png",

    titlebar_minimize_button_normal = themes_path .. "default/titlebar/minimize_normal.png",
    titlebar_minimize_button_focus = themes_path .. "default/titlebar/minimize_focus.png",

    titlebar_ontop_button_normal_inactive = themes_path .. "default/titlebar/ontop_normal_inactive.png",
    titlebar_ontop_button_focus_inactive = themes_path .. "default/titlebar/ontop_focus_inactive.png",
    titlebar_ontop_button_normal_active = themes_path .. "default/titlebar/ontop_normal_active.png",
    titlebar_ontop_button_focus_active = themes_path .. "default/titlebar/ontop_focus_active.png",

    titlebar_sticky_button_normal_inactive = themes_path .. "default/titlebar/sticky_normal_inactive.png",
    titlebar_sticky_button_focus_inactive = themes_path .. "default/titlebar/sticky_focus_inactive.png",
    titlebar_sticky_button_normal_active = themes_path .. "default/titlebar/sticky_normal_active.png",
    titlebar_sticky_button_focus_active = themes_path .. "default/titlebar/sticky_focus_active.png",

    titlebar_floating_button_normal_inactive = themes_path .. "default/titlebar/floating_normal_inactive.png",
    titlebar_floating_button_focus_inactive = themes_path .. "default/titlebar/floating_focus_inactive.png",
    titlebar_floating_button_normal_active = themes_path .. "default/titlebar/floating_normal_active.png",
    titlebar_floating_button_focus_active = themes_path .. "default/titlebar/floating_focus_active.png",

    titlebar_maximized_button_normal_inactive = themes_path .. "default/titlebar/maximized_normal_inactive.png",
    titlebar_maximized_button_focus_inactive = themes_path .. "default/titlebar/maximized_focus_inactive.png",
    titlebar_maximized_button_normal_active = themes_path .. "default/titlebar/maximized_normal_active.png",
    titlebar_maximized_button_focus_active = themes_path .. "default/titlebar/maximized_focus_active.png",

	menu_height = 16
}

theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

return theme
