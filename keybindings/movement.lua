--[[

    Window movement and sizing configs.

--]]
--------------------------------------------------
local awful = require "awful"

local utils = require "keybindings.utils"

--------------------------------------------------
---@type KeybindingModule
local M = { groupName = "Movement" }

local function focusSwitchByDir(dir)
    return function()
        awful.client.focus.global_bydirection(dir)
        if client.focus then
            client.focus:raise()
        end
    end
end

local function moveFloatingClient(c, dir)
    if not c.floating then
        return
    end

    local amount = 15
    if dir == "left" or dir == "up" then
        amount = amount * -1
    end


    if dir == "left" or dir == "right" then
        dir = "x"
    elseif dir == "up" or dir == "down" then
        dir = "y"
    else
        return
    end

    c[dir] = c[dir] + amount

    awful.placement.no_offscreen(c)
end

local function clientResize(c, dir, shrink)
    if not c.floating then
        return
    end

    if dir ~= "width" and dir ~= "height" then
        return
    end

    local amount = 15
    if shrink then
        amount = amount * -1
    end

    c[dir] = c[dir] + amount
    awful.placement.no_offscreen(c)
end

function M.keyboard(env)
    return {
        {
            modifiers   = { env.modKey },
            key         = "l",
            callback    = focusSwitchByDir "right",
            description = "Go to rigth client.",
        },
        {
            modifiers   = { env.modKey },
            key         = "h",
            callback    = focusSwitchByDir "left",
            description = "Go to left client."
        },
        {
            modifiers   = { env.modKey },
            key         = "k",
            callback    = focusSwitchByDir "up",
            description = "Go to upper client."
        },
        {
            modifiers   = { env.modKey },
            key         = "j",
            callback    = focusSwitchByDir "down",
            description = "Go to lower client."
        },
    }
end

function M.client(env)
    return {
        {
            modifiers   = { env.modKey, utils.keys.shift },
            key         = "h",
            callback    = function(c) moveFloatingClient(c, "left") end,
            description = "Moves client to the left.",
        },
        {
            modifiers   = { env.modKey, utils.keys.shift },
            key         = "j",
            callback    = function(c) moveFloatingClient(c, "down") end,
            description = "Moves client to the down.",
        },
        {
            modifiers   = { env.modKey, utils.keys.shift },
            key         = "k",
            callback    = function(c) moveFloatingClient(c, "up") end,
            description = "Moves client to the up.",
        },
        {
            modifiers   = { env.modKey, utils.keys.shift },
            key         = "l",
            callback    = function(c) moveFloatingClient(c, "right") end,
            description = "Moves client to the right.",
        },

        {
            modifiers   = { env.modKey, utils.keys.shift, utils.keys.clt },
            key         = "l",
            callback    = function(c) clientResize(c, "width", false) end,
            description = "Grows client width.",
        },
        {
            modifiers   = { env.modKey, utils.keys.shift, utils.keys.clt },
            key         = "h",
            callback    = function(c) clientResize(c, "width", true) end,
            description = "Shrinks client width.",
        },
        {
            modifiers   = { env.modKey, utils.keys.shift, utils.keys.clt },
            key         = "j",
            callback    = function(c) clientResize(c, "height", false) end,
            description = "Grows client height.",
        },
        {
            modifiers   = { env.modKey, utils.keys.shift, utils.keys.clt },
            key         = "k",
            callback    = function(c) clientResize(c, "height", true) end,
            description = "Shrinks client height.",
        },
    }
end

--------------------------------------------------
return M
