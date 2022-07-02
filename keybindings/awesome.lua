--[[

    Awesome WM keybindings

--]]
--------------------------------------------------
local hotkeysPopup = require "awful.hotkeys_popup"

local utils = require "keybindings.utils"

--------------------------------------------------
---@type KeybindingModule
local M = { groupName = "Awesome" }

function M.keyboard(env)
    return {
        {
            modifiers   = { env.modKey, utils.keys.clt },
            key         = "r",
            callback    = awesome.restart,
            description = "Reload Awesome",
        },
        {
            modifiers   = { env.modKey, utils.keys.shift },
            key         = "q",
            callback    = awesome.quit,
            description = "Quit Awesome",
        },
        {
            modifiers   = { env.modKey },
            key         = "s",
            callback    = hotkeysPopup.show_help,
            description = "Show help",
        },
    }
end

--------------------------------------------------
return M
