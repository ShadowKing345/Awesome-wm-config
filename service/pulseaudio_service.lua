--[[

        Pulse Mixer Service.
        Please note that this does not update if the volume changes externally.

]]
--------------------------------------------------
local awful   = require "awful"
local gTable  = require "gears.table"
local naughty = require "naughty"

local pulseaudio = require "modules".pulseaudio

--------------------------------------------------
---Service midleware for managing pulseaudio related functions.
---@class PulseAudioService
---Collection of pulse objects.
---@field objects {sink: PAObject[], source: PAObject[], sink_input: PAObject[], source_ouput: PAObject[]}
local M = {
    mt      = {},
    objects = {},
}

---Gets or sets the current volumes for all channels.
---Returns an nil if nothing could be done else the new volume.
---@param args PASVolumeArgs #Arguments for this method.
---@return number | nil
function M:volume(args)
    for _, v in pairs(self.objects.sink or {}) do
        if v.default then
            return v.volume
        end
    end

    return nil
end

---Gets or sets if the PulseObject is muted or not.
---Returns nil if none was found or the new state.
---@param args PASMuteArgs #Arguments for this method.
---@return boolean | nil
function M:mute(args)
end

---Initalize sources and sinks.
function M:init()
    if not pulseaudio then
        naughty.notification {
            title   = "Pulseaudio could not be found",
            text    = "Could not find pulseaudio module. Are you sure you followed the setup instructions?",
            urgency = "critical",
        }
        return
    end

    self.objects = pulseaudio.get { type = "all" }
end

---Creates a new pulseMixer service instance.
---@param args PASArgs
---@return PulseAudioService
function M:new(args)
    args = args or {}

    self:init()
    return self
end

--------------------------------------------------
---Creates a new pulseMixer service instance.
---@param args PASArgs
---@return PulseAudioService
function M.mt:__call(args)
    return M:new(args)
end

return setmetatable(M, M.mt)
--------------------------------------------------

---Defines a PulseAudioObjectApplication
---@class PAObjectApplication
---@field name string #Name of the application.
---@field id string #Program id of the application.
---@field binary string #The binary name.

---Defines a PulseAudioObject.
---@class PAObject
---@field index string #Id of source/sink.
---@field name string #Name of source/sink.
---@field muted boolean #Is source/sink muted.
---@field channels number #Number of channels.
---@field volumes number[] #Collection of all the channel volumes.
---@field default boolean #Is source/sink the default.

---Arguments for pulsemixer service.
---@class PASArgs

---Arguments for the volume method.
---@class PASVolumeArgs
---@field id string? #Id for PulseObject.
---@field amount number? #Amount to set the volume to be.
---@field delta boolean? #Sets amount to be a difference of the current volume.

---Arguments for the mute method.
---@class PASMuteArgs
---@field id string? #Id of source or sink.
---@field toggle boolean? #Should the state be toggled.
---@field forceState boolean? #Forces the state to be this value.
