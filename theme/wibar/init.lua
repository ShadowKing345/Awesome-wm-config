--[[

        Config for the main wibar.

]]
--------------------------------------------------
local dpi    = require "beautiful.xresources".apply_dpi
local gShape = require "gears.shape"

local colors = require "theme.colors"

--------------------------------------------------
local M = { mt = {} }

local function shape(ctx, width, height)
    gShape.rounded_rect(ctx, width, height, dpi(3))
end

--  General variables
--------------------------------------------------
local theme_path = require "gears.filesystem".get_xdg_config_home() .. "awesome/theme/"

function M:call(config)


    config.systray  = {
        widget = {
            icon    = {
                theme_path .. "/wibar/systray.svg",
                stylesheet = (".primary {stroke: %s; fill: none;}"):format(colors.theme.main),
                spacing = 10,
            },
            bg      = {
                normal = colors.theme.bg.button.normal,
                hover  = colors.theme.bg.button.hover,
                active = colors.theme.bg.button.active,
            },
            fg      = {
                normal = colors.theme.fg.button.normal,
                hover  = colors.theme.fg.button.hover,
                active = colors.theme.fg.button.active,
            },
            padding = dpi(5),
            margins = dpi(5),
            shape   = shape,
        },
        popup = {
            border_color = colors.theme.main,
        },
    }
    config.taglist  = {
        disable_icon = true,
        bg           = {
            occupied = colors.colors.gray_1,
            normal   = colors.theme.bg.button.normal,
            hover    = colors.theme.bg.button.hover,
            active   = colors.theme.bg.button.active,
        },
        fg           = {
            occupied = colors.theme.fg.minimize,
            normal   = colors.theme.fg.button.normal,
            hover    = colors.theme.fg.button.hover,
            active   = colors.theme.fg.button.active,
        },
        padding      = dpi(5),
        shape        = shape,
        width        = dpi(35),
    }
    config.tasklist = {
        plain_task_name = true,
        width           = 150,
        bg              = {
            normal = colors.theme.bg.button.normal,
            hover  = colors.theme.bg.button.hover,
            active = colors.theme.bg.button.active,
        },
        fg              = {
            normal = colors.theme.fg.button.normal,
            hover  = colors.theme.fg.button.hover,
            active = colors.theme.fg.button.active,
        },
        padding         = dpi(5),
        shape           = shape,
    }

    config.wibar = {
        height   = dpi(40),
        position = "bottom",
    }
    return config
end

--------------------------------------------------
function M.mt:__call(...)
    return M:call(...)
end

return setmetatable(M, M.mt)
