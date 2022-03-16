local awful = require "awful"
local gears = require "gears"

local autostart = {}

function autostart.run()
    if not gears.filesystem.file_readable "/tmp/awesomeWmFirstBoot" then
        -- Creating a blank file as a check.
        awful.spawn.with_shell "touch /tmp/awesomeWmFirstBoot"

        -- environment

        -- gnome environment
        awful.spawn.with_shell "nvidia-settings --load-config-only" -- personal display config file. (recommened to use xrandar if you have no idea what it does)
        awful.spawn.with_shell "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"

        -- utils
        awful.spawn.with_shell "picom -b"
        awful.spawn.with_shell "nm-applet"

        -- apps
        awful.spawn.with_shell "discord"
        awful.spawn.with_shell "mailspring -b"
    end
end

function autostart.run_from_file(file_)
    local f = io.open(file_)
    for line in f:lines() do
        if line:sub(1, 1) ~= "#" then
            awful.spawn.with_shell(line)
        end
    end
    f:close()
end

return autostart
