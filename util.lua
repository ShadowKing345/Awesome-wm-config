local string = string
local table = table

local util = { string = {}, table = {} }

function util.string.split(s, sep)
    local result = {}

    for match in (s .. sep):gmatch("(.-)"..sep) do
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

function util.print_table(t)
    local text = ""
    for k, v in pairs(t) do
       text = text .. tostring(k) .. "=" .. tostring(v) .. "\n"
    end

    print(text)
end

return util