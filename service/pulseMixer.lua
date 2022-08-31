--[[

      Pulse Mixer API mapper

]]
--------------------------------------------------
local awful   = require "awful"
local gTable  = require "gears.table"
local naughty = require "naughty"

local utils = require "utils"

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
        setVolumeAll = "--set-volume-all ",
        maxVolume    = "--max-volume %d",
    },
    types    = {
        input = "Source",
        output = "Sink",
    },
}

---Changes the volume of a source/sink by a delta amount.
---@param amount number #The amount to change by.
---@param id? string #Id for source/sink.
function M:changeVolume(amount, id)
end

---Sets the volume to a given amount.
---Having an array of ammounts will change for each unique channel in order.
---@param amounts number|number[] #The ammount/amounts to change for each volume channel.
---@param id string #Id for source/sink
function M:setVolume(amounts, id)
end

---Gets the current volumes for all channels.
---Returns an empty array if none was found.
---@param id string #Id for source/sink.
---@return number[]
function M:getVolume(id)
end

---Gets the current muted state
---@param id? string #Id of source or sink.
---@return boolean|nil
function M:muted(id)
end

---Mutes a source or sink
---@param id? string #Id of source or sink
function M:mute(id)
end

---Unmutes a source or sink
---@param id? string #Id of source or sink
function M:unmute(id)
end

---Toggles mutes a source or sink
---@param id? string #Id of source or sink
function M:toggleMute(id)
end

---Sets the default sink/source used.
---@param id string #Id of source/sink
function M:setDefault(id)
end

---Sets the maximum volume.
---Note this is just a wrapper method for the flag  of the same name. I have no idea what it is doing behind the scenes.
---@param amount number #The volume level to be set.
---@param id string #Id for source/sink
function M:setMaxVolume(amount, id)
end

---Gets the or an empty string.
---@param id? string
---@return string
function M:_getId(id)
end

---Returns a source or sink if one with matching id is found. nil otherwise
---@param id string #Id for source or sink.
---@return PulseObject | nil
function M:_getObjectById(id)
end

---Parses a string into a SourceSink object.
---@param str string
---@return PulseObject | nil
function M:_parseObject(str)
    local re = "(.*):%s+ID: ([^,]+), Name: ([^,]+), Mute: ([^,]+), Channels: ([^,]+), Volumes: %[(.*)%](.*)"

    local type, id, name, muted, channels, volume, default = str:match(re)

    if not type then
        return
    end

    local volumes = {}
    for i in volume:gmatch "[^,]+" do
        local v = tonumber((utils.trim(utils.trim(i), "'"):gsub("(.*)%%", "%1")))
        table.insert(volumes, v)
    end


    ---@type PulseObject
    return {
        id       = id,
        name     = name,
        channels = tonumber(channels),
        volumes  = volumes,
        output   = type:match "[^%s]+" == self.types.output,
        muted    = muted == "1",
        default  = default:match "Default" ~= nil,
    }
end

---Initalize sources and sinks.
function M:init()

    awful.spawn.easy_async_with_shell(("%s %s %s"):format(self.commands.cmd, self.commands.list, ""),
        function(stdout, stderror, _, exitCode)
            if exitCode ~= 0 then
                naughty.notification {
                    title = "PulseMixerService Error",
                    text = "The pulsemixer service was not able to initalize. Reason:\n" .. stderror,
                    urgency = "critical",
                }
            end

            self.objects = {}
            for i in stdout:gmatch "[^\r\n]+" do
                local object = self:_parseObject(i)
                if object then
                    table.insert(self.objects, object)
                end
            end
        end
    )
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
---@field setVolumeAll string #Flag to set all channels volumes *default "--set-volume-all "*
---@field maxVolume string #Flag to set the maximum volume *default "--max-volume %d"*
