--[[

    Launcher

--]]
--------------------------------------------------
local awful = require "awful"

local menubar = require "menubar"

--------------------------------------------------
---@type KeybindingModule
local M = { groupName = "Launcher" }

function M.keyboard(env)
    return {
        {
            modifiers   = { env.modKey },
            key         = "Return",
            callback    = function()
                awful.spawn(env.terminal)
            end,
            description = "Opens a terminal",
        },
        {
            modifiers   = { env.modKey },
            key         = "p",
            callback    = function()
                menubar.show()
            end,
            description = "Opens application launcher",
        },
    }
end

--------------------------------------------------
return M
