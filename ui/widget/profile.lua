--[[
    
    Profile widget.

--]]
--------------------------------------------------
local setmetatable = setmetatable

local beautiful = require "beautiful"
local dpi       = require "beautiful.xresources".apply_dpi
local gTable    = require "gears.table"
local wibox     = require "wibox"

--------------------------------------------------
local M = { mt = {} }

---Creates the default style.
---@return ProfileStyle
function M.default_style()
    return {
        picture = {
            image        = beautiful["profile_picture"] or os.getenv "HOME" .. "/.face",
            width        = beautiful["profile_picture_width"] or 26,
            height       = beautiful["profile_picture_height"] or 26,
            bg           = beautiful["profile_picture_bg"],
            shape        = beautiful["profile_picture_shape"],
            border_color = beautiful["profile_picture_border_color"],
            border_width = beautiful["profile_picture_border_width"] or dpi(1),
        },
        name    = beautiful["profile_name"] or ("<i>" .. os.getenv "HOME":match "/home/(%w+)" .. "</i>"),
        padding = beautiful["profile_padding"] or 12,
        spacing = beautiful["profile_spacing"] or 10,
    }
end

---Creates a new instance of profile widget.
---@param style ProfileStyle #Style for widget.
---@return any #ProfileWidget.
function M:new(style)
    style = gTable.merge(M.default_style(), style or {})

    if type(style.name) == "function" then
        style.name = style.name()
    end

    local w = wibox.widget {
        {
            {
                {
                    image  = style.picture.image,
                    valign = "center",
                    halign = "center",
                    widget = wibox.widget.imagebox,
                },
                bg            = style.picture.bg,
                border_color  = style.picture.border_color,
                border_width  = style.picture.border_width,
                forced_width  = style.picture.width,
                forced_height = style.picture.height,
                shape         = style.picture.shape,
                widget        = wibox.widget.background,
            },
            {
                markup = style.name,
                widget = wibox.widget.textbox,
            },
            fill_space = true,
            spacing    = style.spacing,
            layout     = wibox.layout.fixed.horizontal,
        },
        margins = style.padding,
        widget  = wibox.container.margin,
    }

    gTable.crush(w, M, true)

    return w
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
--------------------------------------------------
---@class ProfileStyle #Styles for the profile widget.
---@field picture ProfilePictureStyle #Styles for the profile picture.
---@field name string|function():string #Name that will be displayed.
---@field padding number|Cardinal #Padding for the widget.
---@field spacing number #Spacing between image and text.

---@class ProfilePictureStyle #Styles for the profile picture.
---@field image string #Location of image to be used.
---@field width number #Width of image.
---@field height number #Height of image.
---@field bg string #Background color.
---@field shape function #Gears function for the shape.
