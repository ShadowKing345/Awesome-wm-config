--[[

        Environment configuration setup.

]]
--------------------------------------------------
local setmetatable = setmetatable

local awful     = require "awful"
local beautiful = require "beautiful"

local binaryTreeLayout = require "binary-tree-layout"
local keybindingUtils  = require "keybindings.utils"
local theme            = require "theme"

--------------------------------------------------
---@class EnvConfig
---@field terminal string #Name of terminal application
---@field editor string #Name of editor
---@field editorCmd string #Full application call for editor.
---@field modKey string #Super modifiter.
---@field themePath string #Path to theme.lua file for beautiful setup.
---@field tags string[] #Collection of names to be used for the tags.
---@field layouts table #Collection of layouts to be used.
local env = { mt = {} }

---@return EnvConfig
function env:new()
    self.terminal = "kitty"
    self.editor = os.getenv "EDITOR" or "nvim"
    self.editorCmd = self.terminal .. "-e" .. self.editor

    self.modKey = keybindingUtils.keys.super

    self.tags = { "1", "2", "3", "4", "5", "6" }
    self.layouts = {
        binaryTreeLayout {},
        awful.layout.suit.floating,
    }

    self.rules = {
        { rule = { class = "discord" }, properties = { tag = "3", screen = 1, maximized = true } }, -- discord
    }

    beautiful.init(theme())

    return self
end

--------------------------------------------------
function env.mt:__call()
    return env:new()
end

return setmetatable(env, env.mt)
