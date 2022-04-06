-------------------------------------------------
--
--      Input Field Widget
--
--------------------------------------------------
local setmetatable = setmetatable

local awful = require "awful"
local beautiful = require "beautiful"
local gTable = require "gears.table"
local gfs = require "gears.filesystem"
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

---@param args inputFieldNewArgs #Arguments for function.
---@return table #Widget object.
function inputField.new(args)
    args = args or {}
    args.style = gTable.merge(inputField.default_theme(), args.style or {})
    args.prompt_args = args.prompt_args or {}

    local prompt = awful.widget.prompt {
        bg = args.style.bg
    }

    local ret = wibox.widget {
        {
            prompt,
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


    ret:buttons {
        utils.aButton {
            modifiers = {},
            button = 1,
            callback = function()
                ret._private.inputActive = true
                awful.prompt.run {
                    prompt = args.prompt_args.prompt or "",
                    textbox = prompt.widget,
                    completion_callback = args.prompt_args.completion_callback,
                    history_path = args.prompt_args.history_path or gfs.get_cache_dir() .. "/history_inputfield",
                    done_callback = args.prompt_args.done_callback,
                    change_callback = args.prompt_args.change_callback,
                    keypress_callback = args.prompt_args.keypress_callback,
                }
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

                        awful.keygrabber.stop()

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

---@class inputFieldNewArgs
---@field style? InputFieldStyle #Style overwrite.
---@field prompt_args? InputFieldPromptArgs #Arguments for the prompt used.

---@class InputFieldStyle
---@field bg string #Background color.
---@field fg string #Foreground color.
---@field cursor_fg string #Cursor foreground color.
---@field cursor_bg string #Cursor background color.
---@field font string #Font used.
---@field border_width number #Border width.
---@field border_color string #Border color.
---@field shape function #Gears shape function used to create the edge.

---@class InputFieldPromptArgs
---@field prompt? string #The prompt message.
---@field completion_callback? function #Completion callback function.
---@field history_path? string #Path to history file for prompt.
---@field done_callback? function #Callback function for when the prompt is done.
---@field change_callback? function #Callback function for when the input changes.
---@field keypress_callback? function #Callback function for when a key has been pressed.
