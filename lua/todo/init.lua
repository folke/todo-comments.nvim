local Config = require("todo.config")

local M = {}

function M.setup(opts)
  Config.setup(opts)
  require("todo.highlight").start()
end

function M.reset()
  require("plenary.reload").reload_module("todo")
  require("todo").setup()
end

return M
