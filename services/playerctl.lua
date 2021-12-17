local read = require("util.read")
local gtable = require("gears.table")
local awful = require("awful")
local util = require("util")

local playerctl = {mt = {}}

local actions = {"play", "pause", "play-pause", "stop", "next", "previous"}

-- #region Individual Player Controls
function playerctl:action(action, all)
  if all == nil then all = false end
  local index = gtable.hasitem(actions, action)
  if not index then return end

  awful.spawn.easy_async(string.format("playerctl %s %s", all and "-a" or "-p " .. self._current, actions[index]), function(_, _, _, exitcode)
    if exitcode ~= 0 then self._current = nil end
  end)
end

function playerctl:set_volume(args)

end

function playerctl:get_title()
  if not self._current then return end

  return read.output(string.format("playerctl -p %s metadata xesam:title", self._current))
end

function playerctl:get_status()

end
-- #endregion

-- #region Player Controls
function playerctl:prev_player()
  local players = self.get_players()

  local current = gtable.hasitem(players, self._current or "")
  self._current = current and players[(current - 1 < 1) and #players or (current - 1)] or nil
end

function playerctl:next_player()
  local players = self.get_players()

  local current = gtable.hasitem(players, self._current or "")
  self._current = current and players[(current + 1 > #players) and 1 or (current + 1)] or nil
end

function playerctl:get_player()
  return self._current
end

function playerctl.get_players()
  local result = {}
  local players = read.output("playerctl -l")

  for p in players:gmatch("([^\n]+)") do table.insert(result, p) end
  return result
end

function playerctl:get_player_metadata(all)
  if all == nil then all = false end
  local result = {}
  local regex = "(%a+) (%S+) +(.-)\n"

  if all then
    local metadata = read.output("playerctl -a metadata")
    for player, k, v in metadata:gmatch(regex) do
      if result[player] == nil then result[player] = {} end

      result[player][k] = v
    end
  else
    if not self._current then return nil end

    local metadata = read.output(string.format("playerctl -p %s metadata", self._current))
    for _, key, value in metadata:gmatch(regex) do result[key] = value end
  end

  return result
end
-- #endregion

function playerctl:init(args)
  self._current = self.get_players()[1] or nil
end

function playerctl.mt:__call(...)
  return playerctl:init(...)
end

return setmetatable(playerctl, playerctl.mt)
