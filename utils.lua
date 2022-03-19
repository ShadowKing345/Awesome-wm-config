local table = table

local awful = require "awful"

local utils = { string = {}, table = {} }

function utils.string.split(s, sep)
    local result = {}

    for match in (s .. sep):gmatch("(.-)" .. sep) do
        table.insert(result, match)
    end

    return result
end

function utils.table.subset(t, i, j)
    local result = {}

    for x = i, j, 1 do
        table.insert(result, t[x])
    end

    return result
end

function utils.tblToJson(tbl, indent, isObj)
    if not indent then
        indent = 0
    end
    if not isObj then
        isObj = false
    end
    local toprint = (isObj and "" or string.rep(" ", indent)) .. "{\n"
    for k, v in pairs(tbl) do
        local kt = type(k)
        local vt = type(v)

        toprint = toprint .. string.rep(" ", indent + 2) .. (kt == "number" and "[" .. k .. "]" or k) .. " = "

        if vt == "table" then
            toprint = toprint .. utils.tblToJson(v, indent + 4, true) .. ",\n"
        else
            toprint = toprint .. (vt == "string" and '"' .. v .. '"' or tostring(v)) .. ",\n"
        end
    end

    toprint = toprint .. string.rep(" ", indent - 2) .. "}"
    return toprint
end

function utils.table.indexOf(tbl, item)
    local i = nil

    for index, value in ipairs(tbl) do
        if item == value then
            i = index
        end
    end

    return i
end

function utils.table.merge(tbl1, tbl2)
    for k, v in pairs(tbl2) do
        tbl1[k] = v
    end
    for i, v in ipairs(tbl2) do
        tbl1[i] = v
    end

    return tbl1
end

---@class AButton
---@field modifiers string[] #Collection of modifier keys.
---@field button number #The number of mouse button.
---@field callback function #Function called when key is pressed.

---Creates a Awful Button Object
---@param args AButton
---@return Object
function utils.aButton(args)
    return awful.button(args.modifiers, args.button, args.callback)
end

---@class AKey
---@field modifiers string[] #Collection of modifier keys.
---@field key string #The key of the keyboard.
---@field callback function #Function called when key is pressed.
---@field description {description: string, group: string} #Description of the key.

---Creates a Awful Key Object
---@param arg AKey
---@return Object
function utils.aKey(arg)
    return awful.key(arg.modifiers, arg.key, arg.callback, arg.description)
end

return utils
