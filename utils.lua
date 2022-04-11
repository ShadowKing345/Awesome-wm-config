--------------------------------------------------
--
--      A collection of utility function used throught the project.
--
--------------------------------------------------
local math = math
local pairs = pairs
local type = type
local unpack = unpack or table.unpack

local aButton = require "awful.button"
local aKey = require "awful.key"
local gTable = require "gears.table"

--------------------------------------------------
local utils = { button_names = aButton.names }

---Creates a pretty JSON string from an object recursively.
---*NOTE: Lua tables with array values will have the index of the value be printed as the raw number.
---Eg. {"test"} = {1: "test"}*
---@param tbl table #Table to be turned into a JSON object.
---@param opt TblToJsonOptions #Settings for the parser.
---@return string
function utils.tblToJson(tbl, opt)
    ---@type TblToJsonOptions
    local _opt = gTable.clone(opt or { indent = 4, pretty = true })
    _opt.offset = _opt.indent + (_opt.offset or 0)

    local newChar = _opt.pretty and "\n" or ""
    local iString = _opt.pretty and (" "):rep(_opt.offset) or ""

    local result = "{" .. newChar

    for k, v in pairs(tbl) do
        local t = type(v)
        k = type(k) == "string" and "\"" .. k .. "\"" or k
        result = ("%s%s%s:%s,%s"):format(result, iString, k, (_opt.pretty and " " or "") .. (t == "table" and utils.tblToJson(v, _opt) or (t == "string" and "\"" .. v .. "\"" or tostring(v))), newChar)
    end

    return result:sub(1, (_opt.pretty and -3 or -2)) .. newChar .. (_opt.pretty and (" "):rep(math.max(_opt.offset - _opt.indent, 0)) or "") .. "}"
end

---Clamps a number between two values
---@param number number #The number to be clamped
---@param min number #Minimum number
---@param max number #Maximum number
---@return number
function utils.clamp(number, min, max)
    return math.max(math.min(number, max), min)
end

---Creates a Awful Button table
---@param args AButton
---@return table
function utils.aButton(args)
    return aButton(args.modifiers, args.button, args.press and args.press or args.callback, args.release)
end

---Creates a Awful Key table
---@param arg AKey
---@return table
function utils.aKey(arg)
    return aKey(arg.modifiers, arg.key, arg.callback, arg.description)
end

return utils
--------------------------------------------------
---@class AKey
---@field modifiers string[] #Collection of modifier keys.
---@field key string #The key of the keyboard.
---@field callback function #Function called when key is pressed.
---@field description {description: string, group: string} #Description of the key.

---@class AButton
---@field modifiers string[] #Collection of modifier keys.
---@field button number #The number of mouse button.
---@field callback? fun():nil #Function called when key is pressed.
---@field press? fun():nil #Function called when key is pressed.
---@field release? fun():nil #Function called when key is released.

---@class TblToJsonOptions #Settings for the parser.
---@field offset number #The offset of indent.
---@field indent number #Sets the indent from the left. Use to offset the text.
---@field pretty boolean #If true indents and new lines will be applied. Default: true
