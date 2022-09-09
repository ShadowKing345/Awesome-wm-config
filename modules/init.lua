local M = {
    pulseaudio = nil,
}

local t_pulseaudio, pulseaudio = pcall(require, "pulseaudio")

if t_pulseaudio then
    M.pulseaudio = pulseaudio
end

return M
