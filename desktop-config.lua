local beautiful = require("beautiful")
local redflat = require("redflat")
local awful = require("awful")
local clock_desktop = require("desktop.clock")

local desktop = {}

-- This is more or less the same methods found in the redflat util.desktop library however modified to work with multiple displays and workarea offsets.
local function sum(t, n)
  n = n or #t
  local s = 0
  for i = 1, n do s = s + t[i] end
  return s
end

local function wposition(grid, n, workarea, dir)
  local total = sum(grid[dir])
  local full_gap = sum(grid.edge[dir])
  local gap = #grid[dir] > 1 and (workarea[dir] - total - full_gap) / (#grid[dir] - 1) or 0

  local current = sum(grid[dir], n - 1)
  local pos = grid.edge[dir][1] + (n - 1) * gap + current

  if dir == "width" then
    pos = pos + workarea.x
  elseif dir == "height" then
    pos = pos + workarea.y
  end

  return pos
end

local function wgeometry(grid, place, workarea)
  return {
    x = wposition(grid, place[1], workarea, "width"),
    y = wposition(grid, place[2], workarea, "height"),
    width = grid.width[place[1]],
    height = grid.height[place[2]],
  }
end

function desktop:init(args)
  if not beautiful.desktop then return end

  awful.screen.connect_for_each_screen(function(s)
    args = args or {}
    local env = args.env or {}
    local autohide = env.desktop_autohide or false

    local workarea = s.workarea

    local grid = beautiful.desktop.grid
    local places = beautiful.desktop.places

    -- Clock
    local clock = {geometry = wgeometry(grid, places.clock, workarea)}
    clock.args = {}
    clock.style = {}

    -- Network
    local netspeed = {geometry = wgeometry(grid, places.netspeed, workarea)}
    netspeed.args = {
      interface = env.network,
      maxspeed = {up = 6 * 1024 ^ 2, down = 6 * 1024 ^ 2},
      crit = {up = 6 * 1024 ^ 2, down = 6 * 1024 ^ 2},
      timeout = 2,
      autoscalse = true,
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
