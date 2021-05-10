local Config = require("todo.config")

local M = {}

M.setup = Config.setup

function M.reset()
  require("plenary.reload").reload_module("todo")
  require("todo").setup()
end

return M
