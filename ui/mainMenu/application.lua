--[[

    Application button widget for main menu.

]]
--------------------------------------------------
local beautiful = require "beautiful"
local gTable    = require "gears.table"
local wibox     = require "wibox"

local utils = require "utils"

--------------------------------------------------
local M = { mt = {} }

function M.defaultStyle(style)
    local n = "application_"
    return utils.deepMerge({
        bg = {
            normal = beautiful[n .. "bg_normal"],
            hover  = beautiful[n .. "bg_hover"],
            active = beautiful[n .. "bg_active"],
        },
        fg = {
            normal = beautiful[n .. "fg_normal"],
            hover  = beautiful[n .. "fg_hover"],
            active = beautiful[n .. "fg_active"],
        },

        default_application_icon = beautiful[n .. "default_application_icon"],
        padding                  = beautiful[n .. "padding"],
        image_padding            = beautiful[n .. "image_padding"],
        font                     = beautiful[n .. "image_font"] or beautiful.font,

        shape = beautiful[n .. "shape"],
    }, style or {})
end

function M:new(args)
    args             = args or {}
    self.application = args.application or {}
    local style      = self.defaultStyle(args.style or {})

    local w = wibox.widget {
        {
            {
                nil,
                {
                    {
                        image  = self.application.icon,
                        widget = wibox.widget.imagebox,
                    },
                    widget = wibox.container.place,
                },
                {
                    text = self.application.name or "Fish",

                    ellipsize = "end",
                    wrap      = "char",

                    font          = style.font,
                    forced_height = beautiful.get_font_height(style.font),

                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.align.vertical,
            },
            widget = wibox.container.margin,
        },
        forced_height = 50,
        forced_width  = 50,
        bg            = style.bg.normal,
        fg            = style.fg.normal,
        shape         = style.shape,
        widget        = wibox.container.background,
    }

    return w
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)

--------------------------------------------------
---@class ApplicationWidget #The widget object.
---@field buttons function #Inherited from wibox.widget.base
---@field connect_signal function #Inherited from wibox.widget.base
---@field style ApplicationStyle #Style object.
---@field application Application #Application.
---@field callback fun(application:Application):nil #Function callback for when the application is clicked.

---@class ApplicationArgs
---@field application Application #Application used.
---@field style ApplicationStyle #Style used for application.
---@field callback fun(application:Application):nil #Function callback for when the application is clicked.
---@field buttons table #Collection of awful buttons to be used for mouse input.

---@class Application
---@field name string #Name of the application.
---@field icon string #Name of the icon used. (Can be sort or long.)

---@class ApplicationStyle
---@field bg ButtonStyle #The background color.
---@field fg ButtonStyle #The foreground color.
---@field width number #The widget of the widget.
---@field height number #The height of the widget.
---@field padding number|{left:number,right:number,top:number,bottom:number} #The amount of padding used.
---@field image_padding number|{left:number,right:number,top:number,bottom:number} #The amount of padding used for the image.
---@field default_application_icon string #The icon used if none can be found.
---@field font string #Font for the text.
---@field shape function #Shape for the button.
