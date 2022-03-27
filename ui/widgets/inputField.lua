-------------------------------------------------
--
--      Input Field Widget
--
--------------------------------------------------
local setmetatable = setmetatable

local awful = require "awful"
local beautiful = require "beautiful"
local gColor = require "gears.color"
local gString = require "gears.string"
local gTable = require "gears.table"
local rounded_rect = require "gears.shape".rounded_rect
local wibox = require "wibox"

local utils = require "utils"

--------------------------------------------------
local inputField = { mt = {} }

---Creates the default theme used.
---@return InputFieldStyle
function inputField.default_theme()
    return {
        bg = beautiful["input_field_bg"] or beautiful.bg_normal,
        fg = beautiful["input_field_fg"] or beautiful.fg_normal,
        cursor_fg = beautiful["input_field_fg_cursor"] or beautiful.prompt_fg_cursor,
        cursor_bg = beautiful["input_field_bg_cursor"] or beautiful.prompt_bg_cursor,
        font = beautiful["input_field_font"] or beautiful.prompt_font,
        border_width = beautiful["input_field_border_width"] or beautiful.border_width,
        border_color = beautiful["input_field_border_color"] or beautiful.border_focus,
        shape = beautiful["input_field_shape"] or function(cr, width, height) rounded_rect(cr, width, height, 2) end,
    }
end

---Helper function to determine if there is more then 1 character.
function inputField.have_multibyte_char_at(text, position)
    return text:sub(position, position):wlen() == -1
end

---Gets a textbox markup friendly string.
---Based on the method prompt_text_with_cursor from awful.prompt
---@param args TextSanitizerArgs #The table of arguments.
---@return string #Parsed string.
function inputField.sanitize_text(args)
    args.placeholder = args.placeholder or ""

    local char, text_start, text_end
    local text = args.text or ""

    if #text < args.cursor_pos then
        char = args.cursor_hide and "" or " "
        text_start = gString.xml_escape(text)
        text_end = ""
    else
        if #text == 0 then
            char = ""
            text_start = args.placeholder and ("<i>" .. args.placeholder .. "</i>") or ""
            text_end = ""
        else
            local offset = 0
            if inputField.have_multibyte_char_at(text, args.cursor_pos) then
                offset = 1
            end
            char = gString.xml_escape(text:sub(args.cursor_pos, args.cursor_pos + offset))
            text_start = gString.xml_escape(text:sub(1, args.cursor_pos - 1))
            text_end = gString.xml_escape(text:sub(args.cursor_pos + 1 + offset))
        end
    end

    local cursor_color = gColor.ensure_pango_color(args.style.cursor_bg)
    local text_color = gColor.ensure_pango_color(args.style.cursor_fg)

    return text_start .. "<span background=\"" .. cursor_color .. "\" foreground=\"" .. text_color .. "\" >" .. char .. "</span>" .. text_end
end

---The keypress callback function used to parse the input into text.
---Based on the awful.prompt version.
---@param self {stop:function} #The keygrabber itself.
---@param _ table #Modifier keys.
---@param key string #The actual key pressed.
---@param widget table #The input field widget the callback was called for.
function inputField.keypressed_callback(self, _, key, widget)
    local text = widget.text or ""
    ---@type TextSanitizerArgs
    local markupParseArgs = {
        text = text,
        placeholder = widget.placeholder,
        cursor_pos = #text + 1,
        style = widget._private.style,
    }

    if key == "Return" or key == "Escape" then
        markupParseArgs.cursor_hide = true
        widget:get_children_by_id "text_role"[1]:set_markup(inputField.sanitize_text(markupParseArgs))
        self:stop()
        return
    end

    if key == "BackSpace" then
        text = text:sub(1, -2)
    else
        text = text .. key
    end

    widget.text = text
    markupParseArgs.text = text
    markupParseArgs.cursor_pos = #text + 1
    widget:get_children_by_id "text_role"[1]:set_markup(inputField.sanitize_text(markupParseArgs))
end

---@param args inputFieldNewArgs #Arguments for function.
---@return table #Widget object.
function inputField.new(args)
    args = args or {}
    args.style = gTable.merge(inputField.default_theme(), args.style or {})

    local ret = wibox.widget {
        {
            {
                id = "text_role",
                markup = inputField.sanitize_text {
                    text = args.text or "",
                    placeholder = args.placeholder or "",
                    cursor_pos = #(args.text or ""),
                    style = args.style,
                },
                font = args.style.font,
                fg = args.style.fg,
                ellipsize = "start",
                widget = wibox.widget.textbox,
            },
            left = 10,
            right = 10,
            widget = wibox.container.margin,
        },
        bg = args.style.bg,
        border_width = args.style.border_width,
        border_color = args.style.border_color,
        shape = args.style.shape,
        widget = wibox.container.background,
    }

    gTable.crush(ret, inputField, true)

    ret._private.style = args.style
    ret._private.grabber = awful.keygrabber {
        keypressed_callback = function(self, modifiers, key) inputField.keypressed_callback(self, modifiers, key, ret) end,
        mask_modkeys = true,
    }

    if args.placeholder then
        ret._private.placeholder = args.placeholder
    end
    if args.text then
        ret._private.text = args.text
    end
    if args.change_callback then
        ret._private.change_callback = args.change_callback
    end


    ret:buttons {
        utils.aButton {
            modifiers = {},
            button = 1,
            callback = function()
                ret._private.inputActive = true
                ret._private.grabber:start()
            end
        }
    }

    ret:connect_signal("mouse::leave", function(self)
        if self == ret and self._private.inputActive and not self._private.triggerReady then
            self._private.triggerReady = true

            mousegrabber.run(function(_mouse)
                for _, v in ipairs(_mouse.buttons) do
                    if v then
                        ret._private.inputActive = false
                        ret._private.triggerReady = false

                        ret._private.grabber:stop()

                        return false
                    end
                end

                return true
            end, "left_ptr")
        end
    end)

    ret:connect_signal("mouse::enter", function(self)
        if self._private.inputActive and self._private.triggerReady then
            self._private.triggerReady = false
        end
    end)

    return ret
end

--  Set Metadata
--------------------------------------------------
function inputField.mt.__call(_, ...)
    return inputField.new(...)
end

return setmetatable(inputField, inputField.mt)

--------------------------------------------------
-- Class definitions

---@class InputFieldStyle
---@field bg string #Background color.
---@field fg string #Foreground color.
---@field cursor_fg string #Cursor foreground color.
---@field cursor_bg string #Cursor background color.
---@field font string #Font used.
---@field border_width number #Border width.
---@field border_color string #Border color.
---@field shape function #Gears shape function used to create the edge.

---@class inputFieldNewArgs
---@field style? InputFieldStyle #Style overwrite.
---@field text? string #Default text to be put.
---@field placeholder? string #Placeholder text that will appear if there is no text.
---@field change_callback? function #Callback function when input changes.

---@class TextSanitizerArgs
---@field text string #The text.
---@field placeholder string #The placeholder text that appears if there is no text.
---@field cursor_hide boolean #Hide the cursor.
---@field cursor_pos number #The cursor position.
---@field style InputFieldStyle #Style to be used.
