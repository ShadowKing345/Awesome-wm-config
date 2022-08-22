--[[

    Titalbar configuration.

]]
--------------------------------------------------
local colors      = require "theme.colors"
local dpi         = require "beautiful.xresources".apply_dpi
local gFilesystem = require "gears.filesystem"
local gShape      = require "gears.shape"

--------------------------------------------------
local M = { mt = {} }

--  general variables
--------------------------------------------------
local defaultThemePath = gFilesystem.get_themes_dir()
local configPath       = gFilesystem.get_configuration_dir()

function M:call(config)
    config.titlebar = {
        bg               = {
            normal = colors.theme.bg.normal,
            focus  = colors.theme.bg.normal,
            urgent = colors.theme.bg.urgent,
        },
        fg               = {
            normal = colors.theme.fg.normal,
            focus  = colors.theme.fg.focus,
            urgent = colors.theme.fg.urgent,
        },
        buttons          = {
            bg      = {
                normal = colors.theme.bg.button.normal,
                hover  = colors.theme.bg.button.hover,
                active = colors.theme.bg.button.active,
            },
            shape   = function(ctx, w, h) gShape.rounded_rect(ctx, w, h, dpi(5)) end,
            padding = dpi(3),
            margins = dpi(3),
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
                active   = defaultThemePath .. "default/titlebar/ontop_normal_active.png",
                inactive = defaultThemePath .. "default/titlebar/ontop_normal_inactive.png",
            },
            focus  = {
                active   = defaultThemePath .. "default/titlebar/ontop_focus_active.png",
                inactive = defaultThemePath .. "default/titlebar/ontop_focus_inactive.png",
            },
        },
        sticky_button    = {
            normal = {
                active   = defaultThemePath .. "default/titlebar/sticky_normal_active.png",
                inactive = defaultThemePath .. "default/titlebar/sticky_normal_inactive.png",
            },
            focus  = {
                active   = defaultThemePath .. "default/titlebar/sticky_focus_active.png",
                inactive = defaultThemePath .. "default/titlebar/sticky_focus_inactive.png",
            },
        },
        floating_button  = {
            normal = {
                active   = defaultThemePath .. "default/titlebar/floating_normal_active.png",
                inactive = defaultThemePath .. "default/titlebar/floating_normal_inactive.png",
            },
            focus  = {
                active   = defaultThemePath .. "default/titlebar/floating_focus_active.png",
                inactive = defaultThemePath .. "default/titlebar/floating_focus_inactive.png",
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
