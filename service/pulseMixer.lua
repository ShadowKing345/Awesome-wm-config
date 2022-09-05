--[[

        Pulse Mixer Service.
        Please note that this does not update if the volume changes externally.

]]
--------------------------------------------------
local awful   = require "awful"
local gTable  = require "gears.table"
local naughty = require "naughty"

local pulseaudio = require "modules".pulseaudio
local utils      = require "utils"
local cmdf       = "%s %s %s"

--------------------------------------------------
---Service for querying and controlling PulseAudio using pulsemixer commands.
---@class PulseMixerService
---@field objects PulseObject[] #Collection of pulse objects.
---@field types PulseTypes #Tells the service what is the name of an output.
local M = {
    mt       = {},
    objects  = {},
    commands = {
        cmd          = "pulsemixer",
        list         = "-l",
        id           = "--id %s",
        getMuted     = "--get-mute",
        mute         = "--mute",
        unmute       = "--unmute",
        toggleMute   = "--toggle-mute",
        changeVolume = "--change-volume %d",
        getVolume    = "--get-volume",
        setVolume    = "--set-volume %d",
    },
    types    = {
        input = "Source",
        output = "Sink",
    },
}

---Gets or sets the current volumes for all channels.
---Returns an empty array if none was found or the new volumes if they are set.
---@param args VolumeArgs #Arguments for this method.
---@return number[]
function M:volume(args)
    args         = args or {}
    local object = nil

    if not object then
        return {}
    end

    if not args.amount then
        return object.volumes
    end

    local cmd
    if type(args.delta) == "nil" then
        for i, _ in ipairs(object.volumes) do
            object.volumes[i] = args.amount
        end
        cmd = self.commands.setVolume
    else
        for i, v in ipairs(object.volumes) do
            object.volumes[i] = utils.clamp(v + args.amount, 0, 0)
        end
        cmd = self.commands.changeVolume
    end

    awful.spawn.with_shell(cmdf:format(self.commands.cmd, self.commands.id:format(object.id), cmd:format(args.amount)))
    return object.volumes
end

---Gets or sets if the PulseObject is muted or not.
---Returns nil if none was found or the new state.
---@param args MuteArgs #Arguments for this method.
---@return boolean | nil
function M:mute(args)
    args         = args or {}
    local object = nil

    if not object then
        return
    end

    if not args.toggle then
        return object.muted
    end

    local cmd
    if type(args.forceState) == "boolean" then
        object.muted = args.forceState
        cmd = object.muted and self.commands.mute or self.commands.unmute
    else
        object.muted = not object.muted
        cmd = self.commands.toggleMute
    end


    awful.spawn.with_shell(cmdf:format(self.commands.cmd, self.commands.id:format(object.id), cmd))
    return object.muted
end

---Initalize sources and sinks.
function M:init()
end

---Creates a new pulseMixer service instance.
---@param args PulseMixerServiceArgs
---@return PulseMixerService
function M:new(args)
    args = args or {}

    if args.commands then
        self.commands = gTable.merge(self.commands, args.commands)
    end

    if args.types then
        self.types = gTable.merge(self.types, args.types)
    end

    self:init()
    return self
end

--------------------------------------------------
---Creates a new pulseMixer service instance.
---@param args PulseMixerServiceArgs
---@return PulseMixerService
function M.mt:__call(args)
    return M:new(args)
end

return setmetatable(M, M.mt)
--------------------------------------------------

---The input output type names for PulseAudio.
---Note we dont care about sink input or source output just if it's a input or output.
---@class PulseTypes
---@field output string #The output name. (Default: Sink)
---@field input string #The input name. (Default: Source)

---Defines a PulseAudioObject.
---@class PulseObject
---@field id string #Id of source/sink.
---@field name string #Name of source/sink.
---@field muted boolean #Is source/sink muted.
---@field channels number #Number of channels.
---@field volumes number[] #Collection of all the channel volumes.
---@field output boolean #Says if this is an output.
---@field default boolean #Is source/sink the default.

---Arguments for pulsemixer service.
---@class PulseMixerServiceArgs
---@field commands PulseCommands #List of commands prefixes. Used to overwrite the default ones.
---@field types PulseTypes #What are the pulse types. Use this to overwrite the default names.

---Commands for the pulsemixer bash command.
---@class PulseCommands
---@field cmd string #Main command *default "pulsemixer"*
---@field list string #Lists all the sources and sinks.
---@field id string #Flag for id that accepts a string *default "--id %s"*
---@field getMute string #Flag for getting the muted state *default "--get-mute"*
---@field mute string #Flag to mute *default "--mute"*
---@field unmute string #Flag to unmute *default "--unmute"*
---@field toggleMute string #Flag to toggle mute *default "--toggle-mute"*
---@field changeVolume string #Flag to change volume by numbered amount *default "--change-volume %d"*
---@field getVolume string #Flag to get all volumes *default "--get-volume"*
---@field setVolume string #Flag to set volumes *default "--set-volume"*

---Arguments for the volume method.
---@class VolumeArgs
---@field id string? #Id for PulseObject.
---@field amount number? #Amount to set the volume to be.
---@field delta boolean? #Sets amount to be a difference of the current volume.

---Arguments for the mute method.
---@class MuteArgs
---@field id string? #Id of source or sink.
---@field toggle boolean? #Should the state be toggled.
---@field forceState boolean? #Forces the state to be this value.
