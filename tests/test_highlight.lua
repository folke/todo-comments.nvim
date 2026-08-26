-- tests/test_highlight.lua
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

-- Run buffer highlight engine
require("todo-comments.highlight").highlight(buf, 0, vim.api.nvim_buf_line_count(buf))

local ns = require("todo-comments.config").ns
local marks = vim.api.nvim_buf_get_extmarks(buf, ns, { 0, 0 }, { -1, -1 }, { details = true })

print("\n==================== GENERATED EXTMARKS & VIRTUAL TEXT ====================")
local found_progress = false
for _, m in ipairs(marks) do
  local row = m[2] + 1
  local col = m[3]
  local details = m[4] or {}
  local hl = details.hl_group or "None"
  local vt = details.virt_text

  if vt then
    local vt_str = ""
    for _, chunk in ipairs(vt) do
      vt_str = vt_str .. string.format("[%s (%s)] ", chunk[1], chunk[2])
    end
    print(string.format("Line %2d (col %2d) -> VIRT_TEXT: %s", row, col, vt_str))
    if vt_str:find("TodoProgressRatio") then
      found_progress = true
    end
  elseif hl:find("TodoCheckbox") then
    print(string.format("Line %2d (col %2d-%2d) -> CHECKBOX HL: %s", row, col, details.end_col or col, hl))
  end
end
print("===========================================================================\n")

assert(found_progress, "Error: Progress ratio virtual text was not found")
print("✨ ALL STEP 2 HIGHLIGHT TESTS PASSED SUCCESSFULLY ✨\n")
