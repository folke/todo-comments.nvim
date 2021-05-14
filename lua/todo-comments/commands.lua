local has_telescope = pcall(require, "telescope")
local has_trouble = pcall(require, "trouble")

vim.cmd [[command! TodoQuickFix lua require("todo-comments.search").setqflist()]]

if has_telescope then
  vim.cmd [[command! TodoTelescope Telescope todo-comments todo]]
end

if has_trouble then
  vim.cmd [[command! TodoTrouble Trouble todo]]
end
