local setmetatable = setmetatable
local string = string

local wibox = require("wibox")
local beautiful = require("beautiful")
local timer = require("gears.timer")

local redflat = require("redflat")
local redutil = require("redflat.util")
local textbox = require("desktop.common.textbox")
local arcchart = require("wibox.container.arcchart")
local util = require("util")

local clock = {mt = {}}

local function default_style()
    local style = {
        hands = {
            start_angle = math.pi / 2,
            paddings = {left = 2, right = 2, top = 2, bottom = 2},
            rounded_edge = true,
            color = {fg = "#b1222b", bg = nil},
            thickness = 10,
        },
        minutes = {color = {fg = "#404040"}},
        hours = {color = {fg = "#404040"}},
        label = {
            time = {gap = 12, font = {font = "Sans", size = 66, face = 1, slant = 0}, sep = "-", draw = "lower_right"},
            date = {height = 50, gap = 12, font = {font = "Sans", size = 20, face = 1, slant = 0}, sep = "-", draw = "upper_right"},
        },
        color = {main = "#b1222b", wibox = "#161616", gray = "#404040"},
    }
    return redutil.table.merge(style, redutil.table.check(beautiful, "desktop.clock") or {})
end

local default_args = {timeout = 1}

local function create_hand(style)
    local hand = arcchart()

    hand.start_angle = style.start_angle
    hand.paddings = style.paddings
    hand.rounded_edge = style.rounded_edge
    hand.thickness = style.thickness

    hand.bg = style.color.bg
    hand.colors = {style.color.fg}

    return hand
end

local function get_date_suffix(s)
    if s == 11 or s == 12 or s == 13 then return "th" end
    s = s % 10
    if s == 1 then return "st" end
    if s == 2 then return "nd" end
    if s == 3 then return "rd" end
    return "th"
end

function clock.new(args, style)
    local dwidget = {}
    args = redutil.table.merge(default_args, args or {})
    style = redutil.table.merge(default_style(), style or {})

    dwidget.style = style

    -- obj setup
    local seperator = redflat.gauge.separator.horizontal(style.color)

    local time_label = textbox("03:30", style.label.time)
    local date_label = textbox("Wednesday 29th 2021", style.label.date)

    local seconds_hand = create_hand(redutil.table.merge(style.hands, redutil.table.check(style, "seconds") or {}))
    local minutes_hand = create_hand(redutil.table.merge(style.hands, redutil.table.check(style, "minutes") or {}))
    local hour_hand = create_hand(redutil.table.merge(style.hands, redutil.table.check(style, "hours") or {}))

    seconds_hand.min_value = 0
    seconds_hand.max_value = 59
    seconds_hand.value = 45

    minutes_hand.min_value = 0
    minutes_hand.max_value = 60
    minutes_hand.value = 30

    hour_hand.min_value = 0
    hour_hand.max_value = 12
    hour_hand.value = 3

    minutes_hand:set_children({hour_hand, layout = wibox.layout.flex.horizontal})
    seconds_hand:set_children({minutes_hand, layout = wibox.layout.flex.horizontal})

    local mirror = wibox.container.mirror(seconds_hand, {vertical = true, horizontal = false})

    -- setup layout
    dwidget.area = wibox.widget({
        nil,
        {
            {nil, {time_label, right = 5, bottom = 5, widget = wibox.container.margin}, mirror, layout = wibox.layout.align.horizontal},
            seperator,
            date_label,
            expand = "outside",
            layout = wibox.layout.align.vertical,
        },
        expand = "outside",
        layout = wibox.layout.align.horizontal,
    })

    -- Update info
    local function update()
        local datetime = util.string.split(os.date("%H %M %S %A %d %B %Y"), " ")

        local seconds = tonumber(datetime[3])
        local minutes = tonumber(datetime[2]) + seconds / 60.0
        local hours = (tonumber(datetime[1]) % 12) + minutes / 60.0

        hour_hand.value = hours
        minutes_hand.value = minutes
        seconds_hand.value = seconds

        time_label:set_text(table.concat(util.table.subset(datetime, 1, 2), ":"))

        local date = util.table.subset(datetime, 4, 7)
        date[2] = date[2] .. get_date_suffix(tonumber(date[2]))

        date_label:set_text(table.concat(date, " "))
    end

    -- Set update timer
    local t = timer({timeout = args.timeout})
    t:connect_signal("timeout", update)
    t:start()
    t:emit_signal("timeout")

    return dwidget
end

function clock.mt:__call(...)
    return clock.new(...)
end

return setmetatable(clock, clock.mt)
