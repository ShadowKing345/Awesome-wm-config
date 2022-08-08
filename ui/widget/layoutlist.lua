--[[

    Layout list similar to awful.layoutlist but allows for stylesheets.

]]
--------------------------------------------------
local awful      = require "awful"
local wibox      = require "wibox"
local beautiful  = require "beautiful"
local layoutlist = require "awful.layout"
local gTable     = require "gears.table"

--------------------------------------------------
local M = { mt = {} }

function M.default_style(style)
    local n = "layoutlist_"
    local s = {
        selectionNotchTempate = beautiful[n .. "selection_notch_tempate"] or {
            id           = "selection_notch",
            forced_width = 3,
            widget       = wibox.container.background,
        },
        selection = beautiful[n .. "selection"] or function(selected) return selected and beautiful["main"] or nil end,
        bg = {
            normal = beautiful[n .. "bg_normal"],
            hover  = beautiful[n .. "bg_hover"],
            active = beautiful[n .. "bg_active"],
        },
        fg = {
            normal = beautiful[n .. "fg_normal"],
            hover  = beautiful[n .. "fg_hover"],
            active = beautiful[n .. "fg_active"],
        },
        stylesheet = beautiful[n .. "stylesheet"],
    }

    local spacing  = beautiful[n .. "spacing"]
    local tSpacing = type(spacing)
    if tSpacing == "number" or tSpacing == "nil" then
        s.spacing = {
            forced_width = tSpacing == "number" and spacing or 5,
            widget       = wibox.container.background,
        }
    elseif tSpacing == "function" then
        s.spacing = spacing()
    else
        s.spacing = spacing
    end

    return gTable.merge(s, style or {})
end

function M.createLayoutWidget(style, layout)
    local name = layoutlist.getname(layout)
    local w = wibox.widget {
        {
            {
                style.selectionNotchTempate,
                style.spacing,
                {
                    image      = beautiful["layout_" .. name],
                    stylesheet = style.stylesheet,
                    widget     = wibox.widget.imagebox,
                },
                style.spacing,
                layout = wibox.layout.fixed.horizontal,
            },
            {
                text   = name or "[ No Name ]",
                widget = wibox.widget.textbox,
            },
            layout = wibox.layout.align.horizontal,
        },
        bg     = style.bg.normal,
        fg     = style.fg.normal,
        widget = wibox.container.background,
    }

    w:buttons(gTable.join(
        awful.button({}, 1,
            function()
                w.bg = style.bg.active
                w.fg = style.fg.active
                layoutlist.set(layout)
            end,
            function()
                w.bg = style.bg.hover
                w.fg = style.fg.hover
            end
        )
    ))

    w:connect_signal("mouse::enter", function()
        w.bg = style.bg.hover
        w.fg = style.fg.hover
    end)
    w:connect_signal("mouse::leave", function()
        w.bg = style.bg.normal
        w.fg = style.fg.normal
    end)

    function w:updateSelected(tag)
        local selected = tag.layout == layout
        local selectionNotch = w:get_children_by_id "selection_notch"[1]
        if selectionNotch and style.selection then selectionNotch.bg = style.selection(selected) end
    end

    return w
end

function M:new(args)
    args = args or {}
    args.style = self.default_style(args.style or {})
    local t = { layout = wibox.layout.flex.vertical, }

    for _, layout in pairs(layoutlist.layouts) do
        table.insert(t, M.createLayoutWidget(args.style, layout))
    end

    local w  = wibox.widget(t)
    w.style  = args.style
    w.screen = args.screen

    function w:updateSelected(tag)
        if not self.screen then return end
        for _, child in ipairs(self.children) do
            child:updateSelected(tag)
        end
    end

    return w
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
