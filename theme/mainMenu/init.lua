--[[

    Theme file for the main menu.

]]
--------------------------------------------------
local gShape = require "gears.shape"

local colors = require "theme.colors"

--------------------------------------------------
local M = { mt = {} }

--  General variables
--------------------------------------------------
local theme_path = require "gears.filesystem".get_xdg_config_home() .. "awesome/theme/"

function M:call(config)
    local mainMenuIconStyle = (".primary {stroke: %s; fill: none;}"):format(colors.theme.main)

    config.mainmenu = {
        image       = {
            reload   = {
                theme_path .. "mainMenu/power.svg",
                stylesheet = mainMenuIconStyle,
            },
            quit     = {
                theme_path .. "mainMenu/power.svg",
                stylesheet = mainMenuIconStyle,
            },
            sleep    = {
                theme_path .. "mainMenu/sleep.svg",
                stylesheet = mainMenuIconStyle,
            },
            reboot   = {
                theme_path .. "mainMenu/reboot.svg",
                stylesheet = mainMenuIconStyle,
            },
            shutdown = {
                theme_path .. "mainMenu/power.svg",
                stylesheet = mainMenuIconStyle,
            },
        },
        bg          = {
            left  = colors.colors.black_0,
            right = colors.colors.black_0,
        },
        category    = {
            bg = {
                normal = colors.theme.bg.button.normal,
                hover  = colors.theme.bg.button.hover,
                active = colors.theme.bg.button.active,
            },
            fg = {
                normal = colors.theme.fg.button.normal,
                hover  = colors.theme.fg.button.hover,
                active = colors.theme.fg.button.active,
            }
        },
        application = {
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
            shape = function(ctx, width, height) gShape.rounded_rect(ctx, width, height, 3) end,
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
