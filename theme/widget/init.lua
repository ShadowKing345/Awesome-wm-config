--[[

        Config for widgets.

]]
--------------------------------------------------
local configDir = require "gears.filesystem".get_configuration_dir()
local dpi       = require "beautiful.xresources".apply_dpi
local gShape    = require "gears.shape"

local colors = require "theme.colors"

--------------------------------------------------
local M = { mt = {} }

local function shape(ctx, width, height)
    gShape.rounded_rect(ctx, width, height, dpi(3))
end

function M:call(config)
    config.widget = {
        battery = {
            icons         = {
                stylesheet = (".primary {stroke: %s; fill: none;}"):format(colors.theme.main),
            },
            bg            = {
                normal = colors.theme.bg.button.normal,
                hover  = colors.theme.bg.button.hover,
                active = colors.theme.bg.button.active,
            },
            fg            = {
                normal = colors.theme.fg.button.normal,
                hover  = colors.theme.fg.button.hover,
                active = colors.theme.fg.button.active,
            },
            status_script = configDir .. "scripts/battery.py",
            padding       = dpi(5),
            margin        = dpi(5),
            shape         = shape,
            timer_timeout = 10,
        }
    }

    return config
end

--------------------------------------------------
function M.mt:__call(...)
    return M:call(...)
end

return setmetatable(M, M.mt)
