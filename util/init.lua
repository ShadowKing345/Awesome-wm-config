local table = table

local util = { string = {}, table = {} }

function util.string.split(s, sep)
    local result = {}

    for match in (s .. sep):gmatch("(.-)" .. sep) do
        table.insert(result, match)
    end

    return result
end

function util.table.subset(t, i, j)
    local result = {}

    for x = i, j, 1 do
        table.insert(result, t[x])
    end

    return result
end

function util.tblToJson(tbl, indent, isObj)
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
            toprint = toprint .. util.tblToJson(v, indent + 4, true) .. ",\n"
        else
            toprint = toprint .. (vt == "string" and '"' .. v .. '"' or tostring(v)) .. ",\n"
        end
    end

    toprint = toprint .. string.rep(" ", indent - 2) .. "}"
    return toprint
end

function util.table.indexOf(tbl, item)
    local i = nil

    for index, value in ipairs(tbl) do
        if item == value then
            i = index
        end
    end

    return i
end

function util.table.merge(tbl1, tbl2)
    for k, v in pairs(tbl2) do
        tbl1[k] = v
    end
    for i, v in ipairs(tbl2) do
        tbl1[i] = v
    end

    return tbl1
end

return util
