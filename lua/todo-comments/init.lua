local config = require("todo-comments.config")
local jump = require("todo-comments.jump")

local M = {}

M.setup = config.setup

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

M.jump_prev = jump.prev
M.jump_next = jump.next

function M.toggle()
  require("todo-comments.tasks").toggle()
end

function M.toggle_fold()
  require("todo-comments.tasks").toggle_fold()
end

return M
