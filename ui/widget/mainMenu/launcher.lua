--[[

    Launcher widget for the main menu.

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
    local n = "launcher"
    return utils.deepMerge({
        icon       = beautiful[n .. "icon"] or beautiful.awesome_icon,
        stylesheet = beautiful[n .. "stylesheet"],
        margins    = beautiful[n .. "margins"],
        padding    = beautiful[n .. "padding"],
        shape      = beautiful[n .. "shape"],
        bg         = {
            normal = beautiful[n .. "bg_normal"],
            hover  = beautiful[n .. "bg_hover"],
            active = beautiful[n .. "bg_active"],
        }
    }, style or {})
end

function M:new(args)
    args = args or {}
    local style = M.defaultStyle(args.style or {})

    local w = wibox.widget {
        {
            id     = "button",
            {
                {
                    image      = style.icon,
                    stylesheet = style.stylesheet,
                    widget     = wibox.widget.imagebox,
                },
                margins = style.padding,
                widget  = wibox.container.margin,
            },
            bg     = style.bg.normal,
            shape  = style.shape,
            widget = wibox.container.background,
        },
        margins = style.margins,
        widget  = wibox.container.margin,
    }

    local button = w:get_children_by_id "button"[1]
    button:buttons(gTable.join(
        awful.button({}, 1,
            function() button.bg = style.bg.active end,
            function() button.bg = style.bg.hover end)
    ))
    button:connect_signal("mouse::enter", function() button.bg = style.bg.hover end)
    button:connect_signal("mouse::leave", function() button.bg = style.bg.normal end)
    if args.mainMenu and type(args.mainMenu.toggle) == "function" then
        button:connect_signal("button::press", function(_, _, _, b, _, geometry)
            if b ~= 1 then
                return
            end

            args.mainMenu:toggle { geometry = geometry }
        end)
    end

    return w

end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
