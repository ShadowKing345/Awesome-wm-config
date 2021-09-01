local awful = require("awful")
local redflat = require("redflat")
local beautiful = require("beautiful")

local binaryTreeLayout = require("layouts.binary-tree-layout")

local client = client

local layouts = {}

function layouts:init()
    local layset = {
      binaryTreeLayout:build({})
    }

    awful.layout.layouts = layset
end

-- advance layout settings
redflat.layout.map.notification = true
redflat.layout.map.notification_style = {icon = redflat.util.table.check(beautiful, "widget.layoutbox.icon.usermap")}

-- layout handler for grid (replace if different handler wanted)
client.disconnect_signal("request::geometry", awful.layout.move_handler)
client.connect_signal("request::geometry", redflat.layout.common.mouse.move)

return layouts