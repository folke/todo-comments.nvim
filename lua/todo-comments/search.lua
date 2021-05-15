local Config = require("todo-comments.config")
local Highlight = require("todo-comments.highlight")
local Util = require("todo-comments.util")

local M = {}

function M.process(lines)
  local results = {}
  for _, line in pairs(lines) do
    local file, row, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
    if file then
      local item = {
        filename = file,
        lnum = tonumber(row),
        col = tonumber(col),
        line = text,
      }

      local start, finish, kw = Highlight.match(text)

      if start then
        kw = Config.keywords[kw] or kw
        item.tag = kw
        item.text = vim.trim(text:sub(start))
        item.message = vim.trim(text:sub(finish + 1))
        table.insert(results, item)
      end
    end
  end
  return results
end

function M.search(cb)
  if not Config.loaded then
    Util.error("todo-comments isn't loaded. Did you run setup()?")
    return
  end

  local cmd = Config.options.search.tool

  if vim.fn.executable(cmd) ~= 1 then
    Util.error(cmd .. " was not found on your path")
    return
  end

  local ok, Job = pcall(require, "plenary.job")
  if not ok then
    Util.error("search requires https://github.com/nvim-lua/plenary.nvim")
    return
  end

  local args = vim.deepcopy(Config.options.search.tool)
  table.insert(args, Config.search_regex)
  Job
    :new({
      command = cmd,
      args = args,
      on_exit = vim.schedule_wrap(function(j, code)
        if code == 2 then
          local error = table.concat(j:stderr_result(), "\n")
          Util.error("ripgrep failed with code " .. code .. "\n" .. error)
        end
        if code == 1 then
          Util.warn("no todos found")
        end
        local lines = j:result()
        cb(M.process(lines))
      end),
    })
    :start()
end

function M.setqflist(opts)
  opts = opts or { open = true }
  M.search(function(results)
    vim.fn.setqflist({}, " ", { title = "Todo", id = "$", items = results })
    if opts.open then
      vim.cmd([[copen]])
    end
    local win = vim.fn.getqflist({ winid = true })
    if win.winid ~= 0 then
      Highlight.highlight_win(win.winid, true)
    end
  end)
end

return M
