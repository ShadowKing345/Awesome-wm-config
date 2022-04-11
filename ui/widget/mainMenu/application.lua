--------------------------------------------------
--
--      Application button widget for main menu.
--
--------------------------------------------------
local setmetatable = setmetatable
local unpack       = unpack or table.unpack

local beautiful = require "beautiful"
local gTable    = require "gears.table"
local wibox     = require "wibox"

local utils = require "utils"

--------------------------------------------------
local application = { mt = {} }

---Returns the default category style.
---@return CategoryStyle
function application.default_style()
    ---@type CategoryStyle
    local style = {
        bg = {
            normal = beautiful["mainmenu_application_bg_normal"] or beautiful.bg_normal,
            hover  = beautiful["mainmenu_application_bg_hover"] or beautiful.bg_focus,
            active = beautiful["mainmenu_application_bg_active"] or beautiful.bg_urgent,
        },
        fg = {
            normal = beautiful["mainmenu_application_fs_normal"] or beautiful.fs_normal,
            hover  = beautiful["mainmenu_application_fs_hover"] or beautiful.fs_focus,
            active = beautiful["mainmenu_application_fs_active"] or beautiful.fs_urgent,
        },

        width  = beautiful["mainmenu_application_width"] or 80,
        height = beautiful["mainmenu_application_height"] or 80,

        default_application_icon = beautiful["mainmenu_application_default_application_icon"] or nil,
        padding                  = beautiful["mainmenu_application_padding"] or 5,
        image_padding            = beautiful["mainmenu_application_image_padding"] or 5,
        font                     = beautiful["mainmenu_application_image_font"] or beautiful.font
    }
    return style
end

---Sets the colors for when the mouse enters
---@param self ApplicationWidget
function application.on_mouse_enter(self)
    self.bg = self.style.bg.hover
    self.fg = self.style.fg.hover
end

---Sets the colors for when the mouse leaves
---@param self ApplicationWidget
function application.on_mouse_leave(self)
    self.bg = self.style.bg.normal
    self.fg = self.style.fg.normal
end

---Sets the colors for when the button is pressed
---@param self ApplicationWidget
function application.on_button_pressed(self)
    self.bg = self.style.bg.active
    self.fg = self.style.fg.active
end

---Creates a new category widget
---@param args ApplicationArgs
---@return ApplicationWidget
function application.new(args)
    args       = args or {}
    args.style = gTable.merge(application.default_style(), args.style or {})
    ---@type ApplicationWidget
    local ret  = wibox.widget {
        {
            {
                nil,
                {
                    {
                        {
                            image = args.application.icon or args.style.default_application_icon,
                            widget = wibox.widget.imagebox,
                        },
                        widget = wibox.container.place,
                    },
                    margins = args.style.image_padding,
                    widget  = wibox.container.margin,
                },
                {
                    text = args.application.name,

                    ellipsize = "end",
                    wrap      = "char",

                    font          = args.style.font,
                    forced_height = beautiful.get_font_height(args.style.font),

                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.align.vertical,
            },
            margins = args.style.padding,
            widget  = wibox.container.margin,
        },
        forced_width  = args.style.width,
        forced_height = args.style.height,

        bg = args.style.bg.normal,
        fg = args.style.fg.normal,

        widget = wibox.container.background,
    }

    gTable.crush(ret, application, true)
    gTable.crush(ret,
        {
            style       = args.style,
            application = args.application,
            callback    = args.callback
        }, true)

    ret:buttons(gTable.join(
        utils.aButton {
            modifiers = {},
            button    = utils.button_names.LEFT,
            press     = function() application.on_button_pressed(ret) end,
            release   = function() application.on_mouse_enter(ret) if args.callback then args.callback(args.application) end end,
        },
        unpack(args.buttons or {})
    ))

    ret:connect_signal("mouse::enter", application.on_mouse_enter)
    ret:connect_signal("mouse::leave", application.on_mouse_leave)

    return ret
end

--------------------------------------------------
function application.mt:__call(...)
    return application.new(...)
end

return setmetatable(application, application.mt)

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
---@field bg BgStyle #The background color.
---@field fg FgStyle #The foreground color.
---@field width number #The widget of the widget.
---@field height number #The height of the widget.
---@field padding number|{left:number,right:number,top:number,bottom:number} #The amount of padding used.
---@field image_padding number|{left:number,right:number,top:number,bottom:number} #The amount of padding used for the image.
---@field default_application_icon string #The icon used if none can be found.
---@field font string #Font for the text.
