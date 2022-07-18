--[[

    Mouse and Keybindings configurations

--]]
--------------------------------------------------
local awful  = require "awful"
local gTJoin = require "gears.table".join

local utils   = require "utils"
local aKey    = utils.aKey
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
---@return BindingConfig
function M:new(env)
    env = env or {}

    self.keys = {
        global = {},
        client = {},
    }

    for name, module in pairs(modules) do
        if module.keyboard then
            local keys = {}
            for _, key in ipairs(module.keyboard(env)) do
                table.insert(keys, aKey {
                    modifiers   = key.modifiers,
                    key         = key.key,
                    callback    = key.callback,
                    description = { description = key.description, group = module.groupName or name },
                })
            end
            self.keys.global = gTJoin(self.keys.global, table.unpack(keys))
        end

        if module.client then
            local keys = {}
            for _, key in ipairs(module.client(env)) do
                table.insert(keys, aKey {
                    modifiers   = key.modifiers,
                    key         = key.key,
                    callback    = key.callback,
                    description = { description = key.description, group = module.groupName or name },
                })
            end
            self.keys.client = gTJoin(self.keys.client, table.unpack(keys))
        end
    end

    self.mouse = {
        global = gTJoin(
            aButton { modifiers = {}, button = 4, callback = awful.tag.viewnext },
            aButton { modifiers = {}, button = 5, callback = awful.tag.viewprev }
        ),
        client = gTJoin(
            aButton {
                modifiers = {},
                button    = 1,
                callback  = function(c) c:emit_signal("request::activate", "mouse_click", { raise = true }) end,
            },
            aButton {
                modifiers = { env.modKey },
                button    = 1,
                callback  = function(c)
                    c:emit_signal("request::activate", "mouse_click", { raise = true })
                    awful.mouse.client.move(c)
                end,
            },
            aButton {
                modifiers = {},
                button    = 3,
                callback  = function(c) c:emit_signal("request::activate", "mouse_click", { raise = true }) end,
            },
            aButton {
                modifiers = { env.modKey },
                button    = 3,
                callback  = function(c)
                    c:emit_signal("request::activate", "mouse_click", { raise = true })
                    awful.mouse.client.resize(c)
                end,
            }
        ),
    }

    return self
end

--------------------------------------------------
function M.mt:__call(env)
    return M:new(env)
end

return setmetatable(M, M.mt)
--------------------------------------------------

---@class KeybindingModule #Class definition for a keybinding module.
---@field keyboard? function(env:EnvConfig):Keybinding[] #Function that generates the keyboard bindings.
---@filed client? function(env:EnvConfig):Keybinding[] #Function that generates the client bindings.
---@field groupName string #Name of the group.

---@class Keybinding #Class defining a keybinding.
---@field modifiers string[] #Collection of all the modifiers to be pressed.
---@field key string #The key to be pressed.
---@field callout function #Function to be called when the key is pressed.
---@field description string #The description of what the key does.
