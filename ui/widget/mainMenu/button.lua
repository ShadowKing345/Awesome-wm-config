--------------------------------------------------
--
--      A button with an image and text.
--
--------------------------------------------------
local setmetatable = setmetatable

local aButton      = require "awful.button"
local beautiful    = require "beautiful"
local gTable       = require "gears.table"
local rounded_rect = require "gears.shape".rounded_rect
local wibox        = require "wibox"


--------------------------------------------------
local button = { default_string = "<span color=\"%s\">%s</span>", mt = {} }

function button.default_style()
    return {
        bg = {
            normal = beautiful["button_bg_normal"] or beautiful.bg_normal,
            hover  = beautiful["button_bg_hover"] or beautiful.bg_focus,
            active = beautiful["button_bg_active"] or beautiful.bg_urgent,
        },
        fg = {
            normal = beautiful["button_fg_normal"] or beautiful.fg_normal,
            hover  = beautiful["button_fg_hover"] or beautiful.fg_focus,
            active = beautiful["button_fg_active"] or beautiful.fg_urgent,
        },

        font    = beautiful["button_font"] or beautiful.font,
        padding = beautiful["button_padding"] or 3,
        shape   = function(cr, width, height) rounded_rect(cr, width, height, 2) end
    }
end

---Creates a new button with text.
---@param args {image:string, text:string, buttons:table, style: table}
---@return any
function button.new(args)
    args       = args or {}
    args.style = gTable.merge(button.default_style(), args.style or {})

    local ret = wibox.widget {
        {
            {
                {
                    image  = args.image,
                    widget = wibox.widget.imagebox,
                },
                {
                    text   = args.text,
                    font   = args.style.font,
                    widget = wibox.widget.textbox,
                },
                spacing = 10,
                layout  = wibox.layout.fixed.horizontal,
            },
            margins = args.style.padding,
            widget  = wibox.container.margin,
        },
        bg     = args.style.bg.normal,
        fg     = args.style.fg.normal,
        shape  = args.style.shape,
        widget = wibox.container.background,
    }

    ret:buttons(gTable.join(
        table.unpack(args.buttons or {}),
        aButton({}, 1,
            function()
                ret.bg = args.style.bg.active
                ret.fg = args.style.fg.active
            end,
            function()
                ret.bg = args.style.bg.hover
                ret.fg = args.style.fg.hover
            end
        )
    ))

    ret:connect_signal("mouse::enter", function()
        ret.bg = args.style.bg.hover
        ret.fg = args.style.fg.hover
    end)
    ret:connect_signal("mouse::leave", function()
        ret.bg = args.style.bg_normal
        ret.fg = args.style.fg_normal
    end)

    gTable.crush(ret, button, true)
    return ret
end

-- Set metadata
--------------------------------------------------
function button.mt:__call(...)
    return button.new(...)
end

return setmetatable(button, button.mt)
