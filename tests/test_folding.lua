-- tests/test_folding.lua
vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.opt.runtimepath:append(vim.fn.getcwd())
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.cmd([[syntax on]])

local todo = require("todo-comments")
todo.setup()

local buf = vim.fn.bufadd("tests/sample.lua")
vim.fn.bufload(buf)
vim.bo[buf].filetype = "lua"
vim.api.nvim_set_current_buf(buf)

local Tasks = require("todo-comments.tasks")
local Highlight = require("todo-comments.highlight")
local ns = require("todo-comments.config").ns

print("\n--- TEST: MULTILINE FOLDING & ARROW ROTATION ---")
-- 1. Initial State: Unfolded / Open
Highlight.highlight(buf, 0, vim.api.nvim_buf_line_count(buf))
local marks_open = vim.api.nvim_buf_get_extmarks(buf, ns, { 18, 0 }, { 18, -1 }, { details = true })
local vt_open = marks_open[1] and marks_open[1][4].virt_text or {}
print("Unfolded State (Line 19):", vim.inspect(vt_open))
assert(vt_open[1][1] == "▼ ", "Expected down arrow icon ▼ in open state")

-- 2. Fold block at line 19 (TODO: 2FA)
vim.api.nvim_win_set_cursor(0, { 19, 0 })
Tasks.toggle_fold()

local marks_closed = vim.api.nvim_buf_get_extmarks(buf, ns, { 18, 0 }, { 18, -1 }, { details = true })
local vt_closed = marks_closed[1] and marks_closed[1][4].virt_text or {}
print("Folded State (Line 19):", vim.inspect(vt_closed))
assert(vt_closed[1][1] == "▶ ", "Expected right arrow icon ▶ in folded state")

-- Verify that in folded state, the (+4 lines) indicator is displayed
local has_lines_text = false
for _, chunk in ipairs(vt_closed) do
  if chunk[1]:find("%(%+4 lines%)") then
    has_lines_text = true
  end
end
assert(has_lines_text, "Expected (+4 lines) text in folded state")

-- 3. Re-open / Unfold
Tasks.toggle_fold()
local marks_reopened = vim.api.nvim_buf_get_extmarks(buf, ns, { 18, 0 }, { 18, -1 }, { details = true })
local vt_reopened = marks_reopened[1] and marks_reopened[1][4].virt_text or {}
print("Reopened State (Line 19):", vim.inspect(vt_reopened))
assert(vt_reopened[1][1] == "▼ ", "Expected down arrow icon ▼ after reopening")

print("\n✨ ALL FOLDING AND ARROW ROTATION TESTS PASSED SUCCESSFULLY ✨\n")
