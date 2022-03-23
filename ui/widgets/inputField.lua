--------------------------------------------------
--
--      Input Field Widget
--
--------------------------------------------------
local setmetatable = setmetatable

local beautiful = require "beautiful"
local rounded_rect = require "gears.shape".rounded_rect
local wibox = require "wibox"

local utils = require "utils"

--------------------------------------------------
local inputField = { mt = {} }

local function default_theme()
    return {
        bg = beautiful["input_field_bg"] or beautiful.bg_normal,
        border_width = beautiful["input_field_border_width"] or beautiful.border_width,
        border_color = beautiful["input_field_border_color"] or beautiful.border_focus,
        shape = beautiful["input_field_shape"] or function(cr, width, height) rounded_rect(cr, width, height, 2) end,
    }
end

local function new(args)
    args = args or {}
    local style = default_theme()

    local widget = wibox.widget {
        {
            {
                id = "text_role",
                text = args.placeholder or "",
                widget = wibox.widget.textbox,
            },
            left = 10,
            right = 10,
            widget = wibox.container.margin,
        },
        bg = style.bg,
        border_width = style.border_width,
        border_color = style.border_color,
        shape = style.shape,
        widget = wibox.container.background,
    }

    widget:buttons {
        utils.aButton {
            modifiers = {},
            button = 1,
            callback = function()
                widget._private.inputActive = true
                require "naughty".notify { text = "Mouse clicked inside." }
            end
        }
    }

    widget:connect_signal("mouse::leave", function(self)
        if self == widget and self._private.inputActive and not self._private.triggerReady then
            require "naughty".notify { text = "Mouse exited widget" }
            self._private.triggerReady = true

            mousegrabber.run(function(_mouse)
                for _, v in ipairs(_mouse.buttons) do
                    if v then
                        require "naughty".notify { text = "Mouse clicked" }
                        self._private.inputActive = false
                        self._private.triggerReady = false

                        return false
                    end
                end

                return true
            end, "num_glyphs")
        end
    end)

    widget:connect_signal("mouse::enter", function(self)
        if self._private.inputActive and self._private.triggerReady then
            require "naughty".notify { text = "Mouse re-entered widget" }
            self._private.triggerReady = false
        end
    end)

    function widget:set_placeholder(text)
        self:get_children_by_id "text_role"[1].text = text
    end

    return widget
end

--  Set Metadata
--------------------------------------------------
function inputField.mt.__call(_, ...)
    return new(...)
end

return setmetatable(inputField, inputField.mt)
