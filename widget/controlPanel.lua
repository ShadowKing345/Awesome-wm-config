local gears = require("gears")
local wibox = require("wibox")
local redutil = require("redflat.util")
local beautiful = require("beautiful")

local copi = {screen = screen, mouse = mouse}

local controlPanel = {mt = {}}

local function merge_tables(tbl1, tbl2)
  for key, value in pairs(tbl2) do tbl1[key] = value end

  return tbl1
end

local function check_table(tbl, string)
  local v = tbl

  for key in string.gmatch(string, "([^%.]+)(%.?)") do
    if v[key] then
      v = v[key]
    else
      return nil
    end
  end

  return v
end

local function default_style()
  local style = {
    icons = {
      power = redutil.base.placeholder({txt = "⏻"}),
      volume = redutil.base.placeholder({txt = "墳"}),
      brightness = redutil.base.placeholder({txt = ""}),
      wifi = redutil.base.placeholder({txt = ""}),
      airplane = redutil.base.placeholder({txt = ""}),
      bluetooth = redutil.base.placeholder({txt = ""}),
    },
    fonts = {userName = "Roboto 21", module = "Roboto 12", textclock = "Roboto 12"},
    colors = {
      wibox = "#333333",
      main = "#ff0000",
      text = "#ffffff",
      border = "#ff0000",
      button = {bg = "#202020", fg = "#ffffff", active = "#1f1f1f", hover = "#010101"},
      slider = {bar = "#808080", handle_bg = "#202020", handle_hover = "#010101", handle_active = "#1f1f1f"},
    },
    margins = {wibox = 12},
    shape = gears.shape.rounded_rect,
  }

  return merge_tables(style, check_table(beautiful, "widget.controlPanel") or {})
end

local default_arguments = {
  profile_picture_path = os.getenv("HOME") .. "/" .. ".face.png",
  userName = os.getenv("USER"),
  modules = {},
  volume_controls = "pulse",
  placement = function(workarea, size)
    return {x = workarea.x + workarea.width - size.width - 10, y = workarea.y + workarea.height - size.height - 10}
  end,
}

function controlPanel:show()
  if not self.wibox then self:init() end

  if self.wibox.visible then
    self:hide()
  else
    self:set_position()
    self.wibox.visible = true
  end
end

function controlPanel:hide()
  if not self.wibox then self:init() end

  self.wibox.visible = false
end

function controlPanel:init(args)
  self.args = merge_tables(default_arguments, args or {})
  self.style = merge_tables(default_style(), self.args.style or {})

  self.size = {width = 256 + (self.style.margins.wibox * 2), height = 216 + (100 * math.ceil(3 / 4)) + (self.style.margins.wibox * 2)}

  self.wibox = wibox {
    screen = copi.mouse.screen,
    width = self.size.width,
    height = self.size.height,
    shape = self.style.shape,
    ontop = true,
    bg = self.style.colors.wibox,
  }
end

function controlPanel:set_position(args)
  args = args or {}
  local workarea = args.workarea or copi.screen[copi.mouse.screen].workarea
  local position = args.position or self.args.placement(workarea, self.size)

  self.wibox.x = position.x
  self.wibox.y = position.y
end

function controlPanel.new(args)
  args = args or {}
end

function controlPanel.mt:__call(...)
  return controlPanel.new(...)
end

return setmetatable(controlPanel, controlPanel.mt)

