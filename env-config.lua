local env = {mt = {}}

function env:new()
  self.terminal = "kitty"
  self.editor = os.getenv("EDITOR") or "nvim"
  self.editorCmd = self.terminal .. "-e" .. self.editor

  self.modKey = "Mod4"

  return self
end

function env.mt:__call()
  return env:new()
end

return setmetatable(env, env.mt)
