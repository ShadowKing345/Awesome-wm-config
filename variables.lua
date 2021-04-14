local r = {}

r.terminal = "alacritty"
r.editor = os.getenv( "EDITOR" ) or "nvim"
r.modkey = "Mod4"
r.editor_cmd = r.terminal .. " -e " .. r.editor

return r

