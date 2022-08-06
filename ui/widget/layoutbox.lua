--[[

    Layoutbox
    Remake of the layoutbox provided by awful in order to implement widget.

]]
--------------------------------------------------
local awful     = require "awful"
local gTable    = require "gears.table"
local gShape    = require "gears.shape"
local wibox     = require "wibox"
local layout    = require "awful.layout"
local tooltip   = require "awful.tooltip"
local beautiful = require "beautiful"

local capi = { screen = screen, tag = tag }
--------------------------------------------------
local M    = {
    boxes = nil,
    mt    = {},
}

function M.getScreen(s)
    return s and capi.screen[s]
end

function M.defaultStyle(style)
    return gTable.merge({
        bg         = {
            normal = beautiful["layoutbox_bg_normal"],
            hover  = beautiful["layoutbox_bg_hover"],
            active = beautiful["layoutbox_bg_active"],
        },
        shape      = beautiful["layoutbox_shape"] or gShape.rectangle,
        padding    = beautiful["layoutbox_padding"] or 3,
        stylesheet = beautiful["layoutbox_stylesheet"] or "",
    }, style or {})
end

function M.update(w, screen)
    screen = M.getScreen(screen)
    local name = layout.getname(layout.get(screen))
    w._layoutboxToolTip:set_text(name or "[No Name]")

    local img                                        = beautiful["layout_" .. name]
    w._button:get_children_by_id "imagebox"[1].image = img
    w._button:get_children_by_id "textbox"[1].text   = img and "" or name
end

function M.updateFromTag(t)
    local screen = M.getScreen(t.screen)
    local w = M.boxes[screen]
    if w then
        M.update(w, screen)
    end
end

function M:new(args)
    args = args or {}
    local screen = self.getScreen(args.screen or 1)

    if self.boxes == nil then
        self.boxes = setmetatable({}, { __mode = "kv" })
        capi.tag.connect_signal("property::selected", self.updateFromTag)
        capi.tag.connect_signal("property::layout", self.updateFromTag)
        capi.tag.connect_signal("property::screen", function()
            for s, w in ipairs(self.boxes) do
                if s.valid then
                    self.update(w, s)
                end
            end
        end)
    end

    local w = self.boxes[screen]
    if not w then
        args.style = M.defaultStyle(args.style or {})
        local style = args.style

        local button = wibox.widget {
            {
                {
                    id         = "imagebox",
                    stylesheet = style.stylesheet,
                    widget     = wibox.widget.imagebox,
                },
                {
                    id     = "textbox",
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            bg     = style.bg.normal,
            shape  = style.shape,
            widget = wibox.container.background,
        }

        w = wibox.widget {
            button,
            margins = style.padding,
            widget  = wibox.container.margin,
        }

        w._layoutboxToolTip = tooltip { object = { w }, delay_show = 1 }
        w._button           = button

        if args.buttons then
            for _, b in ipairs(args.buttons) do
                button:add_button(b)
            end
        end

        button:buttons(gTable.join(
            awful.button({}, 1,
                function()
                    if args.layoutlist then args.layoutlist:toggle() end
                    button.bg = style.bg.active
                end,
                function() button.bg = style.bg.hover end
            )
        ))
        button:connect_signal("mouse::enter", function() button.bg = style.bg.hover end)
        button:connect_signal("mouse::leave", function() button.bg = style.bg.normal end)

        gTable.crush(w, args)

        self.update(w, screen)
        self.boxes[screen] = w
    end

    return w
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
