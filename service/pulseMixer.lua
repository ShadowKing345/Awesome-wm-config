--------------------------------------------------
--
--      Pulse Mixer API mapper
--
--------------------------------------------------

-- Features
-- [*] Toggle mute, mute, unmute.
-- [*] Get mute state.
-- [*] Change volume by delta amount.
-- [ ] Get / Set volume.
-- [ ] Change volumes for all at once.
-- [ ] Get / Set max volume.
-- [ ] Select default / active.
-- [ ] Get source/sink information.

--------------------------------------------------
local setmetatable = setmetatable

local awful = require "awful"

--------------------------------------------------
---@class PulseMixer
---@field sources SourceSink[] #Collection of sources.
---@field sinks SourceSink[] #Collection of sources.
local pulseMixer = {
    mt            = {},
    sources       = {},
    sink          = {},
    commands      = {
        cmd          = "pulsemixer",
        id           = "--id %s",
        getMuted     = "--get-mute",
        mute         = "--mute",
        unmute       = "--unmute",
        toggleMute   = "--toggle-mute",
        changeVolume = "--change-volume %d",
    },
    commandFormat = "%s %s %s",
    active        = {
        sink   = nil,
        source = nil,
    }
}

---@type SourceSinkType
local SourceSinkType = {
    SOURCE = "Source",
    SINK   = "Sink",
}

---Changes the volume of a source/sink by a delta amount.
---@param amount number #The amount to change by.
---@param id? string #Id for source/sink.
function pulseMixer:changeVolume(amount, id)
    awful.spawn.with_shell(self.commandFormat:format(
        self.commands.cmd,
        self:_getId(id),
        self.commands.changeVolume:format(amount)
    ))
end

---Gets the current muted state
---@param id? string #Id of source or sink.
---@return boolean|nil
function pulseMixer:getMuted(id)
    print(self.active.source)

    if not id and self.active.source then
        return self:_getSourceSinkById(self.active.source).is_muted
    end

    local sourceSink, result = self:_getSourceSinkById(id)

    if sourceSink then
        result = sourceSink.is_muted
    else
        local cmd = io.popen(self.commandFormat:format(self.commands.cmd, self:_getId(id), self.commands.getMuted))
        result = cmd:read "a":match "([^\n]+)\n" == "1"
    end

    return result
end

---Mutes a source or sink
---@param id? string #Id of source or sink
function pulseMixer:mute(id)
    local sourceSink = self:_getSourceSinkById(id) or self:_getSourceSinkById(self.active.source)

    awful.spawn.with_shell(self.commandFormat:format(
        self.commands.cmd,
        self:_getId(sourceSink and sourceSink.id),
        self.commands.mute
    ))
    if sourceSink then sourceSink.is_muted = true end
end

---Unmutes a source or sink
---@param id? string #Id of source or sink
function pulseMixer:unmute(id)
    local sourceSink = self:_getSourceSinkById(id) or self:_getSourceSinkById(self.active.source)

    awful.spawn.with_shell(self.commandFormat:format(
        self.commands.cmd,
        self:_getId(sourceSink and sourceSink.id),
        self.commands.unmute
    ))
    if sourceSink then sourceSink.is_muted = false end
end

---Toggles mutes a source or sink
---@param id? string #Id of source or sink
function pulseMixer:toggleMute(id)
    local sourceSink = self:_getSourceSinkById(id) or self:_getSourceSinkById(self.active.source)

    awful.spawn.with_shell(self.commandFormat:format(
        self.commands.cmd,
        self:_getId(sourceSink and sourceSink.id),
        self.commands.toggleMute
    ))
    if sourceSink then sourceSink.is_muted = not sourceSink.is_muted end
end

---Gets the or an empty string.
---@param id? string
---@return string
function pulseMixer:_getId(id)
    return id and self.commands.id:format(id) or ""
end

---Returns a source or sink if one with matching id is found. nil otherwise
---@param id string #Id for source or sink.
---@return SourceSink|nil
function pulseMixer:_getSourceSinkById(id)
    for _, sink in ipairs {} do
        if sink.id == id then
            return sink
        end
    end

    for _, source in ipairs {} do
        if source.id == id then
            return source
        end
    end

    return nil
end

---Initalize sources and sinks.
---@param results? fun(result: SourceSink[]):nil  #Callback called when the operation has finished.
function pulseMixer:initSourceSinks(results)
    awful.spawn.easy_async_with_shell(self.commandFormat:format(self.commands.cmd, "-l", ""),
        function(stdOut, _, _, exitcode)
            if exitcode ~= 0 then
                return
            end

            for type, data in stdOut:gmatch "(%w+):%s+([^\n]*)\n?" do
                ---@type SourceSink
                local obj = {
                    type       = (
                        type == SourceSinkType.SOURCE and SourceSinkType.SOURCE or
                            type == SourceSinkType.SINK and SourceSinkType.SINK
                        ) or nil,
                    id         = data:match "ID: ([^,]+),.*",
                    name       = data:match "Name: ([^,]+),.*",
                    is_muted   = data:match "Mute: ([^,]+),.*" == "1",
                    channels   = tonumber(data:match "Channels: ([^,]+),.*"),
                    volumes    = (function()
                        local result = {}

                        for i in data:match "Volumes: %[(.*)%]":gmatch "([^,]+)" do
                            table.insert(result, tostring(i:match "'(.*)%'"))
                        end
                        return result
                    end)(),
                    is_default = data:match ".*,%s+(.*)" == "Default"
                }

                if obj.type then
                    table.insert(obj.type == SourceSinkType.SINK and pulseMixer.sink or pulseMixer.sources, obj)
                    if obj.is_default then
                        self.active[obj.type == SourceSinkType.SINK and "sink" or "source"] = obj.id
                    end
                end
            end

            if results then results { sinks = self.sink, sources = self.sources } end
        end)
end

function pulseMixer:new(args)
    self:initSourceSinks()
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
