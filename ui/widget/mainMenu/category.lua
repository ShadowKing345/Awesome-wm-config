--------------------------------------------------
--
--      Category widget used in main menu.
--
--------------------------------------------------
local setmetatable = setmetatable

local beautiful = require "beautiful"
local gTable = require "gears.table"
local menubarUtils = require "menubar.utils"
local wibox = require "wibox"

--------------------------------------------------
local category = { mt = {} }

---Returns the default style.
---@return CategoryStyle
function category.default_style()
    return {
        bg = beautiful["mainmenu_category_bg"] or beautiful.bg_normal,
        fg = beautiful["mainmenu_category_fg"] or beautiful.fg_normal,

        padding = beautiful["mainmenu_category_padding"] or 4,
        spacing = beautiful["mainmenu_category_spacing"] or 4,

        default_icon = beautiful["mainmenu_category_default_icon"] or nil,

        icon_width = beautiful["mainmenu_category_icon_width"] or 26,
        icon_height = beautiful["mainmenu_category_icon_height"] or 26,

        right_icon = beautiful["mainmenu_category_right_button_icon"] or nil,
        right_width = beautiful["mainmenu_category_right_button_width"] or 26,
        right_height = beautiful["mainmenu_category_right_button_height"] or 26,

        font = beautiful.font or "sans 10",
        valign = beautiful["mainmenu_category_text_valign"] or "center",
    }
end

---Creates a new category widget.
---@param args CategoryArgs #Arguments for category widget.
---@return table #New category widget.
function category.new(args)
    args = args or {}
    args.style = gTable.merge(category.default_style(), args.style or {})

    local ret = wibox.widget {
        {

            {
                {
                    {
                        image = menubarUtils.lookup_icon(args.category.icon_name) or args.style.default_icon,
                        forced_width = args.style.icon_width,
                        forced_height = args.style.icon_height,
                        widget = wibox.widget.imagebox,
                    },
                    {
                        {
                            text = args.category.name,
                            font = args.style.font,
                            valign = args.style.valign,
                            widget = wibox.widget.textbox,
                        },
                        left = args.style.spacing,
                        right = args.style.spacing,
                        widget = wibox.container.margin,
                    },
                    {
                        image = args.style.right_icon,
                        forced_width = args.style.right_width,
                        forced_height = args.style.right_height,
                        widget = wibox.widget.imagebox,
                    },
                    layout = wibox.layout.align.horizontal,
                },
                content_fill_horizontal = true,
                widget = wibox.container.place,
            },
            margins = args.style.padding,
            widget = wibox.container.margin,
        },
        bg = args.style.bg,
        fg = args.style.fg,
        widget = wibox.container.background,
    }

    gTable.crush(ret, category, true)
    gTable.crush(ret, args, true)

    if args.callback then
        ret:connect_signal("button::press", function(self, _, _, button)
            if button == 1 then
                self.callback(self)
            end
        end)
    end

    return ret
end

--------------------------------------------------
function category.mt:__call(...)
    return category.new(...)
end

return setmetatable(category, category.mt)

--------------------------------------------------
---@class CategoryArgs
---@field category Category #Category used.
---@field style CategoryStyle #Style used for category.
---@field callback function #Function callback for when the category is clicked.

---@class Category
---@field name string #Name of the category.
---@field icon_name string #Name of the icon used. (Can be sort or long.)

---@class CategoryStyle
---@field bg string #The background color.
---@field fg string #The foreground color.
---@field padding number #The amount of padding used.
---@field spacing number #The amount of space between elements.
---@field default_icon string #The icon used if none can be found.
---@field icon_width number #The width for the category icon.
---@field icon_height number #The height for the category icon.
---@field right_icon string #The image used for the right button.
---@field right_width number #The width for the right button.
---@field right_height number #The height for the right button.
---@field font string #Font for the text.
---@field valign string #Vertical alignment for the text.
