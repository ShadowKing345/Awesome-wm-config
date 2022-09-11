--------------------------------------------------
--
--      Category widget used in main menu.
--
--------------------------------------------------
local setmetatable = setmetatable
local unpack       = table.unpack

local beautiful    = require "beautiful"
local gTable       = require "gears.table"
local menubarUtils = require "menubar.utils"
local wibox        = require "wibox"

local utils = require "utils"

--------------------------------------------------
local category = { mt = {} }

---Returns the default style.
---@return CategoryStyle
function category.default_style()
    ---@type CategoryStyle
    local style = {
        bg = {
            normal = beautiful["mainmenu_category_bg_normal"] or beautiful.bg_normal,
            hover  = beautiful["mainmenu_category_bg_hover"] or beautiful.bg_focus,
            active = beautiful["mainmenu_category_bg_active"] or beautiful.bg_urgent,
        },
        fg = {
            normal = beautiful["mainmenu_category_fg_normal"] or beautiful.fg_normal,
            hover  = beautiful["mainmenu_category_fg_hover"] or beautiful.fg_focus,
            active = beautiful["mainmenu_category_fg_active"] or beautiful.fg_urgent,
        },

        padding = beautiful["mainmenu_category_padding"] or 4,
        spacing = beautiful["mainmenu_category_spacing"] or 4,

        default_icon = beautiful["mainmenu_category_default_icon"] or nil,

        icon_width  = beautiful["mainmenu_category_icon_width"] or 26,
        icon_height = beautiful["mainmenu_category_icon_height"] or 26,

        right_icon   = beautiful["mainmenu_category_right_button_icon"] or nil,
        right_width  = beautiful["mainmenu_category_right_button_width"] or 26,
        right_height = beautiful["mainmenu_category_right_button_height"] or 26,

        font   = beautiful.font or "sans 10",
        valign = beautiful["mainmenu_category_text_valign"] or "center",
    }

    return style
end

---Sets the colors for when the mouse enters
---@param self CategoryWidget
function category.on_mouse_enter(self)
    self.bg = self.style.bg.hover
    self.fg = self.style.fg.hover
end

---Sets the colors for when the mouse leaves
---@param self CategoryWidget
function category.on_mouse_leave(self)
    self.bg = self.style.bg.normal
    self.fg = self.style.fg.normal
end

---Sets the colors for when the button is pressed
---@param self CategoryWidget
function category.on_button_pressed(self)
    self.bg = self.style.bg.active
    self.fg = self.style.fg.active
end

---Creates a new category widget.
---@param args CategoryArgs #Arguments for category widget.
---@return CategoryWidget #New category widget.
function category.new(args)
    args       = args or {}
    args.style = gTable.merge(category.default_style(), args.style or {})

    ---@type CategoryWidget
    local ret = wibox.widget {
        {

            {
                {
                    {
                        image         = menubarUtils.lookup_icon(args.category.icon_name) or args.style.default_icon,
                        forced_width  = args.style.icon_width,
                        forced_height = args.style.icon_height,
                        widget        = wibox.widget.imagebox,
                    },
                    {
                        {
                            text   = args.category.name,
                            font   = args.style.font,
                            valign = args.style.valign,
                            widget = wibox.widget.textbox,
                        },
                        left   = args.style.spacing,
                        right  = args.style.spacing,
                        widget = wibox.container.margin,
                    },
                    {
                        image         = args.style.right_icon,
                        forced_width  = args.style.right_width,
                        forced_height = args.style.right_height,
                        widget        = wibox.widget.imagebox,
                    },
                    layout = wibox.layout.align.horizontal,
                },
                content_fill_horizontal = true,
                widget                  = wibox.container.place,
            },
            margins = args.style.padding,
            widget  = wibox.container.margin,
        },
        bg     = args.style.bg.normal,
        fg     = args.style.fg.normal,
        widget = wibox.container.background,
    }

    gTable.crush(ret, category, true)
    gTable.crush(ret, { style = args.style, category = args.category, callback = args.callback }, true)

    ret:buttons(gTable.join(
        utils.aButton {
            modifiers = {},
            button    = utils.button_names.LEFT,
            press     = function() category.on_button_pressed(ret) if args.callback then args.callback(category) end end,
            release   = function() category.on_mouse_enter(ret) end,
        },
        unpack(args.buttons or {})
    ))

    ret:connect_signal("mouse::enter", category.on_mouse_enter)
    ret:connect_signal("mouse::leave", category.on_mouse_leave)

    return ret
end

--------------------------------------------------
function category.mt:__call(...)
    return category.new(...)
end

return setmetatable(category, category.mt)

--------------------------------------------------
---@class CategoryWidget #The widget object.
---@field buttons function #Inherited from wibox.widget.base
---@field connect_signal function #Inherited from wibox.widget.base
---@field style CategoryStyle #Style object.
---@field category Category #Category.
---@field callback fun(category:Category):nil #Function callback for when the category is clicked.

---@class CategoryArgs
---@field category Category #Category used.
---@field style CategoryStyle #Style used for category.
---@field callback fun(category:Category):nil #Function callback for when the category is clicked.
---@field buttons table #Collection of awful buttons to be used for mouse input.

---@class Category
---@field name string #Name of the category.
---@field icon_name string #Name of the icon used. (Can be sort or long.)

---@class CategoryStyle
---@field bg ButtonStyle #The background color.
---@field fg ButtonStyle #The foreground color.
---@field padding {left:number,right:number,top:number,bottom:number} | number #The amount of padding used.
---@field spacing number #The amount of space between elements.
---@field default_icon string | nil #The icon used if none can be found.
---@field icon_width number #The width for the category icon.
---@field icon_height number #The height for the category icon.
---@field right_icon string | nil #The image used for the right button.
---@field right_width number #The width for the right button.
---@field right_height number #The height for the right button.
---@field font string #Font for the text.
---@field valign string #Vertical alignment for the text.
