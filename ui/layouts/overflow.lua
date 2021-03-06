--------------------------------------------------
--
--      Overflow layout.
--      Please be aweare that this is a copy paste of the overflow layout found here.
--      https://github.com/sclu1034/awesome/blob/feature/overflow_container/lib/wibox/layout/overflow.lua
--      All credit for this should go to sclu1034 and the AwesomeWM team over on github for this layout.
--      As it has yet to approved for official release I copying it with minimul changes such as formating and applying my coding practices
--      as well as fixed for potential issues I find along the way.
--
--------------------------------------------------
local setmetatable = setmetatable

local base = require "wibox.widget.base"
local fixed = require "wibox.layout.fixed"
local gObject = require "gears.object"
local gTable = require "gears.table"
local gShape = require "gears.shape"
local separator = require "wibox.widget.separator"

--------------------------------------------------
local overflow = { mt = {} }

function overflow:before_draw_children(_, cr, width, height)
    cr:rectangle(0, 0, width, height)
    cr:clip()
end

function overflow:layout(context, orig_width, orig_height)
    local result = {}
    local is_y = self._private.dir == "y"
    local widgets = self._private.widgets
    local avail_in_dir = is_y and orig_height or orig_width
    local scrollbar_width = self._private.scrollbar_width
    local scrollbar_enabled = self._private.scrollbar_enabled
    local scrollbar_position = self._private.scrollbar_position
    local width, height = orig_width, orig_height
    local widget_x, widget_y = 0, 0
    local used_in_dir, used_max = 0, 0

    if is_y then
        height = math.huge
    else
        width = math.huge
    end

    for _, widget in ipairs(widgets) do
        local w, h = base.fit_widget(self, context, widget, width, height)

        if is_y then
            used_max = math.max(used_max, w)
            used_in_dir = used_in_dir + h
        else
            used_max = math.max(used_max, h)
            used_in_dir = used_in_dir + w
        end
    end

    used_in_dir = used_in_dir + self._private.spacing * (#widgets - 1)

    self._private.avail_in_dir = avail_in_dir
    self._private.used_in_dir = used_in_dir

    local need_scrollbar = used_in_dir > avail_in_dir and scrollbar_enabled
    local scroll_position = self._private.scroll_factor

    if need_scrollbar then
        local scrollbar_widget = self._private.scrollbar_widget
        local bar_x, bar_y = 0, 0
        local bar_w, bar_h

        local visible_percent = avail_in_dir / used_in_dir

        local bar_length = math.floor(visible_percent * avail_in_dir)
        local bar_pos = (avail_in_dir - bar_length) * scroll_position

        if is_y then
            bar_w, bar_h = base.fit_widget(self, context, scrollbar_widget, scrollbar_width, bar_length)
            bar_y = bar_pos

            if scrollbar_position == "left" then
                widget_x = widget_x + bar_w
            elseif scrollbar_position == "right" then
                bar_x = orig_width - bar_w
            end

            self._private.bar_length = bar_h
            width = width - bar_w
        else
            bar_w, bar_h = base.fit_widget(self, context, scrollbar_widget, bar_length, scrollbar_width)
            bar_x = bar_pos

            if scrollbar_position == "top" then
                widget_y = widget_y + bar_h
            elseif scrollbar_position == "bottom" then
                bar_y = orig_height - bar_h
            end

            self._private.bar_length = bar_w

            height = height - bar_h
        end

        table.insert(result, base.place_widget_at(
            scrollbar_widget,
            math.floor(bar_x),
            math.floor(bar_y),
            math.floor(bar_w),
            math.floor(bar_h)
        ))
    end

    local pos, spacing = 0, self._private.spacing
    local interval = used_in_dir - avail_in_dir

    local spacing_widget = self._private.spacing_widget
    if spacing_widget then
        if is_y then
            local _
            _, spacing = base.fit_widget(self, context, spacing_widget, width, spacing)
        else
            spacing = base.fit_widget(self, context, spacing_widget, spacing, height)
        end
    end

    for i, w in ipairs(widgets) do
        local content_x, content_y
        local content_w, content_h = base.fit_widget(self, context, w, width, height)

        local scrolled_pos = pos - (scroll_position * interval)
        if scrolled_pos > avail_in_dir then
            break
        end

        if is_y then
            content_x, content_y = widget_x, scrolled_pos
            pos = pos + content_h + spacing

            if self._private.fill_space then
                content_w = width
            end
        else
            content_x, content_y = scrolled_pos, widget_y
            pos = pos + content_w + spacing

            if self._private.fill_space then
                content_h = height
            end
        end

        local is_in_view = is_y and (scrolled_pos + content_h > 0) or (scrolled_pos + content_w > 0)

        if is_in_view then
            if i > 1 and spacing_widget then
                table.insert(result, base.place_widget_at(
                    spacing_widget,
                    math.floor(is_y and content_x or (content_x - spacing)),
                    math.floor(is_y and (content_y - spacing) or content_y),
                    math.floor(is_y and content_w or spacing),
                    math.floor(is_y and spacing or content_h)
                ))
            end
        end

        table.insert(result, base.place_widget_at(
            w,
            math.floor(content_x),
            math.floor(content_y),
            math.floor(content_w),
            math.floor(content_h)
        ))
    end

    return result
end

function overflow:fit(context, orig_width, orig_height)
    local widgets = self._private.widgets
    local num_widgets = #widgets
    if num_widgets < 1 then
        return 0, 0
    end

    local width, height = orig_width, orig_height
    local scrollbar_width = self._private.scrollbar_width
    local scrollbar_enabled = self._private.scrollbar_enabled
    local used_in_dir, used_max = 0, 0
    local is_y = self._private.dir == "y"
    local avail_in_dir = is_y and orig_height or orig_width

    if is_y then
        height = math.huge
    else
        width = math.huge
    end

    for _, widget in ipairs(widgets) do
        local w, h = base.fit_widget(self, context, widget, width, height)

        if is_y then
            used_max = math.max(used_max, w)
            used_in_dir = used_in_dir + h
        else
            used_max = math.max(used_max, h)
            used_in_dir = used_in_dir + w
        end

        local spacing = self._private.spacing * (num_widgets - 1)
        used_in_dir = used_in_dir + spacing

        local need_scrollbar = scrollbar_enabled and used_in_dir > avail_in_dir

        if need_scrollbar then
            used_max = used_max + scrollbar_width
        end

        if is_y then
            return used_max, used_in_dir
        else
            return used_in_dir, used_max
        end
    end
end

function overflow:set_step(step)
    self._private.step = step
end

function overflow:scroll(amount)
    if amount == 0 then
        return
    end
    local interval = self._private.used_in_dir
    local delta = self._private.step / interval

    local factor = self._private.scroll_factor + (delta * amount)
    self:set_scroll_factor(factor)
end

function overflow:set_scroll_factor(factor)
    local current = self._private.scroll_factor
    local interval = self._private.used_in_dir - self._private.avail_in_dir
    if current == factor
        or interval <= 0
        or (current <= 0 and factor < 0)
        or (current >= 1 and factor > 1)
    then
        return
    end

    self._private.scroll_factor = math.min(1, math.max(factor, 0))

    self:emit_signal "widget::layout_changed"
    self:emit_signal("widget::scroll_factor", factor)
end

function overflow:get_scroll_factor()
    return self._private.scroll_factor
end

function overflow:set_scrollbar_width(width)
    if self._private.scrollbar_width == width then
        return
    end

    self._private.scrollbar_width = width

    self:emit_signal "widget::layout_changed"
    self:emit_signal("property::scrollbar_width", width)
end

function overflow:get_scrollbar_width()
    return self._private.scrollbar_width
end

function overflow:set_scrollbar_position(position)
    if self._private.scrollbar_position == position then
        return
    end

    self._private.scrollbar_position = position

    self:emit_signal "widget::layout_changed"
    self:emit_signal("property::scrollbar_position", position)
end

function overflow:get_scrollbar_position()
    return self._private.scrollbar_position
end

function overflow:set_scrollbar_enabled(enabled)
    if self._private.scrollbar_enabled == enabled then
        return
    end

    self._private.scrollbar_enabled = enabled
    self:emit_signal "widget::layout_changed"
    self:emit_signal("property::scrollbar_enabled", enabled)
end

function overflow:get_scrollbar_enabled()
    return self._private.scrollbar_enabled
end

function overflow.build_grabber(container, initial_x, initial_y, geo)
    local is_y = container._private.dir == "y"
    local bar_interval = container._private.avail_in_dir - container._private.bar_length
    local start_pos = container._private.scroll_factor * bar_interval
    local start = is_y and initial_y or initial_x

    local matrix_from_device = geo.hierarchy:get_matrix_from_device()
    local wgeo = geo.drawable.drawable:geometry()
    local matrix = matrix_from_device:translate(-wgeo.x, -wgeo.y)

    return function(mouse)
        if not mouse.buttons[1] then
            return false
        end

        local x, y = matrix:transform_point(mouse.x, mouse.y)
        local pos = is_y and x and y
        container:set_scroll_factor((start_pos + (pos - start)) / bar_interval)

        return true
    end
end

function overflow.apply_scrollbar_mouse_signal(container, w)
    w:connect_signal("button::press", function(_, x, y, button_id, _, geo)
        if button_id ~= 1 then
            return
        end
        mousegrabber.run(overflow.build_grabber(container, x, y, geo), "sb_" .. (container._private.dir == "y" and "v" or "h") .. "_double_arrow")
    end)
end

function overflow:set_scrollbar_widget(widget)
    local w = base.make_widget_from_value(widget)

    overflow.apply_scrollbar_mouse_signal(self, w)
    self._private.scrollbar_widget = w

    self:emit_signal "widget::layout_changed"
    self:emit_signal("property::scrollbar_widget", widget)
end

function overflow:get_scrollbar_widget()
    return self._private.scrollbar_widget
end

function overflow.new(dir, ...)
    local ret = fixed[dir](...)

    gTable.crush(ret, overflow, true)
    ret.widget_name = gObject.modulename(2)
    ret.clip_child_extends = true

    ret._private.scroll_factor = 0
    ret._private.step = 10
    ret._private.fill_space = true
    ret._private.scrollbar_width = 5
    ret._private.scrollbar_enabled = true
    ret._private.scrollbar_position = dir == "vertical" and "right" or "bottom"

    local scrollbar_widget = separator { shape = gShape.rectangle }
    overflow.apply_scrollbar_mouse_signal(ret, scrollbar_widget)
    ret._private.scrollbar_widget = scrollbar_widget

    ret:connect_signal("button::press", function(self, _, _, button)
        if button == 4 then
            self:scroll(-1)
        elseif button == 5 then
            self:scroll(1)
        end
    end)

    return ret
end

function overflow.horizontal(...)
    return overflow.new("horizontal", ...)
end

function overflow.vertical(...)
    return overflow.new("vertical", ...)
end

--------------------------------------------------
function overflow.mt:__call(...)
    return overflow.new(...)
end

return setmetatable(overflow, overflow.mt)
