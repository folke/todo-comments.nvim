local Config = require("todo-comments.config")

local M = {}

M.setup = Config.setup

function M.reset()
  require("plenary.reload").reload_module("todo")
  require("todo-comments").setup()
end

return M
