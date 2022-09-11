--[[

        Pulse Mixer Service.
        Please note that this does not update if the volume changes externally.

]]
--------------------------------------------------
local awful   = require "awful"
local gTable  = require "gears.table"
local naughty = require "naughty"

local pulseaudio = require "modules".pulseaudio

local utils = require "utils"

---@enum PA_TYPES
local PA_TYPES         = {
    SINK          = "sink",
    SINK_INPUT    = "sink_input",
    SOURCE        = "source",
    SOURCE_OUTPUT = "source_ouput",
    ALL           = "all",
}
---@enum PAS_SIGNAL_TYPES
local PAS_SIGNAL_TYPES = {
    UPDATE_OBJECT = "update::object",
    UPDATE_ALL    = "update::all",
}
---@enum PAS_MUTE_MODES
local PAS_MUTE_MODES   = {
    TOGGLE = 0,
    MUTE   = 1,
    UNMUTE = 2,
}

--------------------------------------------------
---Service midleware for managing pulseaudio related functions.
---@class PulseAudioService
---Collection of pulse objects.
---@field objects {sink: PAObject[], source: PAObject[], sink_input: PAObject[], source_ouput: PAObject[]}
local M = {
    mt               = {},
    objects          = {},
    subscribers      = {},
    PA_TYPES         = PA_TYPES,
    PAS_SIGNAL_TYPES = PAS_SIGNAL_TYPES,
    PAS_MUTE_MODES   = PAS_MUTE_MODES,
}

---Checks if pulseaudio module exists. Else prints an error message.
---@return boolean
local function _check_pa()
    if not pulseaudio then
        naughty.notification {
            title   = "Pulseaudio could not be found",
            text    = "Could not find pulseaudio module. Are you sure you followed the setup instructions?",
            urgency = "critical",
        }
        return false
    end
    return true
end

---Register an event subscriber to listen in for events.
---@param key PAS_SIGNAL_TYPES #Name of event to listen for.
---@param fn function #Callback function to be called when event is fired.
function M:connect_signal(key, fn)
    if self.subscribers[key] == nil then
        self.subscribers[key] = {}
    end

    if type(fn) ~= "function" then
        return
    end

    table.insert(self.subscribers[key], fn)
end

---Unregisters an callback function.
---@param key PAS_SIGNAL_TYPES #Name of event you wish to unsubscribe to.
---@param fn function #Callback object to be removed.
function M:disconnect_signal(key, fn)
    if self.subscribers[key] == nil then
        return
    end

    local i = 0
    local index
    local flag = false

    while flag and i <= #self.subscribers[key] do
        if self.subscribers[key][i] == fn then
            index = i
        end
        i = i + 1
    end

    if not index then
        return
    end

    table.remove(self.subscribers, index)
end

---Fires an event.
---@param key PAS_SIGNAL_TYPES #Name of event.
---@param ... any #Collection of values to be passed to the function.
function M:send_signal(key, ...)
    for _, fn in ipairs(self.subscribers[key] or {}) do
        if type(fn) == "function" then
            fn(...)
        end
    end
end

---Gets or sets the current volumes for all channels.
---Returns an nil if nothing could be done else the new volume.
---@param args PASVolumeArgs #Arguments for this method.
---@return number | nil
function M:volume(args)
    if not _check_pa() then
        return
    end
    args = args or {}

    if not args.type then
        args.type = PA_TYPES.SINK
    end

    local obj = self:_get_object(args.type, args.index)
    if not args.amount or not obj then
        return obj and obj.volume or nil
    end

    local v = obj.volume
    if args.raw then
        if args.delta then
            v = v + args.amount
        else
            v = args.amount
        end
    else
        local amount = (args.amount / 100) * pulseaudio.defaults.volume_norm
        if args.delta then
            v = v + amount
        else
            v = amount
        end
    end

    v = math.floor(utils.clamp(v, pulseaudio.defaults.volume_mute, pulseaudio.defaults.volume_norm) + 0.5)

    if pulseaudio.set_volume { index = obj.index, volume = v, type = args.type } then
        obj.volume = v
        self:send_signal(PAS_SIGNAL_TYPES.UPDATE_OBJECT, obj)
        return v
    end

    return nil
