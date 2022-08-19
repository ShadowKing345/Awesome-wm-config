--[[

        Client configuration

]]
--------------------------------------------------
local awful     = require "awful"
local beautiful = require "beautiful"
local titlebar  = require "client.titlebar"

--------------------------------------------------
local M = { mt = {} }

function M:init(args)
    args = args or {}

    args = args or {}

    client.connect_signal("manage", function(c)
        if c.maximized then
            -- I do this to prevent an issue were maximized windows on startup or refresh result in
            -- the titlebar size being added after the window is maximized.
            awful.placement.maximize(c, { honor_workarea = true })
        end
    end)

    titlebar(args)
end

--------------------------------------------------
function M.mt:__call(...)
    return M:init(...)
end

return setmetatable(M, M.mt)
