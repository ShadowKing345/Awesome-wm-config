--------------------------------------------------
--
--      Environment configuration setup.
--
--------------------------------------------------
local beautiful = require "beautiful"
local gears = require "gears"

---@class EnvConfig
---@field terminal string #Name of terminal application
---@field editor string #Name of editor
---@field editorCmd string #Full application call for editor.
---@field modKey string #Super modifiter.
---@field themePath string #Path to theme.lua file for beautiful setup.
---@field tags string[] #Names for tags to be used.
local env = { mt = {} }

---@class EnvArgs
---@field terminal? string #Name of the terminal application.
---@field editor? string #Name of editor.
---@field modKey? string #Super modifier to be used.
---@field themePath? string #Path to theme.lua file.

---@param args? EnvArgs #Optional arguments for environment configuration.
---@return EnvConfig
function env:new(args)
    args = args or {}
    self.terminal = args.terminal or "kitty"
    self.editor = args.editor or os.getenv "EDITOR" or "nvim"
    self.editorCmd = self.terminal .. "-e" .. self.editor

    self.modKey = args.modKey or "Mod4"

    self.themePath = args.themePath or gears.filesystem.get_xdg_config_home() .. "awesome/" .. "theme/theme.lua"

    beautiful.init(env.themePath)

    return setmetatable(self, self.mt)
end

--------------------------------------------------
-- Metadata setup
--------------------------------------------------
function env.mt:__call(args)
    return env:new(args)
end

return setmetatable(env, env.mt)

--------------------------------------------------
-- EoF
--------------------------------------------------
