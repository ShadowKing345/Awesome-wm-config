--[[

        Wrapper for the textclock widget.

]]
--------------------------------------------------
local awful     = require "awful"
local wibox     = require "wibox"
local beautiful = require "beautiful"
local gTable    = require "gears.table"
local gShape    = require "gears.shape"

--------------------------------------------------
local M = { mt = {} }

function M.default_style(style)
    local n = "textclock_"
    return gTable.merge({
        margin  = beautiful[n .. "margin"],
        padding = beautiful[n .. "padding"],
        shape   = beautiful[n .. "shape"] or gShape.rectangle,
        bg      = {
            normal = beautiful[n .. "bg_normal"],
            hover  = beautiful[n .. "bg_hover"],
            active = beautiful[n .. "bg_active"],
        },
        fg      = {
            normal = beautiful[n .. "fg_normal"],
            hover  = beautiful[n .. "fg_hover"],
            active = beautiful[n .. "fg_active"],
        },
    }, style or {})
end

function M:new(args)
    args = args or {}
    local style = self.default_style(args.style or {})

    local button = wibox.widget {
        {
            wibox.widget.textclock(),
            margins = style.padding,
            widget  = wibox.container.margin,
        },
        bg     = style.bg.normal,
        fg     = style.fg.normal,
        shape  = style.shape,
        widget = wibox.container.background,
    }
    local w = wibox.widget {
        button,
        margins = style.margin,
        widget  = wibox.container.margin,
    }

    button:buttons(gTable.join(
        awful.button({}, 1,
            function()
                button.bg = self.style.bg.active
                button.fg = self.style.fg.active
            end,
            function()
                button.bg = self.style.bg.hover
                button.fg = self.style.fg.hover
            end)
    ))

    button:connect_signal("mouse::enter", function()
        button.bg = self.style.bg.hover
        button.fg = self.style.fg.hover
    end)
    button:connect_signal("mouse::leave", function()
        button.bg = self.style.bg.normal
        button.fg = self.style.fg.normal
    end)

    gTable.crush(w, self, false)

    return w
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
