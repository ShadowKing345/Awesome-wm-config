--[[

    Titalbar configuration.

]]
--------------------------------------------------
local colors      = require "theme.colors"
local gFilesystem = require "gears.filesystem"

--------------------------------------------------
local M = { mt = {} }

--  general variables
--------------------------------------------------
local default_theme_path = gFilesystem.get_themes_dir()
local configPath         = gFilesystem.get_configuration_dir()

function M:call(config)
    config.titlebar = {
        bg               = {
            normal = colors.theme.bg.normal,
            focus  = colors.colors.black_3,
            urgent = colors.theme.bg.urgent,
        },
        fg               = {
            normal = colors.theme.fg.normal,
            focus  = colors.theme.fg.focus,
            urgent = colors.theme.fg.urgent,
        },
        close_button     = {
            normal = configPath .. "theme/titlebar/close.svg",
            focus  = configPath .. "theme/titlebar/close.svg",
        },
        minimize_button  = {
            normal = configPath .. "theme/titlebar/minimize.svg",
            focus  = configPath .. "theme/titlebar/minimize.svg",
        },
        maximized_button = {
            normal = {
                active   = configPath .. "theme/titlebar/maximize.svg",
                inactive = configPath .. "theme/titlebar/not_maximize.svg",
            },
            focus  = {
                active   = configPath .. "theme/titlebar/maximize.svg",
                inactive = configPath .. "theme/titlebar/not_maximize.svg",
            },
        },
        ontop_button     = {
            normal = {
                active   = default_theme_path .. "default/titlebar/ontop_normal_active.png",
                inactive = default_theme_path .. "default/titlebar/ontop_normal_inactive.png",
            },
            focus  = {
                active   = default_theme_path .. "default/titlebar/ontop_focus_active.png",
                inactive = default_theme_path .. "default/titlebar/ontop_focus_inactive.png",
            },
        },
        sticky_button    = {
            normal = {
                active   = default_theme_path .. "default/titlebar/sticky_normal_active.png",
                inactive = default_theme_path .. "default/titlebar/sticky_normal_inactive.png",
            },
            focus  = {
                active   = default_theme_path .. "default/titlebar/sticky_focus_active.png",
                inactive = default_theme_path .. "default/titlebar/sticky_focus_inactive.png",
            },
        },
        floating_button  = {
            normal = {
                active   = default_theme_path .. "default/titlebar/floating_normal_active.png",
                inactive = default_theme_path .. "default/titlebar/floating_normal_inactive.png",
            },
            focus  = {
                active   = default_theme_path .. "default/titlebar/floating_focus_active.png",
                inactive = default_theme_path .. "default/titlebar/floating_focus_inactive.png",
            },
        },
    }

    return config
end

--------------------------------------------------
function M.mt:__call(...)
    return M:call(...)
end

return setmetatable(M, M.mt)
