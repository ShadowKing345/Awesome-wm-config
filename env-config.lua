--------------------------------------------------
--
--      Environment configuration setup.
--
--------------------------------------------------
local setmetatable = setmetatable

local beautiful = require "beautiful"
local gears = require "gears"

local keybindingUtils = require "keybindings.utils"

--------------------------------------------------
---@class EnvConfig
---@field terminal string #Name of terminal application
---@field editor string #Name of editor
---@field editorCmd string #Full application call for editor.
---@field modKey string #Super modifiter.
---@field themePath string #Path to theme.lua file for beautiful setup.
---@field tags string[] #Names for tags to be used.
local env = { mt = {} }

---@return EnvConfig
function env:new()
    self.terminal = "kitty"
    self.editor = os.getenv "EDITOR" or "nvim"
    self.editorCmd = self.terminal .. "-e" .. self.editor

    self.modKey = keybindingUtils.keys.super

    self.themePath = gears.filesystem.get_xdg_config_home() .. "awesome/theme/theme.lua"

    beautiful.init(env.themePath)

    return self
end

--------------------------------------------------
function env.mt:__call()
    return env:new()
end

return setmetatable(env, env.mt)
