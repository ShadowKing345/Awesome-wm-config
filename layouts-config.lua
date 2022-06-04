--[[

      Layouts configuration

]]
local setmetatable = setmetatable

local awful = require "awful"

local binaryTreeLayout = require "binary-tree-layout"

--------------------------------------------------
---@class LayoutConfiguration
---@field layouts table Contains all set layouts.
local layoutConfiguration = { mt = {} }

function layoutConfiguration:new(_)
    self.layouts = {
        binaryTreeLayout {},
        awful.layout.suit.floating,
    }

    awful.layout.layouts = self.layouts

    return self
end

--------------------------------------------------
function layoutConfiguration.mt:__call(...)
    return layoutConfiguration:new(...)
end

return setmetatable(layoutConfiguration, layoutConfiguration.mt)
