-- tests/test_search.lua
vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.opt.runtimepath:append(vim.fn.getcwd())
vim.opt.swapfile = false
vim.opt.termguicolors = true

local todo = require("todo-comments")
todo.setup()

local Search = require("todo-comments.search")

local fake_rg_lines = {
  "tests/sample.lua:5:4:-- FIX: Fix memory leak in websocket connection handler",
  "tests/sample.lua:6:4:-- HACK: Temporary workaround for upstream dependency regression",
  "tests/sample.lua:9:4:-- WARN: Critical security deprecation notice",
  "tests/sample.lua:14:4:-- NOTE: Architecture and Design Decision",
  "tests/sample.lua:19:4:-- TODO: Implement two-factor authentication (2FA)",
  "tests/sample.lua:26:4:-- TODO: Database and Query Optimization",
  "tests/sample.lua:32:4:-- TODO: Migrate UI components to Tailwind v4",
  "tests/sample.lua:39:4:-- TODO: [ ] Create seed script for mock test data",
  "tests/sample.lua:43:6:  -- TODO: Payment processing and validation pipeline",
  "tests/sample.lua:50:8:    -- WARN: Invalid transaction attempt detected",
  "tests/sample.lua:57:6:  -- TODO: Single line todo without any continuation comments",
}

local results = Search.process(fake_rg_lines)

print("\n==================== SEARCH RESULTS & SUBTASK BADGES ====================")
for _, item in ipairs(results) do
  print(string.format("[%s] Line %2d -> %s", item.tag, item.lnum, item.text))
  if item.tasks and item.tasks.total > 0 then
    print(
      string.format(
        "      Tasks: %d/%d done (doing: %d) | Context: +%d lines",
        item.tasks.done,
        item.tasks.total,
        item.tasks.doing,
        item.context_lines or 0
      )
    )
  elseif item.context_lines and item.context_lines > 0 then
    print(string.format("      Context info: +%d lines", item.context_lines))
  end
end
print("=========================================================================\n")

-- Assertions
local todo_2fa = results[5]
assert(todo_2fa.tasks.total == 4 and todo_2fa.tasks.done == 2, "2FA must have 2/4 tasks")

local todo_db = results[6]
assert(todo_db.tasks.total == 3 and todo_db.tasks.done == 3, "DB must be 100% completed (3/3)")

local todo_tailwind = results[7]
assert(todo_tailwind.tasks.total == 4 and todo_tailwind.tasks.done == 1, "Tailwind must have 1/4 tasks")

local todo_seed = results[8]
assert(todo_seed.tasks.total == 1 and todo_seed.tasks.done == 0, "Seed must have 0/1 tasks")

local todo_single_line = results[11]
assert(
  todo_single_line.context_lines == 0,
  "Single-line TODO followed by code must have 0 context lines, found " .. tostring(todo_single_line.context_lines)
)
assert(todo_single_line.tasks.total == 0, "Single-line TODO must have 0 tasks")

print("✨ ALL SEARCH & TASK BADGE TESTS PASSED SUCCESSFULLY ✨\n")
