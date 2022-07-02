--------------------------------------------------
--
--      Awesome WM config entry point.
--
--------------------------------------------------
pcall(require, "luarocks.loader")

--------------------------------------------------
local awful = require "awful"
require "awful.autofocus"
require "awful.hotkeys_popup.keys"

-- Error checking setup.
--------------------------------------------------
require "error-config"

-- Environment variables setup.
--------------------------------------------------
local env = require "env-config" ()
require "layouts-config" (env)
local screenConfig = require "ui.screen-config" (env)
awful.screen.connect_for_each_screen(screenConfig.init)

local keybindings = require "keybindings" (env)
root.keys(keybindings.keys.global)
root.buttons(keybindings.mouse.global)

require "rules-config":init { hotkeys = { keys = keybindings.keys, mouse = keybindings.mouse } }
require "service.pulseMixer" {}
require "signals".init(env)
require "autostart-config".run()
