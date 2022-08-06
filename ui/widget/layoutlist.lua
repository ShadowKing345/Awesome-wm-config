--[[

    Layout list similar to awful.layoutlist but allows for stylesheets.

]]
--------------------------------------------------
local M = { mt = {} }

--Todo:
--[[

[ ]: Allow for scrolling through the list with the scroll wheel.

[icon]: name

--]]

function M:new(args)

end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
