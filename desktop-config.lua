local beautiful = require("beautiful")
local redflat = require("redflat")
local naughty = require("naughty")
local awful = require("awful")
local wibox = require("wibox")
local clock_desktop = require("desktop.clock")

local desktop = {}

local wgeometry = redflat.util.desktop.wgeometry
local system = redflat.system

function desktop:init(args)
    if not beautiful.desktop then return end

    awful.screen.connect_for_each_screen(function(s)
        args = args or {}
        local env = args.env or {}
        local autohide = env.desktop_autohide or false

        local workarea = s.workarea

        local grid = beautiful.desktop.grid
        local places = beautiful.desktop.places

        local clock = { geometry = wgeometry(grid, places.clock, workarea) }
        clock.args = {}
        clock.style = {}

        -- Audio

        -- Network
        local netspeed = {geometry = wgeometry(grid, places.netspeed, workarea)}
        netspeed.args = {
            interface = env.network,
            maxspeed = {up = 6 * 1024 ^ 2, down = 6 * 1024 ^ 2},
            crit = {up = 6 * 1024 ^ 2, down = 6 * 1024 ^ 2},
            timeout = 2,
            autoscalse = true
        }

        netspeed.style = {}

        -- Init widgets
        netspeed.body = redflat.desktop.speedmeter.normal(netspeed.args, netspeed.style)
        clock.body = clock_desktop(clock.args, clock.style)

        -- Desktop setup
        local desktop_objects = {netspeed, clock}

        if not autohide then
            redflat.util.desktop.build.static(desktop_objects)
        else
            redflat.util.desktop.build.dynamic(desktop_objects, nil, beautiful.desktopbg, arg.buttons)
        end
    end)
end

return desktop
