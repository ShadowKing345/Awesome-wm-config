--[[

    Titalbar configuration.

]]
--------------------------------------------------
local M = { mt = {} }

--  general variables
--------------------------------------------------
local default_theme_path = require "gears.filesystem".get_themes_dir()

function M:call(config)
    config.titlebar = {
        close_button     = {
            normal = default_theme_path .. "default/titlebar/close_normal.png",
            focus  = default_theme_path .. "default/titlebar/close_focus.png",
        },
        minimize_button  = {
            normal = default_theme_path .. "default/titlebar/minimize_normal.png",
            focus  = default_theme_path .. "default/titlebar/minimize_focus.png",
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
        maximized_button = {
            normal = {
                active   = default_theme_path .. "default/titlebar/maximized_normal_active.png",
                inactive = default_theme_path .. "default/titlebar/maximized_normal_inactive.png",
            },
            focus  = {
                active   = default_theme_path .. "default/titlebar/maximized_focus_active.png",
                inactive = default_theme_path .. "default/titlebar/maximized_focus_inactive.png",
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
