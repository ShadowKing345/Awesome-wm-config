local awful = require("awful")
local beautiful = require("beautiful")

local rules = {}

rules.base_properties = {
    border_width = beautiful.border_width,
    border_color = beautiful.border_color,
    focus = awful.client.focus.filter,
    raise = true,
    size_hints_honor = false,
    screen = awful.screen.preferred,
    placement = awful.placement.no_overlap + awful.placement.no_offscreen,
}

rules.floating_any = {
    instance = {"DTA", "copyq"},
    class = {"Arandr", "Gpick", "Kruler", "MessageWin", "Sxiv", "Wpa_gui", "pinentry", "veromix", "xtightvncviewer"},
    name = {"Event Tester"},
    role = {"AlarmWindow", "pop-up"},
}

function rules:init(args)
    args = args or {}
    self.base_properties.keys = args.hotkeys.keys.client
    self.base_properties.buttons = args.hotkeys.mouse.client

    -- Build rules
    self.rules = {
        {rule = {}, properties = args.base_properties or self.base_properties},
        {rule_any = args.floating_any or self.floating_any, properties = {floating = true}},
        {rule_any = {type = {"normal", "dialog"}}, properties = {titlebars_enabled = true}}, -- discord
        {rule = {class = "discord"}, properties = {tag = "Tag3", screen = 1, maximized = true}},

        -- attempt to make the "splash screen" for Jetbrain IDE float. Shockingly worked.
        {rule = {name = "win0"}, properties = {floating = true}},
    }

    awful.rules.rules = rules.rules
end

return rules
