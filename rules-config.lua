local awful = require "awful"
local ruled = require "ruled"

local M = {}

function M:init(args)
    args = args or {}

    ruled.client.connect_signal("request::rules", function()
        ruled.client.append_rule {
            id         = "global",
            rule       = {},
            properties = {
                focus     = awful.client.focus.filter,
                raise     = true,
                screen    = awful.screen.preferred,
                placement = awful.placement.no_overlap + awful.placement.no_offscreen
            }
        }

        ruled.client.append_rule {
            id         = "floating",
            rule_any   = {
                instance = { "copyq", "pinentry" },
                class    = {
                    "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                    "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
                },
                name     = {
                    "Event Tester",
                },
                role     = {
                    "AlarmWindow",
                    "ConfigManager",
                    "pop-up",
                }
            },
            properties = { floating = true }
        }

        ruled.client.append_rule {
            id         = "titlebars",
            rule_any   = { type = { "normal", "dialog" } },
            properties = { titlebars_enabled = true }
        }

        self.rules = {
            { rule = {}, properties = args.base_properties or self.base_properties },
            { rule_any = args.floating_any or self.floating_any, properties = { floating = true } },
            { rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = true } },
            { rule = { class = "discord" }, properties = { tag = "3", screen = 1, maximized = true } }, -- discord
        }

        for _, v in pairs(args.rules or {}) do
            table.insert(self.rules, v)
        end
    end)
end

return M
