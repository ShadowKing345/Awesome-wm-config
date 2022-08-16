--[[

    Application button widget for main menu.

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
    local n = "application_"
    return utils.deepMerge({
        width   = beautiful[n .. "width"],
        height  = beautiful[n .. "height"],
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
        image   = {
            default    = beautiful[n .. "image_default"],
            padding    = beautiful[n .. "image_padding"],
            shape      = beautiful[n .. "image_shpae"],
            stylesheet = beautiful[n .. "image_stylesheet"],
        },
        padding = beautiful[n .. "padding"],
        spacing = beautiful[n .. "spacing"] or 0,
        shape   = beautiful[n .. "shape"],
        font    = beautiful[n .. "image_font"] or beautiful.font,
    }, style or {})
end

function M:new(args)
    args             = args or {}
    self.application = args.application or {}
    local style      = self.defaultStyle(args.style or {})

    local w = wibox.widget {
        {
            {
                {
                    {
                        {
                            {
                                image      = self.application.icon or style.image.default,
                                stylesheet = style.stylesheet,
                                widget     = wibox.widget.imagebox,
                            },
                            shape  = style.image.shape,
                            widget = wibox.container.background,
                        },
                        margins = style.image.padding,
                        widget  = wibox.container.margin,
                    },
                    forced_height = style.height - style.spacing - style.padding - beautiful.get_font_height(style.font),
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
                spacing = style.spacing,
                layout  = wibox.layout.fixed.vertical,
            },
            margins = style.padding,
            widget  = wibox.container.margin,
        },
        bg            = style.bg.normal,
        fg            = style.fg.normal,
        forced_height = style.height,
        forced_width  = style.width,
        shape         = style.shape,
        widget        = wibox.container.background,
    }

    w:connect_signal("mouse::enter", function()
        w.bg = style.bg.hover
        w.fg = style.fg.hover
    end)
    w:connect_signal("mouse::leave", function()
        w.bg = style.bg.normal
        w.fg = style.fg.normal
    end)
    w:buttons(gTable.join(awful.button({}, 1,
        function()
            w.bg = style.bg.active
            w.fg = style.fg.active
        end,
        function()
            w.bg = style.bg.hover
            w.fg = style.fg.hover
        end
    )))

    if args.callback and type(args.callback) == "function" then
        w:add_button(awful.button({}, 1, function() awful.callback(self.application.cmdline) end))
    end

    if args.buttons then
        for _, v in ipairs(args.buttons) do
            w:add_button(v)
        end
    end

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
