local Search = require("todo-comments.search")
local util = require("trouble.util")
local Config = require("todo-comments.config")

local function todo(_win, _buf, cb, opts)
  Search.search(function(results)
    local ret = {}
    for _, item in pairs(results) do
      local row = (item.lnum == 0 and 1 or item.lnum) - 1
      local col = (item.col == 0 and 1 or item.col) - 1

      local pitem = {
        row = row,
        col = col,
        message = item.text,
        sign = Config.options.keywords[item.tag].icon,
        sign_hl = "TodoFg" .. item.tag,
        -- code = string.lower(item.tag),
        -- source = "todo",
        severity = 0,
        range = {
          start = { line = row, character = col },
          ["end"] = { line = row, character = -1 },
        },
      }

      table.insert(ret, util.process_item(pitem, vim.fn.bufnr(item.filename, true)))
    end
    if #ret == 0 then
      util.warn("no todos found")
    end
    cb(ret)
  end, opts.cmd_options)
end

return todo
