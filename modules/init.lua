local M = {
    pulseaudio = {
        get_object = function(args) return args.type == "all" and {} or nil end,
        set_volume = function() return false end,
        mute_object = function() return false end,
    },
}

return M
