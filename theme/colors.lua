--[[

        General storage for theme and colors.

]]
--------------------------------------------------
local M = {}

--  Main colors
--------------------------------------------------
M.colors = {
    flamingo  = "#F2CDCD",
    mauve     = "#DDB6F2",
    pink      = "#F5C2E7",
    maroon    = "#E8A2AF",
    red       = "#F28FAD",
    peach     = "#F8BD96",
    yellow    = "#FAE3B0",
    green     = "#ABE9B3",
    teal      = "#B5E8E0",
    blue      = "#96CDFB",
    sky       = "#89DCEB",
    black_0   = "#161320",
    black_1   = "#1A1826",
    black_2   = "#1E1E2E",
    black_3   = "#302D41",
    black_4   = "#575268",
    gray_0    = "#6E6C7E",
    gray_1    = "#988BA2",
    gray_2    = "#C3BAC6",
    white     = "#D9E0EE",
    lavender  = "#C9CBFF",
    rosewater = "#F5E0DC",
}

-- Main Theme
--------------------------------------------------
M.bg_prime_colors = {
    M.colors.flamingo,
    M.colors.mauve,
    M.colors.pink,
    M.colors.maroon,
    M.colors.red,
    M.colors.peach,
    M.colors.yellow,
    M.colors.green,
    M.colors.teal,
    M.colors.blue,
    M.colors.sky,
    M.colors.white,
    M.colors.lavender,
    M.colors.rosewater,
}

local main = table.remove(M.bg_prime_colors, math.random(#M.bg_prime_colors))
local secondary = M.bg_prime_colors[math.random(#M.bg_prime_colors)]

M.theme = {
    main   = main,
    second = secondary,
    gray   = M.colors.gray_2,
    bg     = {
        normal   = M.colors.black_2,
        focus    = main,
        urgent   = secondary,
        minimize = M.colors.black_4,
        button   = {
            normal = M.colors.black_3,
            hover  = M.colors.black_4,
            active = M.colors.black_1,
        },
    },
    fg     = {
        normal   = M.colors.white,
        focus    = M.colors.gray_0,
        urgent   = M.colors.rosewater,
        minimize = M.colors.lavender,
        button   = {
            normal = M.colors.white,
            hover  = M.colors.lavender,
            active = M.colors.rosewater,
        },
    },
}

return M
