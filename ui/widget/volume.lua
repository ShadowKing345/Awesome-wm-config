--[[

        Volume widget.

]]
--------------------------------------------------
local awful     = require "awful"
local beautiful = require "beautiful"
local gTable    = require "gears.table"
local wibox     = require "wibox"

local utils = require "utils"

--------------------------------------------------
local M = { mt = {} }

function M.defaultStyle(style)
    local n = "widget_volume_"
    return utils.deepMerge({
        bg      = {
            normal = beautiful[n .. "bg_normal"],
            hover  = beautiful[n .. "bg_hover"],
            active = beautiful[n .. "bg_active"],
        },
        padding = beautiful[n .. "padding"] or 0,
        margin  = beautiful[n .. "margin"] or 0,
    }, style or {})
end

function M:new(args)
    args = args or {}
    local style = self.defaultStyle(args.style or {})

    local button = wibox.widget {
        {
            {
                image  = beautiful.awesome_icon,
                widget = wibox.widget.imagebox,
            },
            margins = style.padding,
            widget  = wibox.container.margin,
        },
        bg     = style.bg.normal,
        widget = wibox.container.background,
    }

    local w = wibox.widget {
        button,
        margins = style.margin,
        widget  = wibox.container.margin,
    }

    button:connect_signal("mouse::enter", function() button.bg = style.bg.hover end)
    button:connect_signal("mouse::leave", function() button.bg = style.bg.normal end)
    button:buttons(gTable.join(args.buttons or {},
        awful.button({}, 1,
            function() button.bg = style.bg.active end,
            function() button.bg = style.bg.hover end
        )
    ))

    gTable.crush(w, self, false)

    return w
end

--------------------------------------------------
function M.mt:__call(args)
    return M:new(args)
end

return setmetatable(M, M.mt)
