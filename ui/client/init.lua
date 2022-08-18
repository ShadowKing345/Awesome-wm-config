local titlebar = require "ui.client.titlebar"

local M = { mt = {} }

function M:init(args)
    args = args or {}

    titlebar(args)
end

function M.mt:__call(...)
    return M:init(...)
end

return setmetatable(M, M.mt)
