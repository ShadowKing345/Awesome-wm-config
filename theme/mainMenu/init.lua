--[[

    Theme file for the main menu.

]]
--------------------------------------------------
local dpi    = require "beautiful.xresources".apply_dpi
local gShape = require "gears.shape"

local colors = require "theme.colors"

--------------------------------------------------
local M = { mt = {} }

--  General variables
--------------------------------------------------
local themePath = require "gears.filesystem".get_configuration_dir() .. "theme/mainMenu/"

local function shape(ctx, w, h)
    return gShape.rounded_rect(ctx, w, h, dpi(3))
end

local bg = {
    normal = colors.theme.bg.button.normal,
    hover  = colors.theme.bg.button.hover,
    active = colors.theme.bg.button.active,
}
local fg = {
    normal = colors.theme.fg.button.normal,
    hover  = colors.theme.fg.button.hover,
    active = colors.theme.fg.button.active,
}


function M:call(config)
    local stylesheet = (".primary {stroke: %s; fill: none;}"):format(colors.theme.main)

    config.mainmenu = {
        launcher = {
            margins = dpi(5),
            shape   = shape,
            bg      = bg,
        },
        wibox    = {
            bg           = {
                left  = colors.colors.black_0,
                right = colors.colors.black_0,
            },
            buttons      = {
                icons   = {
                    stylesheet = stylesheet,
                    reload     = {
                        icon = themePath .. "power.svg",
                    },
                    quit       = {
                        icon = themePath .. "power.svg",
                    },
                    sleep      = {
                        icon = themePath .. "sleep.svg",
                    },
                    reboot     = {
                        icon = themePath .. "reboot.svg",
                    },
                    shutdown   = {
                        icon = themePath .. "power.svg",
                    },
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
                shape   = shape,
                spacing = dpi(10),
            },
            applications = {
                fg      = fg,
                bg      = bg,
                width   = dpi(50),
                height  = dpi(80),
                spacing = dpi(5),
                padding = dpi(5),
                shape   = shape,
                image   = {
                    padding    = dpi(5),
                    shape      = shape,
                    stylesheet = stylesheet,
                },
            },
        },
    }
    config.profile  = {
        picture = {
            bg           = colors.colors.black_4,
            shape        = gShape.circle,
            border_width = 0,
        },
    }
    return config
end

--------------------------------------------------
function M.mt:__call(...)
    return M:call(...)
end

return setmetatable(M, M.mt)
