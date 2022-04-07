--------------------------------------------------
--
--      Overflow layout.
--
--------------------------------------------------
local setmetatable = setmetatable

local base = require "wibox.widget.base"
local gTable = require "gears.table"

--------------------------------------------------
local overflow = { mt = {} }

function overflow:before_draw_children(_, cr, width, height)
    cr:rectangle(0, 0, width - 30, height - 30)
    cr:clip()
end

function overflow:layout(context, width, height)
    local result = {}

    local widget = self._private.widget
    local content_w, content_y = base.fit_widget(self, context, widget, math.huge, math.huge)

    table.insert(result, base.place_widget_at(widget, 0, 0, content_w, content_y))

    return result
end

function overflow:fit(_, width, height)
    return width, height
end

overflow.set_widget = base.set_widget_common

function overflow:get_widget()
    return self._private.widget
end

function overflow:get_childre()
    return { self._private.widget }
end

function overflow:set_children(children)
    self:set_widget(children[1])
end

---Creates ma new overflow layout widget.
---@param args any #Collection of arguments.
---@return table #Overflow widget.
function overflow.new(args)
    args = args or {}
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gTable.crush(ret._private, args, true)
    gTable.crush(ret, overflow, true)

    return ret
end

--------------------------------------------------
function overflow.mt:__call(...)
    return overflow.new(...)
end

return setmetatable(overflow, overflow.mt)
