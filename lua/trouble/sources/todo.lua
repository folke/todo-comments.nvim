---@diagnostic disable: inject-field
local Config = require("todo-comments.config")
local Item = require("trouble.item")
local Search = require("todo-comments.search")

---@type trouble.Source
local M = {}

---@diagnostic disable-next-line: missing-fields
M.config = {
  formatters = {
    todo_icon = function(ctx)
      return {
        text = Config.options.keywords[ctx.item.tag].icon,
        hl = "TodoFg" .. ctx.item.tag,
      }
    end,
  },
  views = {
    todo = {
      events = { "BufEnter", "BufWritePost" },
      source = "todo",
      groups = {
        { "directory" },
        { "filename", format = "{file_icon} {filename} {count}" },
      },
      sort = { { buf = 0 }, "filename", "pos", "message" },
      format = "{todo_icon} {text} {pos}",
    },
  },
}

function M.get(cb)
  Search.search(function(results)
    local items = {} ---@type trouble.Item[]
    for _, item in pairs(results) do
      local row = item.lnum
      local col = item.col - 1
      items[#items + 1] = Item.new({
        buf = vim.fn.bufadd(item.filename),
        pos = { row, col },
        end_pos = { row, col + #item.tag },
        text = item.text,
        filename = item.filename,
        item = item,
        source = "todo",
      })
    end
    cb(items)
  end, {})
end

return M
