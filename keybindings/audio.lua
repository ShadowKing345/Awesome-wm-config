--[[

    Audio Keybindings.

--]]
--------------------------------------------------
---@type KeybindingModule
local M = { groupName = "Audio" }

function M.keyboard(env)
    env = env or {}
    local service = env.pulseaudio_service

    if not service then
        return {}
    end

    return {
        {
            modifiers   = {},
            key         = "XF86AudioMute",
            press       = function() service:mute { mode = service.PAS_MUTE_MODES.TOGGLE } end,
            description = "Toggle Mute",
        },
        {
            modifiers   = {},
            key         = "XF86AudioRaiseVolume",
            press       = function() service:volume { amount = 1, delta = true, type = "sink" } end,
            description = "Raise Volume",
        },
        {
            modifiers   = {},
            key         = "XF86AudioLowerVolume",
            press       = function() service:volume { amount = -1, delta = true, type = "sink" } end,
            description = "Lower Volume",
        },
    }
end

--------------------------------------------------
return M