end

---Gets or sets if the PulseObject is muted or not.
---Returns nil if none was found or the new state.
---@param args PASMuteArgs #Arguments for this method.
---@return boolean | nil
function M:mute(args)
    if not _check_pa() then
        return
    end
    args = args or {}

    if not args.type then
        args.type = PA_TYPES.SINK
    end

    local obj = self:_get_object(args.type, args.index)
    if args.mode == nil or not obj then
        return obj and obj.mute or nil
    end

    local mute = obj.mute
    if args.mode == PAS_MUTE_MODES.TOGGLE then
        mute = not mute
    elseif args.mode == PAS_MUTE_MODES.MUTE then
        mute = true
    elseif args.mode == PAS_MUTE_MODES.UNMUTE then
        mute = false
    else
        return nil
    end

    if pulseaudio.mute_object { type = args.type, index = obj.index, mute = mute } then
        obj.mute = mute
        self:send_signal(PAS_SIGNAL_TYPES.UPDATE_OBJECT, obj)
        return obj.mute
    end

    return nil
end

---Initalize sources and sinks.
function M:init()
    if not _check_pa() then
        return
    end

    self.objects = pulseaudio.get_object { type = PA_TYPES.ALL }
    self:send_signal(PAS_SIGNAL_TYPES.UPDATE_ALL, self.objects)
end

---Creates a new pulseMixer service instance.
---@param args PASArgs
---@return PulseAudioService
function M:new(args)
    args = args or {}

    if _check_pa() then
        self.defaults = pulseaudio.defaults
        self:init()
    end
    return self
end

---Returns the first PAObject from the current collection of objects.
---If none can be found does a server query and retries. If fails again will return nil.
---@param type PA_TYPES #The type to look for. (All by default.)
---@param index number? #Index to look for. If nil will look for default instead.
function M:_get_object(type, index)
    local default = not index

    local tables = type ~= PA_TYPES.ALL and self.objects[type] or
        {
            table.unpack(self.objects.sink),
            table.unpack(self.objects.sink_input),
            table.unpack(self.objects.source),
            table.unpack(self.objects.source_ouput)
        }

    local function query(t)
        for _, v in ipairs(t) do
            if default then
                if v.default then
                    return v
                end
            elseif v.index == index then
                return v
            end
        end

        return nil
    end

    local result = query(tables)
    if result ~= nil then
        return result
    end

    self:init()
    return query(tables)
end

---Returns a list of the objects stored in the service.
---@param type PA_TYPES? #The type of object you wish to get. (Default: all)
---@param flatten boolean? #Flatten the list down to a single array. (Default: false)
---@return PAObject[] | table<PA_TYPES, PAObject[]>
function M:get_objects(type, flatten)
    if not type then
        type = PA_TYPES.ALL
    end

    local objs = type == PA_TYPES.ALL and self.objects or self.objects[type]

    if flatten and type == PA_TYPES.ALL and objs then
        local flatten_result = {}

        for _, category in pairs(objs) do
            for _, obj in ipairs(category) do
                table.insert(flatten_result, obj)
            end
        end

        return flatten_result
    end

    return objs
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
---@field name string? #Name of the application.
---@field pid string? #Program id of the application.
---@field binary string? #The binary name.

---Defines a PulseAudioObject.
---@class PAObject
---@field index number #Id of source/sink.
---@field name string? #Name of source/sink.
---@field mute boolean #Is source/sink muted.
---@field volume number #Average volume of all channels..
---@field default boolean #Is source/sink the default.
---@field type PA_TYPES #Type for the object.

---Arguments for pulsemixer service.
---@class PASArgs

---Arguments for the volume method.
---@class PASVolumeArgs
---@field index number? #Id for PulseObject.
---@field delta boolean? #Sets amount to be a difference of the current volume.
---@field amount number? #Amount to set the volume to be.
---@field raw boolean? #Sets to use raw values rather then calculated. (Default false)
---@field type PA_TYPES? #If needed the type of input to set. Default sink.

---Arguments for the mute method.
---@class PASMuteArgs
---@field index number? #Id for PAObject.
---@field mode number? #Should the state be toggled.
---@field type PA_TYPES? #If needed the type of input to set. Default sink.
