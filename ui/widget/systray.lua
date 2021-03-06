--[[

    System tray widget.

--]]
--------------------------------------------------
local setmetatable = setmetatable
local unpack       = unpack or table.unpack

local awful     = require "awful"
local beautiful = require "beautiful"
local gTable    = require "gears.table"
local wibox     = require "wibox"

--------------------------------------------------
local M = {
    popup   = nil,
    ---@type SysTrayStyle
    style   = nil,
    systray = nil,
    mt      = {},
}

---Returns the default style for this widget.
---@return SysTrayStyle
function M.default_style()
    return {
        icon            = beautiful["systray_icon"],
        icon_stylesheet = beautiful["systray_icon_stylesheet"],
        bg              = {
            normal = beautiful["systray_bg_normal"] or beautiful.bg_normal,
            hover  = beautiful["systray_bg_hover"] or beautiful.bg_focus,
            active = beautiful["systray_bg_active"] or beautiful.bg_urgent,
        },
        fg              = {
            normal = beautiful["systray_fg_normal"] or beautiful.fg_normal,
            hover  = beautiful["systray_fg_hover"] or beautiful.fg_focus,
            active = beautiful["systray_fg_active"] or beautiful.fg_urgent,
        },
        padding         = beautiful["systray_padding"] or 3,
        popup           = {
            icon_size = beautiful["systray_popup_icon_size"] or 30,

            bg                = beautiful["systray_popup_bg"] or beautiful.bg_normal,
            fg                = beautiful["systray_popup_fg"] or beautiful.fg_normal,
            border_width      = beautiful["systray_popup_border_width"] or 1,
            border_color      = beautiful["systray_popup_border_color"] or beautiful.border_normal,
            padding           = beautiful["systray_popup_padding"] or 8,
            relative_position = beautiful["systray_popup_relative_placement"] or { "top", "left" },
        },
    }
end

---Creates a new instance of the popup used to show all the system try icons.
---@param args SysTrayArgs
function M:init(args)
    args = args or {}

    if not self.style then
        self.style = gTable.merge(self.default_style(), args.style or {})
    end

    if not self.systray then
        self.systray = wibox.widget.systray()
    end

    self.popup = wibox {
        ontop        = true,
        type         = "popup_menu",
        border_width = self.style.popup.border_width,
        border_color = self.style.popup.border_color,
        bg           = self.style.popup.bg,
        fg           = self.style.popup.fg,
        widget       = {
            self.systray,
            margins = self.style.popup.padding,
            widget  = wibox.container.margin,
        }
    }

    self.systray:connect_signal("widget::redraw_needed", function() M:update_popup_size_position() end)
end

---Updates the geometry and position of the popup.
function M:update_popup_size_position()
    if not self.popup then return end
    local size = self.style.popup.icon_size;
    if not size then return end

    local count, border_width, padding = awesome.systray(), self.style.popup.border_width, self.style.popup.padding
    local padding_horizontal, padding_vertical

    if count == 0 then
        count = 1
    end

    if type(padding) == "table" then
        padding_vertical = padding.top + padding.bottom
        padding_horizontal = padding.left + padding.right
    else
        padding_vertical = padding
        padding_horizontal = padding
    end

    self.popup.height = (border_width * 2) + padding_vertical + size
    self.popup.width = (border_width * 2) + padding_horizontal + (count * size)
    self.popup.x = self.popup.x - (self.popup.width / 2)
end

---Shows the popup.
---@param args SysTrayShowArgs
function M:show(args)
    if not self.popup then
        return
    end
    args = args or {}

    M:update_popup_size_position()

    if args.next_to then
        (awful.placement.next_to_mouse + awful.placement.no_offscreen)(self.popup, { honor_workarea = true })
    else
        awful.placement.next_to_mouse(self.popup)
    end

    self.popup.visible = true
end

---Hides the popup.
function M:hide()
    if not self.popup then
        return
    end

    self.popup.visible = false
end

---Toggles between the visible states for the popup.
---@param args SysTrayShowArgs
function M:toggle(args)
    if not self.popup then
        return
    end
    args = args or {}

    if self.popup.visible then
        self:hide()
    else
        self:show(args)
    end
end

---Creates a new systray button widget for used in the wibar.
---@param args any
---@return unknown
function M:new(args)
    args = args or {}
    if not self.style then
        self.style = gTable.merge(self.default_style(), args.style or {})
    end

    if not self.popup then
        self:init(args)
    end

    local w = wibox.widget {
        {
            {
                image      = self.style.icon,
                stylesheet = self.style.icon_stylesheet,
                widget     = wibox.widget.imagebox,
            },
            margins = self.style.padding,
            widget  = wibox.container.margin,
        },
        bg     = self.style.bg.normal,
        fg     = self.style.fg.normal,
        widget = wibox.container.background,
    }

    w._private.style = {
        bg = self.style.bg,
        fg = self.style.fg,
    }

    function w:change_state(state)
        self.bg = self._private.style.bg[state]
        self.fg = self._private.style.fg[state]
    end

    w:buttons(gTable.join(
        unpack(args.buttons or {}),
        awful.button({}, 1, function() w:change_state "active" end, function() w:change_state "hover" end),
        awful.button({}, 1, function() self:toggle { next_to = w } end)
    ))
    w:connect_signal("mouse::enter", function() w:change_state "hover" end)
    w:connect_signal("mouse::leave", function() w:change_state "normal" end)

    return w
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
--------------------------------------------------
---@class SysTrayArgs #Arguments for system tray.
---@field style? SysTrayStyle #Style used.

---@class SysTrayStyle #The style for the system tray widget.
---@field icon string #The icon to be used int the widget.
---@field icon_stylesheet string #Style for the icon.
---@field bg ButtonStyle #The button colors for the background.
---@field fg ButtonStyle #The button colors for the foreground.
---@field padding number|Cardinal #The padding for the button.
---@field popup SysTrayPopupStyle #Style for the popup wibox.

---@class SysTrayPopupStyle #The style for the popup wibox.
---@field icon_size number #The size of a systray icon.
---@field bg string #The background colors.
---@field fg string #The forground colors.
---@field border_width number #The border width.
---@field border_color string #The border color.
---@field padding number|Cardinal #The padding.
---@field relative_position string[] #The placement of the popup relative to the widget.

---@class SysTrayShowArgs #Argyments for when you are showing the system tray popup.
---@field next_to? table #Where to place the popup next to.
