--------------------------------------------------
--
--      Pulse Mixer API mapper
--
--------------------------------------------------

-- Features
-- [*] Toggle mute, mute, unmute.
-- [*] Get mute state.
-- [*] Change volume by delta amount.
-- [*] Get / Set volume.
-- [*] Set max volume.
-- [x] Select default / active.
-- [*] Get source/sink information.

--------------------------------------------------
local setmetatable = setmetatable

local awful   = require "awful"
local gTable  = require "gears.table"
local gString = require "gears.string"

--------------------------------------------------
---@class PulseMixer
---@field sources SourceSink[] #Collection of sources.
---@field sinks SourceSink[] #Collection of sources.
local pulseMixer = {
    mt             = {},
    ---@type SourceSink[]
    sources        = {},
    ---@type PulseCommands
    commands       = {
        cmd          = "pulsemixer",
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
    commandFormat  = "%s %s %s",
    active         = {
        sink   = nil,
        source = nil,
    },
    ---@type SourceSinkType
    sourceSinkType = {}
}

---Changes the volume of a source/sink by a delta amount.
---@param amount number #The amount to change by.
---@param id? string #Id for source/sink.
function pulseMixer:changeVolume(amount, id)
    id = id or self.active.sink

    awful.spawn.easy_async(self.commandFormat:format(
        self.commands.cmd,
        self:_getId(id),
        self.commands.changeVolume:format(amount)
    ), function(_, _, _, exitcode)
        if exitcode ~= 0 then
            return
        end

        local sourceSink = self:_getSourceSinkById(id)
        if sourceSink then
            for k, v in ipairs(sourceSink.volumes) do
                sourceSink.volumes[k] = v + amount
            end
        end
    end)
end

---Sets the volume to a given amount.
---Having an array of ammounts will change for each unique channel in order.
---@param amounts number|number[] #The ammount/amounts to change for each volume channel.
---@param id string #Id for source/sink
function pulseMixer:setVolume(amounts, id)
    local cmd
    local t = type(amounts)

    if t == "table" then
        cmd = self.commands.setVolumeAll .. table.concat(amounts, ":")
    elseif t == "number" then
        cmd = self.commands.setVolume:format(amounts)
    end

    awful.spawn.easy_async(
        self.commandFormat:format(
            self.commands.cmd,
            self:_getId(id),
            cmd
        ),
        function(_, _, _, exitcode)
            if exitcode ~= 0 then
                return
            end

            local sourceSink = self:_getSourceSinkById(id)

            if t == "table" then
                for k, v in ipairs(amounts) do
                    sourceSink.volumes[k] = v
                end
            elseif t == "number" then
                for k = 1, #sourceSink.volumes, 1 do
                    sourceSink.volumes[k] = amounts
                end
            end
        end
    )
end

---Gets the current volumes for all channels.
---Returns an empty array if none was found.
---@param id string #Id for source/sink.
---@return number[]
function pulseMixer:getVolume(id)
    id = id or self.active.sink
    local sourceSink = self:_getSourceSinkById(id)

    if sourceSink then
        return sourceSink.volumes
    end

    local cmd = io.popen(self.commandFormat:format(self.commands.cmd, self:_getId(id), self.commands.getVolume))
    local stdOut, result, cleanExit = cmd:read "a", {}, cmd:close()

    if cleanExit then
        for channel in stdOut:gmatch "%d+" do
            table.insert(result, tonumber(channel))
        end
    end

    return result
end

---Gets the current muted state
---@param id? string #Id of source or sink.
---@return boolean|nil
function pulseMixer:getMuted(id)
    id = id or self.active.sink
    local sourceSink = self:_getSourceSinkById(id)

    if sourceSink then
        return sourceSink.is_muted
    end

    local cmd = io.popen(self.commandFormat:format(self.commands.cmd, self:_getId(id), self.commands.getMuted))
    local stdOut, cleanExit = cmd:read "a", cmd:close()

    if cleanExit then
        return stdOut == "0"
    end

    return nil
end

---Mutes a source or sink
---@param id? string #Id of source or sink
function pulseMixer:mute(id)
    id = id or self.active.sink

    awful.spawn.easy_async(
        self.commandFormat:format(
            self.commands.cmd,
            self:_getId(id),
            self.commands.mute
        ),
        function(_, _, _, exitcode)
            if exitcode ~= 0 then
                return
            end
            local sourceSink = self:_getSourceSinkById(id)
            if sourceSink then
                sourceSink.is_muted = true
            end
        end
    )
end

---Unmutes a source or sink
---@param id? string #Id of source or sink
function pulseMixer:unmute(id)
    id = id or self.active.sink

    awful.spawn.easy_async(
        self.commandFormat:format(
            self.commands.cmd,
            self:_getId(id),
            self.commands.unmute
        ),
        function(_, _, _, exitcode)
            if exitcode ~= 0 then
                return
            end
            local sourceSink = self:_getSourceSinkById(id)
            if sourceSink then
                sourceSink.is_muted = false
            end
        end
    )
end

---Toggles mutes a source or sink
---@param id? string #Id of source or sink
function pulseMixer:toggleMute(id)
    id = id or self.active.sink

    awful.spawn.easy_async(
        self.commandFormat:format(
            self.commands.cmd,
            self:_getId(id),
            self.commands.toggleMute
        ),
        function(_, _, _, exitcode)
            if exitcode ~= 0 then
                return
            end
            local sourceSink = self:_getSourceSinkById(id)
            if sourceSink then
                sourceSink.is_muted = not sourceSink.is_muted
            end
        end
    )
end

---Sets the default sink/source used.
---@param id string #Id of source/sink
---@param type SourceSinkType #The type to set.
function pulseMixer:setDefault(id, type)
    if not id then
        return
    end

    if type == self.sourceSinkType.SINK then
        self.active.sink = id
    end

    if type == self.sourceSinkType.SOURCE then
        self.active.source = id
    end
end

---Gets the information of a source/sink. Returns the default sink if no id was provided.
---@param id string #Id for source/sink
---@return SourceSink|nil
function pulseMixer:getInfo(id)
    id = id or self.active.sink
    local sourceSink = self:_getSourceSinkById(id)

    if sourceSink then
        return sourceSink
    end

    local cmd = io.popen(self.commandFormat:format(self.commands.cmd, "-l", ""))
    local stdOut, cleanExit = cmd:read "a", cmd:close()

    if cleanExit then
        for str in stdOut:gmatch "[^\n]+" do
            local obj = self:_parseStringIntoSourceSink(str)
            if obj.id == id then
                return obj
            end
        end
    end

    return nil
end

---Sets the maximum volume.
---Note this is just a wrapper method for the flag  of the same name. I have no idea what it is doing behind the scenes.
---@param amount number #The volume level to be set.
---@param id string #Id for source/sink
function pulseMixer:setMaxVolume(amount, id)
    id = id or self.active.sink

    awful.spawn(self.commandFormat:format(
        self.commands.cmd,
        self:_getId(id),
        self.commands.maxVolume:format(amount)
    ))
end

---Gets the or an empty string.
---@param id? string
---@return string
function pulseMixer:_getId(id)
    if id then
        return self.commands.id:format(id)
    elseif self.active.sink then
        return self.commands.id:format(self.active.sink)
    end
    return ""
end

---Returns a source or sink if one with matching id is found. nil otherwise
---@param id string #Id for source or sink.
---@return SourceSink|nil
function pulseMixer:_getSourceSinkById(id)
    for _, source in pairs(self.sources) do
        if source.id == id then
            return source
        end
    end

    return nil
end

---Parses a string into a SourceSink object.
---@param str string
---@return SourceSink
function pulseMixer:_parseStringIntoSourceSink(str)
    local t, data = str:match "(%w+):%s+([^.]+).?"

    return {
        type       = self.sourceSinkType[t],
        id         = data:match "ID: ([^,]+),.*",
        name       = data:match "Name: ([^,]+),.*",
        is_muted   = data:match "Mute: ([^,]+),.*" == "1",
        channels   = tonumber(data:match "Channels: ([^,]+),.*"),
        volumes    = (function()
            local result = {}

            for _, i in pairs(gString.split(data:match "Volumes: %[(.*)%]", ",")) do
                table.insert(result, tonumber(i:match "^%s*(.-)%s*$":match "%d+"))
            end
            return result
        end)(),
        is_default = data:match ".*,%s+(.*)" == "Default"
    }
end

---Initalize sources and sinks.
---@param args PulseMixerServiceArgs #Arguments.
---@param results? fun(result: SourceSink[]):nil  #Callback called when the operation has finished.
function pulseMixer:initSourceSinks(args, results)
    awful.spawn.easy_async_with_shell(self.commandFormat:format(self.commands.cmd, "-l", ""),
        function(stdOut, _, _, exitcode)
            if exitcode ~= 0 then
                return
            end

            for str in stdOut:gmatch "[^\n]+" do
                local obj = self:_parseStringIntoSourceSink(str)

                if obj.type then
                    table.insert(self.sources, obj)
                    if obj.is_default then
                        self.active[(obj.type == self.sourceSinkType.SINK) and "sink" or "source"] = obj.id
                    end
                end
            end

            if args.sink then
                self.active.sink = args.sink
            end

            if args.source then
                self.active.source = args.source
            end

            if results then results(self.sources) end
        end)
end

---Creates a new pulseMixer service.
---@param args PulseMixerServiceArgs
---@return PulseMixer
function pulseMixer:new(args)
    args = args or {}

    self.commands = gTable.merge(self.commands, args.commands or {})

    self.sourceSinkType = {}
    self.sourceSinkType.SOURCE = args.sourceType or "Source"
    self.sourceSinkType[self.sourceSinkType.SOURCE] = "SOURCE"
    self.sourceSinkType.SINK = args.sinkType or "Sink"
    self.sourceSinkType[self.sourceSinkType.SINK] = "SINK"

    self:initSourceSinks(args)
    return self
end

--------------------------------------------------
function pulseMixer.mt:__call(...)
    return pulseMixer:new(...)
end

return setmetatable(pulseMixer, pulseMixer.mt)
--------------------------------------------------

---@class SourceSink #Object mapping of the name.
---@field type SourceSinkType #Variable to tell the difference between a source or a sink.
---@field id string #Id of source/sink.
---@field name string #Name of source/sink.
---@field is_muted boolean #Is source/sink muted.
---@field channels number #Number of channels.
---@field volumes number[] #Collection of all the channel volumes.
---@field is_default boolean #Is source/sink the default.

---@class SourceSinkType #Enum of type.
---@field SOURCE string
---@field SINK string

---@class PulseMixerServiceArgs #Arguments for pulsemixer service.
---@field commands PulseCommands #List of commands prefixes. Used to overwrite the default ones.
---@field sink string #Default sink id to be used.
---@field source string #Default source id to be used.
---@field sourceType string #Name of the source type.
---@field sinkType string #Name of the sink type.

---@class PulseCommands #Commands used by the pulsemixer service in order to call for information.
---@field cmd string #Main command *default "pulsemixer"*
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
