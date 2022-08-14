--[[

    Battery Widget

]]
--------------------------------------------------
local awful     = require "awful"
local aSpawn    = require "awful.spawn"
local gTable    = require "gears.table"
local gShape    = require "gears.shape"
local gTimer    = require "gears.timer"
local gPCall    = require "gears.protected_call"
local beautiful = require "beautiful"
local wibox     = require "wibox"

local utils = require "utils"

--------------------------------------------------
local M = {
    mt          = {},
    widget      = nil,
    status      = {
        state          = "unknown",
        percentage     = "0",
        name           = "[Unknown]",
        additionalInfo = "",
        timer          = nil,
    },
    validStates = { "full", "charging", "discharging", "unknown" },
}

function M.default_style(style)
    local n = "widget_battery_"

    local result = {
        icons        = {
            stylesheet    = beautiful[n .. "icons_stylesheet"],
            batteryStates = {
                full        = beautiful[n .. "icons_batery_states_full"],
                charging    = beautiful[n .. "icons_batery_states_charging"],
                discharging = beautiful[n .. "icons_batery_states_discharging"],
                unknown     = beautiful[n .. "icons_batery_states_unkown"],
            },
            percentages   = beautiful[n .. "icons_percentages"] or {},
        },
        spacing      = beautiful[n .. "spacing_widget"] or wibox.widget {
            forced_width = 5,
            widget       = wibox.container.background,
        },
        bg           = {
            normal = beautiful[n .. "bg_normal"],
            hover  = beautiful[n .. "bg_hover"],
            active = beautiful[n .. "bg_active"],
        },
        fg           = {
            normal = beautiful[n .. "fg_normal"],
            hover  = beautiful[n .. "fg_hover"],
            active = beautiful[n .. "fg_active"],
        },
        margins      = beautiful[n .. "margins"] or 5,
        padding      = beautiful[n .. "padding"] or 5,
        shape        = beautiful[n .. "shape"] or gShape.rectangle,
        statusScript = beautiful[n .. "status_script"],
        timerTimeout = beautiful[n .. "timer_timeout"] or 60,
    }

    return gTable.merge(result, style or {})
end

function M:init(style)
    self.style = self.style or M.default_style(style or {})

    local button = wibox.widget {
        {
            {
                {
                    {
                        id         = "icon",
                        stylesheet = self.style.icons.stylesheet,
                        widget     = wibox.widget.imagebox,
                    },
                    {
                        id         = "overlay",
                        stylesheet = self.style.icons.stylesheet,
                        widget     = wibox.widget.imagebox,
                    },
                    layout = wibox.layout.stack,
                },
                self.style.spacing,
                {
                    id     = "text",
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            margins = self.style.padding,
            widget  = wibox.container.margin,
        },
        bg     = self.style.bg.normal,
        fg     = self.style.fg.normal,
        shape  = self.style.shape,
        widget = wibox.container.background,
    }
    self.widget  = wibox.widget {
        button,
        margins = self.style.margins,
        widget  = wibox.container.margin,
    }

    self.widget._button  = button
    self.widget._tooltip = awful.tooltip {
        objects = { self.widget },
        mode    = "outside",
    }

    button:buttons(gTable.join(
        awful.button({}, 1,
            function()
                button.bg = self.style.bg.active
                button.fg = self.style.fg.active
            end,
            function()
                button.bg = self.style.bg.hover
                button.fg = self.style.fg.hover
            end
        )
    ))

    button:connect_signal("mouse::enter", function()
        button.bg = self.style.bg.hover
        button.fg = self.style.fg.hover
    end)
    button:connect_signal("mouse::leave", function()
        button.bg = self.style.bg.normal
        button.fg = self.style.fg.normal
    end)

    self.status.timer = gTimer {
        timeout   = self.style.timerTimeout,
        call_now  = true,
        autostart = false,
        callback  = function()
            local t = type(self.style.statusScript)
            if t == "string" then
                aSpawn.easy_async_with_shell(self.style.statusScript, function(stdout, _, _, exitCode)
                    if exitCode ~= 0 then
                        return self:stopTimer(true)
                    end

                    if #utils.trim(stdout) == 0 then
                        return self:stopTimer(true)
                    end

                    local results = utils.splitString(utils.trim(stdout), ",")
                    M:setStatus {
                        name           = results[1],
                        state          = results[2],
                        percentage     = results[3],
                        additionalInfo = results[4],
                    }
                end)
            elseif t == "function" then
                if not gPCall(function() self.style.statusScript(function(obj) M:setStatus(obj) end) end) then
                    return self:stopTimer(true)
                end
            else
                self:stopTimer(true)
            end
        end,
    }
end

function M:update()
    if not self.widget then
        return
    end

    local text = self.widget._button:get_children_by_id "text"[1]
    if text then
        text.text = self.status.percentage .. "%"
    end

    if self.widget._tooltip then
        self.widget._tooltip.text = self.status.name ..
            (self.status.additionalInfo and ": " .. self.status.additionalInfo or "")
    end
end

function M:startTimer(show)
    if not self.status.timer or self.status.timer.started then
        return
    end

    if show then
        self:showWidget()
    end

    self.status.timer:start()
end

function M:stopTimer(hide)
    if not self.status.timer or not self.status.timer.started then
        return
    end

    if hide then
        self:hideWidget()
    end

    self.status.timer:stop()
end

function M:hideWidget()
    if not self.widget then
        return
    end

    self.widget.visible = false
end

function M:showWidget()
    if not self.widget then
        return
    end

    self.widget.visible = true
end

function M:setStatus(obj)
    if not obj or type(obj) ~= "table" then
        return
    end

    local status = self.status
    status.name = (obj.name and type(obj.name) == "string") and obj.name or "[Unknown]"
    status.percentage = (obj.percentage and type(obj.percentage) == "string") and obj.percentage or "[Unknown]"
    status.additionalInfo = (obj.additionalInfo and type(obj.additionalInfo) == "string") and obj.additionalInfo or nil
    status.state = (obj.state and type(obj.state) == "string" and gTable.hasitem(self.validStates, obj.state) ~= nil)
        and obj.state or "unknown"

    self.status.valid = true
    M:update()
end

function M:new(args)
    args = args or {}

    if not self.widget then
        M:init(args.style or {})
        M:update()
    end

    return self
end

--------------------------------------------------
function M.mt:__call(...)
    return M:new(...)
end

return setmetatable(M, M.mt)
