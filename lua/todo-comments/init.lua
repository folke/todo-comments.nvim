local Config = require("todo-comments.config")

local M = {}

M.setup = Config.setup

function M.reset()
  require("plenary.reload").reload_module("todo")
  require("todo-comments").setup()
end

function M.disable()
  require("todo-comments.highlight").stop()
end

function M.enable()
  require("todo-comments.highlight").start()
end

return M
