--[[

    A button with an image and text.

]]
--------------------------------------------------
local setmetatable = setmetatable

local aButton   = require "awful.button"
local beautiful = require "beautiful"
local gTable    = require "gears.table"
local wibox     = require "wibox"

local utils = require "utils"

--------------------------------------------------
local M = { mt = {} }

function M.defaultStyle(style)
    local n = "button_"
    return utils.deepMerge({
        image      = beautiful[n .. "image"],
        stylesheet = beautiful[n .. "stylesheet"],
        bg         = {
            normal = beautiful[n .. "bg_normal"],
            hover  = beautiful[n .. "bg_hover"],
            active = beautiful[n .. "bg_active"],
        },
        fg         = {
            normal = beautiful[n .. "fg_normal"],
            hover  = beautiful[n .. "fg_hover"],
            active = beautiful[n .. "fg_active"],
        },
        font       = beautiful[n .. "font"] or beautiful.font,
        padding    = beautiful[n .. "padding"],
        spacing    = beautiful[n .. "spacing"],
        shape      = beautiful[n .. "shape"],
    }, style or {})
end

---Creates a new button with text.
---@param args {image:string, text:string, buttons:table, style: table, stylesheet:string}
---@return any
function M:new(args)
    args        = args or {}
    local style = self.defaultStyle(args.style or {})

    local w = wibox.widget {
        {
            {
                {
                    image      = style.image,
                    stylesheet = style.stylesheet,
                    widget     = wibox.widget.imagebox,
                },
                {
                    text   = args.text,
                    widget = wibox.widget.textbox,
                },
                spacing    = style.spacing,
                fill_space = true,
                layout     = wibox.layout.fixed.horizontal,
            },
            margins = style.padding,
            widget  = wibox.container.margin,
        },
        bg     = style.bg.normal,
        fg     = style.fg.normal,
        shape  = style.shape,
        widget = wibox.container.background,
    }

    w:connect_signal("mouse::enter", function()
        w.bg = style.bg.hover
        w.fg = style.fg.hover
    end)
    w:connect_signal("mouse::leave", function()
        w.bg = style.bg.normal
        w.fg = style.fg.normal
    end)
    w:buttons(gTable.join(
        aButton({}, 1,
            function()
                w.bg = style.bg.active
                w.fg = style.fg.active
            end,
            function()
                w.bg = style.bg.hover
                w.fg = style.fg.hover
            end)
    ))
    if args.buttons then
        for _, button in ipairs(args.buttons) do
            w:add_button(button)
        end
    end

    gTable.crush(w, self, true)
    return w
end

-- Set metadata
--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
