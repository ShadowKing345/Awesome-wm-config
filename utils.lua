--------------------------------------------------
--
--      A collection of utility function used throught the project.
--
--------------------------------------------------
local math  = math
local pairs = pairs
local type  = type

local aButton = require "awful.button"
local aKey    = require "awful.key"

--------------------------------------------------
local utils = { button_names = aButton.names }

---Creates a pretty JSON string from an object recursively.
---*Note: All array objects enter a $Array Field instead due to how lua combines dictionarys and arrays.*
---@param tbl table #Table to be turned into a JSON object.
---@param depth number #How far in we are.
---@param indent number #Sets the indent from the left. Use to offset the text.
---@param pretty boolean #If true indents and new lines will be applied. Default: true
---@return string
function utils.tblToJson(tbl, pretty, indent, depth)
    pretty = pretty or false
    indent = (indent or 2) * (pretty and 1 or 0)
    depth  = depth or 1

    local array, hasItem, keys = {}, false, {}

    for k, v in pairs(tbl) do
        local vType = type(v)
        if type(k) == "number" then
            if vType == "table" then
                table.insert(array, utils.tblToJson(v, pretty, indent, depth + 1))
            elseif vType == "string" then
                table.insert(array, "\"" .. v .. "\"")
            else
                table.insert(array, tostring(v))
            end
        else
            hasItem = true
            local prefix = "\"" .. tostring(k) .. "\": "
            if vType == "table" then
                table.insert(keys, prefix .. utils.tblToJson(v, pretty, indent, depth + 1))
            elseif vType == "string" then
                table.insert(keys, prefix .. "\"" .. v .. "\"")
            else
                table.insert(keys, prefix .. tostring(v))
            end
        end
    end

    local prettyStr = pretty and "\n" or ""
    local indentStr = (" "):rep(indent * depth)
    local prefixIndent = (" "):rep(indent * math.max(depth - 1, 0))

    local result = prefixIndent .. "{" .. prettyStr

    if #array > 0 then
        local arrayIndent = (" "):rep(indent * depth * 2)
        result = result .. indentStr .. "$Array: [" .. prettyStr
        result = result .. arrayIndent .. table.concat(array, "," .. prettyStr .. arrayIndent) .. prettyStr
        result = result .. indentStr .. "]"
        if hasItem then
            result = result .. ","
        end
        result = result .. prettyStr
    end

    if #keys > 0 then
        result = result .. indentStr .. table.concat(keys, "," .. prettyStr .. indentStr) .. prettyStr
    end

    return result .. prefixIndent .. "}"
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
