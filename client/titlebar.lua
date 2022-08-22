--[[

        Titlebar configuration

]]
--------------------------------------------------
local awful     = require "awful"
local beautiful = require "beautiful"
local gTable    = require "gears.table"
local wibox     = require "wibox"

local utils = require "utils"

--------------------------------------------------
local M = { mt = {} }

local function button(widget, style)
    style = style or {}

    local w = wibox.widget {
        {
            {
                widget,
                margins = style.buttons.padding,
                widget  = wibox.container.margin,
            },
            bg     = style.buttons.bg.normal,
            shape  = style.buttons.shape,
            widget = wibox.container.background,
        },
        margins = style.buttons.margins,
        widget  = wibox.container.margin,
    }

    w:connect_signal("mouse::enter", function() w.children[1].bg = style.buttons.bg.hover end)
    w:connect_signal("mouse::leave", function() w.children[1].bg = style.buttons.bg.normal end)

    w:buttons(gTable.join {
        awful.button({}, 1,
            function() w.bg = style.buttons.bg.active end,
            function() w.bg = style.buttons.bg.hover end)
    })

    return w
end

function M.defaultStyle(style)
    local n = "titlebar_"
    return utils.deepMerge({
        buttons = {
            bg      = {
                normal = beautiful[n .. "buttons_bg_normal"],
                hover  = beautiful[n .. "buttons_bg_hover"],
                active = beautiful[n .. "buttons_bg_active"],
            },
            padding = beautiful[n .. "buttons_padding"] or 0,
            margins = beautiful[n .. "buttons_margins"] or 0,
            shape   = beautiful[n .. "buttons_shape"],
        },
    }, style or {})
end

function M:init(args)
    args = args or {}
    local style = self.defaultStyle(args.style or {})

    client.connect_signal("request::titlebars", function(c)
        local buttons = {
            awful.button({}, 1, function()
                c:activate { context = "titlebar", action = "mouse_move" }
            end),
            awful.button({}, 3, function()
                c:activate { context = "titlebar", action = "mouse_resize" }
            end),
        }

        awful.titlebar(c).widget = {
            {
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout  = wibox.layout.fixed.horizontal
            },
            {
                {
                    align  = "center",
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                buttons = buttons,
                layout  = wibox.layout.flex.horizontal
            },
            {
                button(awful.titlebar.widget.floatingbutton(c), style),
                button(awful.titlebar.widget.maximizedbutton(c), style),
                button(awful.titlebar.widget.stickybutton(c), style),
                button(awful.titlebar.widget.ontopbutton(c), style),
                button(awful.titlebar.widget.closebutton(c), style),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal,
        }
    end)
end

--------------------------------------------------
function M.mt:__call(...)
    return M:init(...)
end

return setmetatable(M, M.mt)
