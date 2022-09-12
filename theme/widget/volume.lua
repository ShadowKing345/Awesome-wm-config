--[[

        Config for volume widgets.

]]
--------------------------------------------------
local dpi    = require "beautiful.xresources".apply_dpi
local gShape = require "gears.shape"

local colors = require "theme.colors"

--------------------------------------------------

local M = { mt = {} }

function M:call(config)
    config.widget.volume = {
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
        margin  = dpi(5),
        wibox   = {
            button = {
                bg = {
                    normal = colors.theme.bg.button.normal,
                    hover  = colors.theme.bg.button.hover,
                    active = colors.theme.bg.button.active,
                },
                fg = {
                    normal = colors.theme.fg.button.normal,
                    hover  = colors.theme.fg.button.hover,
                    active = colors.theme.fg.button.active,
                },
                padding = dpi(5),
            },
            slider = {
                bg     = colors.theme.bg.button.active,
                width  = dpi(100),
                handle = {
                    color = colors.colors.gray_0,
                    shape = gShape.circle,
                    border =
                    {
                        width = dpi(1),
                        color = colors.theme.bg.button.hover,
                    },
                    width = dpi(15),
                },
                bar    = {
                    height = dpi(5),
                    color = colors.theme.bg.button.normal,
                    shape = function(ctx, w, h) gShape.rounded_rect(ctx, w, h, dpi(3)) end,
                },
            },
        },
    }


    return config
end

--------------------------------------------------
function M.mt:__call(config)
    return M:call(config)
end

return setmetatable(M, M.mt)
