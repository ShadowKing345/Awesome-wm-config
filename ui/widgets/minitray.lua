local awful = require "awful"
local wibox = require "wibox"

local minitray = { widgets = {}, mt = {} }

function minitray:init()
    local wargs = {
        ontop = true,
        border_width = 3,
    }
    local geometry = { height = 40 }

    self.wibox = wibox(wargs)
    self.wibox:geometry(geometry)

    self.geometry = geometry

    local l = wibox.layout.align.horizontal()
    self.tray = wibox.widget.systray()
    l:set_middle(self.tray)
    self.wibox:set_widget(l)

    self.tray:connect_signal("widget::redraw_needed", function()
        self:update_geometry()
    end)
end

function minitray:update_geometry()
    local items = awesome.systray()
    if items == 0 then items = 1 end

    self.wibox:geometry { width = self.geometry.width or self.geometry.height * items }

    awful.placement.under_mouse(self.wibox)

    self.tray.screen = self.wibox.screen
end

function minitray:show()
    self:update_geometry()
    self.wibox.visible = true
end

function minitray:hide()
    self.wibox.visible = false
end

function minitray:toggle()
    if self.wibox.visible then
        self:hide()
    else
        self:show()
    end
end

function minitray:new()
    if not minitray.wibox then
        minitray:init()
    end

    local widg = wibox.widget {
        {
            text = "F",
            widget = wibox.widget.textbox,
        },
        margin = 4,
        widget = wibox.container.margin,
    }
    table.insert(minitray.widgets, widg)

    --  minitray.tray:connect_signal("widget::redraw_needed", function ()
    --   widg:update()
    --  end)

    return widg
end

function minitray.mt:__call()
    return minitray:new()
end

return setmetatable(minitray, minitray.mt)
