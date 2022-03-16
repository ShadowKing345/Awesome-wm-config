---@module'gears'
local gears = require "gears"

---@class EnvConfig
---@field terminal string
---@field editor string
---@field editorCmd string
---@field modKey string
---@field themePath string
local env = {metatable = {}}
env.metatable.__index = env

---@class EnvArgs
---@field terminal? string #Name of the terminal application.
---@field editor? string #Name of editor.
---@field modKey? string #Super modifier to be used.
---@field themePath? string #Path to theme.lua file.

---@param args? EnvArgs #Optional arguments for environment configuration.
---@return EnvConfig
function env:new(args)
  args = args or {}
  self = {}
    self.terminal = args.terminal or "kitty"
    self.editor = args.editor or os.getenv "EDITOR" or "nvim"
    self.editorCmd = self.terminal .. "-e" .. self.editor

    self.modKey = args.modKey or "Mod4"

    self.themePath = args.themePath or gears.filesystem.get_xdg_config_home() .. "awesome/" .. "theme/theme.lua"

    return setmetatable(self, self.metatable)
end

---@param args? EnvArgs #Optional arguments for environment configuration.
---@return EnvConfig
function env.metatable:__call(args)
  return env:new(args)
end

---@type EnvConfig
return setmetatable(env, env.metatable)
