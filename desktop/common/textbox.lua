-- Based on the redflat version but the text aligns to one of the 9 standard ui anchors.
local setmetatable = setmetatable
local wibox = require("wibox")
local color = require("gears.color")
local beautiful = require("beautiful")

local redutil = require("redflat.util")

local textbox = {mt = {}}

local function default_style()
    local style = {
        width = nil,
        height = nil,
        draw = "upper_left",
        separator = '%s',
        color = "#404040",
        font = {font = "Sans", size = 20, face = 0, slant = 0}
    }

    return redutil.table.merge(style, redutil.table.check(beautiful, "desktop.common.personal.textbox") or {})
end

local align = {}

function align.upper_left(cr, width, height, text)
    local ext = cr:text_extents(text)

    cr:move_to(0, ext.height)
    cr:show_text(text)
end

function align.upper_center(cr, width, height, text)
    local ext = cr:text_extents(text)
    cr:move_to((width / 2) - (ext.width / 2), ext.height)
    cr:show_text(text)
end

function align.upper_right(cr, width, height, text)
    local ext = cr:text_extents(text)
    cr:move_to(width - ext.width - 10, ext.height)
    cr:show_text(text)
end

function align.middle_left(cr, width, height, text)
    local ext = cr:text_extents(text)
    cr:move_to(0, (height / 2) - (ext.height / 2))
    cr:show_text(text)
end

function align.middle_center(cr, width, height, text)
    local ext = cr:text_extents(text)
    cr:move_to((width / 2) - (ext.width / 2), (height / 2) - (ext.height / 2))
    cr:show_text(text)
end

function align.middle_right(cr, width, height, text)
    local ext = cr:text_extents(text)
    cr:move_to(width - ext.width - 10, (height / 2) - (ext.height / 2))
    cr:show_text(text)
end

function align.lower_left(cr, _, height, text)
    local ext = cr:text_extents(text)
    cr:move_to(0, height - 10)
    cr:show_text(text)
end

function align.lower_center(cr, width, height, text)
    local ext = cr:text_extents(text)
    cr:move_to((width / 2) - (ext.width / 2), height - 10)
    cr:show_text(text)
end

function align.lower_right(cr, width, height, text)
    local ext = cr:text_extents(text)
    cr:move_to(width - ext.width - 10, height - 10)
    cr:show_text(text)
end

function textbox.new(txt, style)
    style = redutil.table.merge(default_style(), style or {})

    local textwidg = wibox.widget.base.make_widget()
    textwidg._data = {
        text = txt or "",
        width = style.width,
        color = style.color
    }

    function textwidg:set_text(text)
        if self._data.text ~= text then
            self._data.text = text
            self:emit_signal("widget::redraw_needed")
        end
    end

    function textwidg:set_color(value)
        if self._data.color ~= value then
            self._data.color = value
            self:emit_signal("widget::redraw_needed")
        end
    end

    function textwidg:set_width(width)
        if self._data.width ~= width then
            self._data.width = width
            self:emit_signal("widget::redraw_needed")
        end
    end

    function textwidg:fit(_, width, height)
        local w = self._data.width and math.min(self._data.width, width) or
                      width
        local h = style.height and math.min(style.height, height) or height
        return w, h
    end

    function textwidg:draw(_, cr, width, height)
        cr:set_source(color(self._data.color))
        redutil.cairo.set_font(cr, style.font)

        align[style.draw](cr, width, height, self._data.text)
    end

    return textwidg
end

function textbox.mt:__call(...) return textbox.new(...) end

return setmetatable(textbox, textbox.mt)
