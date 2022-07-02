--[[

    Audio Keybindings.

--]]
--------------------------------------------------
local pulseMixer = require "service.pulseMixer"

--------------------------------------------------
---@type KeybindingModule
local M = { groupName = "Audio" }

function M.keyboard(_)
    return {
        {
            modifiers   = {},
            key         = "XF86AudioMute",
            callback    = function() pulseMixer:toggleMute() end,
            description = "Toggle Mute",
        },
        {
            modifiers   = {},
            key         = "XF86AudioRaiseVolume",
            callback    = function() pulseMixer:changeVolume(1) end,
            description = "Raise Volume",
        },
        {
            modifiers   = {},
            key         = "XF86AudioLowerVolume",
            callback    = function() pulseMixer:changeVolume(-1) end,
            description = "Lower Volume",
        },
    }
end

--------------------------------------------------
return M
