--[[

    Wibar setup

--]]
--------------------------------------------------
local setmetatable = setmetatable

local awful     = require "awful"
local beautiful = require "beautiful"
local dpi       = require "beautiful.xresources".apply_dpi
local wibox     = require "wibox"

--------------------------------------------------
local M = { mt = {} }

---Creates a new wibar.
---@param args WibarArgs
---@return table
function M:new(args)
    args = args or {}
    local separator = wibox.widget {
        {
            orientation = "vertical",
            span_ratio = 0.8,
            thickness = dpi(1),
            widget = wibox.widget.separator,
        },
        left = dpi(3),
        right = dpi(3),
        forced_width = dpi(7),
        widget = wibox.container.margin,
    }

    return awful.wibar {
        position = beautiful["wibar_position"],
        screen   = args.screen,
        widget   = {
            {
                forced_height = beautiful["wibar_border_width_top"] or dpi(1),
                widget        = wibox.widget.separator,
            },
            {
                {
                    args.launcher,
                    separator,
                    args.taglist,
                    separator,
                    layout = wibox.layout.fixed.horizontal,
                },
                args.tasklist,
                {
                    args.clock,
                    separator,
                    args.systray,
                    separator,
                    args.layoutbox,
                    layout = wibox.layout.fixed.horizontal,
                },
                layout = wibox.layout.align.horizontal,
            },
            layout = wibox.layout.fixed.vertical,
        }
    }
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)

--------------------------------------------------
---@class WibarArgs
---@field screen any #Screen object.
---@field taglist table #Taglist widget.
---@field tasklist table #Tasklist widget.
---@field launcher table #Launcher widget.
---@field clock table #Clock widget.
---@field systray table #System tray widget.
---@field layoutbox table #Layout box widget.
