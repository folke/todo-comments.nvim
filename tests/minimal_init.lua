-- tests/minimal_init.lua
-- Isolated test harness environment for todo-comments.nvim

vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.opt.runtimepath:append(vim.fn.getcwd())
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.swapfile = false

-- Auto-discover auxiliary plugins (plenary, telescope, trouble) if present
local lazy_plugins = {
  vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim"),
  vim.fn.expand("~/.local/share/nvim/lazy/telescope.nvim"),
  vim.fn.expand("~/.local/share/nvim/lazy/trouble.nvim"),
}
for _, p in ipairs(lazy_plugins) do
  if vim.fn.isdirectory(p) == 1 then
    vim.opt.runtimepath:append(p)
  end
end

-- Initialize Telescope if available
pcall(function()
  require("telescope").setup({})
  require("telescope").load_extension("todo-comments")
end)

-- Load and setup todo-comments
local todo = require("todo-comments")
todo.setup({
  signs = true,
  highlight = {
    multiline = true,
    multiline_pattern = "^.",
    multiline_context = 10,
  },
})

-- Convenient test keymaps
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>tt", "<cmd>TodoToggle<CR>", { desc = "Toggle TODO task status" })
vim.keymap.set("n", "<leader>tf", "<cmd>TodoToggleFold<CR>", { desc = "Toggle TODO multiline fold" })

print("✨ [todo-comments.nvim] Test environment ready. Keymaps: <Space>tt (Toggle) | <Space>tf (Fold)")
