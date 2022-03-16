---@module "gears"
local gears = require "gears"
local theme_assets = require "beautiful.theme_assets"
local xresources = require "beautiful.xresources"
local dpi = xresources.apply_dpi

local gfs = gears.filesystem
local themes_path = gfs.get_themes_dir()

local theme = {}

theme.path = gfs.get_xdg_config_home() .. "awesome/theme/"
theme.wallpaper = theme.path .. "background.svg"
theme.font = "sans 10"

theme.bg_normal = "#222222"
theme.bg_focus = "#535d6c"
theme.bg_urgent = "#ff0000"
theme.bg_minimize = "#444444"
theme.bg_systray = theme.bg_normal

theme.fg_normal = "#aaaaaa"
theme.fg_focus = "#ffffff"
theme.fg_urgent = "#ffffff"
theme.fg_minimize = "#ffffff"

theme.useless_gap = dpi(0)
theme.border_width = dpi(1)
theme.border_normal = "#000000"
theme.border_focus = "#535d6c"
theme.border_marked = "#91231c"

theme.taglist_disable_icon = true
theme.taglist_bg_occupied = theme.bg_minimize

theme.tasklist_fg_normal = theme.fg_minimize
theme.tasklist_bg_normal = theme.bg_minimize
theme.tasklist_fg_minimize = "#ffffff"
theme.tasklist_bg_minimize = "#333333"
theme.tasklist_plain_task_name = true

theme.menu_submenu_icon = themes_path .. "default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width = dpi(100)

theme.titlebar_close_button_normal = themes_path .. "default/titlebar/close_normal.png"
theme.titlebar_close_button_focus = themes_path .. "default/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = themes_path .. "default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus = themes_path .. "default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = themes_path .. "default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = themes_path .. "default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path .. "default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = themes_path .. "default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path .. "default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = themes_path .. "default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path .. "default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = themes_path .. "default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path .. "default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = themes_path .. "default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path .. "default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = themes_path .. "default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path .. "default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = themes_path .. "default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path .. "default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = themes_path .. "default/titlebar/maximized_focus_active.png"

theme.layout_fairh = themes_path .. "default/layouts/fairhw.png"
theme.layout_fairv = themes_path .. "default/layouts/fairvw.png"
theme.layout_floating = themes_path .. "default/layouts/floatingw.png"
theme.layout_magnifier = themes_path .. "default/layouts/magnifierw.png"
theme.layout_max = themes_path .. "default/layouts/maxw.png"
theme.layout_fullscreen = themes_path .. "default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path .. "default/layouts/tilebottomw.png"
theme.layout_tileleft = themes_path .. "default/layouts/tileleftw.png"
theme.layout_tile = themes_path .. "default/layouts/tilew.png"
theme.layout_tiletop = themes_path .. "default/layouts/tiletopw.png"
theme.layout_spiral = themes_path .. "default/layouts/spiralw.png"
theme.layout_dwindle = themes_path .. "default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path .. "default/layouts/cornernww.png"
theme.layout_cornerne = themes_path .. "default/layouts/cornernew.png"
theme.layout_cornersw = themes_path .. "default/layouts/cornersww.png"
theme.layout_cornerse = themes_path .. "default/layouts/cornersew.png"

theme.wibar_height = 30
theme.wibar_position = "bottom"

theme.separator_color = theme.bg_minimize

theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.bg_focus, theme.fg_focus)

theme.icon_theme = nil

return theme
