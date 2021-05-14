local uv = vim.loop
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
  local stdin = nil
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local error = ""
  local lines = {}

  local opts = {
    args = {
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      Config.rg_regex,
    },
    stdio = { stdin, stdout, stderr },
  }

  uv.spawn("rg", opts, function(code, _signal)
    if not stdout:is_closing() then
      stdout:close()
    end
    if not stderr:is_closing() then
      stderr:close()
    end
    if code == 2 then
      vim.defer_fn(function()
        Util.error(error)
        Util.error("ripgrep failed with code " .. code)
      end, 10)
    end

    vim.schedule_wrap(function()
      cb(M.process(lines))
    end)()
  end)

  stderr:read_start(function(_err, data, _is_complete)
    if data then
      error = error .. data
    end
  end)

  stdout:read_start(function(err, data, is_complete)
    if err or not data or is_complete then
      return
    end
    data = data:gsub("\r", "")
    for _, line in pairs(vim.split(data, "\n", true)) do
      if line ~= "" then
        table.insert(lines, line)
      end
    end
  end)
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
