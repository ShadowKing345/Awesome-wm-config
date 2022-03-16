pcall(require, "luarocks.loader")

local awful = require "awful"
local beautiful = require "beautiful"
require "awful.autofocus"
require "awful.hotkeys_popup.keys"
require "error-config"

local env = require "env-config"{}
beautiful.init(env.themePath)
awful.layout.layouts = { awful.layout.suit.floating }

local screenConfig = require "screen-config"(env)
awful.screen.connect_for_each_screen(screenConfig.init)

local bindingConfig = require "binding-config"(env)
root.keys(bindingConfig.keys.global)
root.buttons(bindingConfig.mouse.global)

require("rules-config"):init { hotkeys = { keys = bindingConfig.keys, mouse = bindingConfig.mouse } }
require("signals").init(env)
require("autostart-config").run()
