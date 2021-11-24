local awful = require("awful")
local binaryTreeLayout = require("layouts.binary-tree-layout")

local layouts = {}

function layouts:init()
  local layset = {binaryTreeLayout:build({})}

  awful.layout.layouts = layset
end


return layouts
