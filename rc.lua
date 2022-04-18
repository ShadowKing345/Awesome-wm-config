--------------------------------------------------
--
--      Awesome WM config entry point.
--
--------------------------------------------------
pcall(require, "luarocks.loader")

--------------------------------------------------
require "awful.autofocus"
require "awful.hotkeys_popup.keys"

-- Error checking setup.
--------------------------------------------------
require "error-config"

-- Environment variables setup.
--------------------------------------------------
local env = require "env-config" {}
require "layouts-config" (env)
require "ui" (env)

local bindingConfig = require "binding-config" (env)
root.keys(bindingConfig.keys.global)
root.buttons(bindingConfig.mouse.global)

require "rules-config":init { hotkeys = { keys = bindingConfig.keys, mouse = bindingConfig.mouse } }
require "service.pulseMixer" {}
require "signals".init(env)
require "autostart-config".run()
