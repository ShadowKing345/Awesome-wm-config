--[[

    Client

--]]
--------------------------------------------------
local awful = require "awful"

local utils = require "keybindings.utils"

--------------------------------------------------
---@type KeybindingModule
local M = { groupName = "Client" }

local function clientResize(c, dir, push)
    if c.floating then
        return
    end

    local layout = utils.getCurrentLayout(c)
    if layout and layout.name == "binaryTreeLayout" then
        layout.resize(c, 5 * (push and -1 or 1), dir)
    end
end

function M.keyboard(env)
    return {
        {
            modifiers   = { env.modKey, utils.keys.clt },
            key         = "n",
            press       = function()
                local c = awful.client.restore()
                if c then
                    c:emit_signal("request::activate", "key.unminimize", { raise = true })
                end
            end,
            description = "Restore minimized",
        },
    }
end

function M.client(env)
    return {
        {
            modifiers   = { utils.keys.alt },
            key         = "F4",
            press       = function(c) c:kill() end,
            description = "Kill application",
        },
        {
            modifiers   = { env.modKey },
            key         = "f",
            press       = function(c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            description = "Toggle fullscreen",
        },
        {
            modifiers   = { env.modKey, utils.keys.shift },
            key         = "f",
            press       = awful.client.floating.toggle,
            description = "Toggle floating",
        },
        {
            modifiers   = { env.modKey },
            key         = "t",
            press       = function(c) c.ontop = not c.ontop end,
            description = "Toggle keep on top",
        },
        {
            modifiers   = { env.modKey },
            key         = "n",
            press       = function(c) c.minimized = true end,
            description = "Minimize",
        },
        {
            modifiers   = { env.modKey },
            key         = "m",
            press       = function(c)
                c.maximized = not c.maximized
                c:raise()
            end,
            description = "(Un)maximize",
        },
        {
            modifiers   = { env.modKey },
            key         = "o",
            press       = function(c) c:move_to_screen() end,
            description = "Move to next screen",
        },
        {
            modifiers = { env.modKey, utils.keys.clt, },
            key = "t",
            press = awful.titlebar.toggle,
            description = "Toggles the titlebar for the focused client",
        },

        {
            modifiers = { env.modKey, utils.keys.shift },
            key = "h",
            press = function(c) clientResize(c, "left") end,
            description = "Push left",
        },
        {
            modifiers = { env.modKey, utils.keys.shift, utils.keys.clt },
            key = "h",
            press = function(c) clientResize(c, "left", true) end,
            description = "Pull left",
        },

        {
            modifiers = { env.modKey, utils.keys.shift },
            key = "l",
            press = function(c) clientResize(c, "right") end,
            description = "Push right",
        },
        {
            modifiers = { env.modKey, utils.keys.shift, utils.keys.clt },
            key = "l",
            press = function(c) clientResize(c, "right", true) end,
            description = "Pull right",
        },

        {
            modifiers = { env.modKey, utils.keys.shift },
            key = "k",
            press = function(c) clientResize(c, "up") end,
            description = "Push up",
        },
        {
            modifiers = { env.modKey, utils.keys.shift, utils.keys.clt },
            key = "k",
            press = function(c) clientResize(c, "up", true) end,
            description = "Pull up",
        },

        {
            modifiers = { env.modKey, utils.keys.shift },
            key = "j",
            press = function(c) clientResize(c, "down") end,
            description = "Push down",
        },
        {
            modifiers = { env.modKey, utils.keys.shift, utils.keys.clt },
            key = "j",
            press = function(c) clientResize(c, "down", true) end,
            description = "Pull down",
        },
    }
end

--------------------------------------------------
return M
