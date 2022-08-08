--[[

    Mouse and Keybindings configurations

--]]
--------------------------------------------------
local awful = require "awful"

local utils   = require "utils"
local aButton = utils.aButton

---@type KeybindingModule[]
local modules = {
    audio    = require "keybindings.audio",
    awesome  = require "keybindings.awesome",
    client   = require "keybindings.client",
    launcher = require "keybindings.launcher",
    layout   = require "keybindings.layout",
    movement = require "keybindings.movement",
    tags     = require "keybindings.tags",
}

--------------------------------------------------
---@class BindingConfig
---@field keys table
---@field button table
local M = { mt = {} }

---@param env EnvConfig #The environment configurations.
function M:new(env)
    env = env or {}

    self.global = { keyboard = {}, mouse = {
        aButton { modifiers = {}, button = 4, callback = awful.tag.viewnext },
        aButton { modifiers = {}, button = 5, callback = awful.tag.viewprev }
    } }
    self.client = { keyboard = {}, mouse = {
        aButton {
            modifiers = {},
            button    = 1,
            callback  = function(c) c:activate { context = "mouse_click" } end,
        },
        aButton {
            modifiers = { env.modKey },
            button    = 1,
            callback  = function(c) c:activate { context = "mouse_click", action = "mouse_move", } end,
        },
        aButton {
            modifiers = {},
            button    = 3,
            callback  = function(c) c:activate { context = "mouse_click" } end,
        },
        aButton {
            modifiers = { env.modKey },
            button    = 3,
            callback  = function(c) c:activate { context = "mouse_click", action = "mouse_resize", } end,
        }
    } }

    for name, m in pairs(modules) do
        if m.keyboard then
            ---@type Keybinding[]
            local keybindings = m.keyboard(env)
            for _, key in ipairs(keybindings) do
                table.insert(self.global.keyboard,
                    awful.key(
                        key.modifiers,
                        key.key,
                        key.press or function() end,
                        key.release or function() end,
                        { description = key.description, group = name }
                    )
                )
            end
        end

        if m.client then
            ---@type Keybinding[]
            local keybindings = m.client(env)
            for _, key in ipairs(keybindings) do
                table.insert(self.client.keyboard,
                    awful.key(
                        key.modifiers,
                        key.key,
                        key.press or function() end,
                        key.release or function() end,
                        { description = key.description, group = name }
                    )
                )
            end
        end
    end

    awful.keyboard.append_global_keybindings(self.global.keyboard)
    awful.mouse.append_global_mousebindings(self.global.mouse)

    client.connect_signal("request::default_keybindings", function()
        awful.keyboard.append_client_keybindings(self.client.keyboard)
    end)

    client.connect_signal("request::default_keybindings", function()
        awful.mouse.append_client_mousebindings(self.client.mouse)
    end)
end

--------------------------------------------------
function M.mt:__call(env)
    return M:new(env)
end

return setmetatable(M, M.mt)
--------------------------------------------------

---@class KeybindingModule #Class definition for a keybinding module.
---@field keyboard? function(env:EnvConfig):Keybinding[] #Function that generates the keyboard bindings.
---@field client? function(env:EnvConfig):Keybinding[] #Function that generates the keyboard bindings.
---@field groupName string #Name of the group.

---@class Keybinding #Class defining a keybinding.
---@field modifiers string[] #Collection of all the modifiers to be pressed.
---@field key string #The key to be pressed.
---@field press function #Function to be called when the key is pressed.
---@field release function #Function to be called when the key is pressed.
---@field description string #The description of what the key does.
