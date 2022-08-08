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
            press       = function() pulseMixer:toggleMute() end,
            description = "Toggle Mute",
        },
        {
            modifiers   = {},
            key         = "XF86AudioRaiseVolume",
            press       = function() pulseMixer:changeVolume(1) end,
            description = "Raise Volume",
        },
        {
            modifiers   = {},
            key         = "XF86AudioLowerVolume",
            press       = function() pulseMixer:changeVolume(-1) end,
            description = "Lower Volume",
        },
    }
end

--------------------------------------------------
return M
