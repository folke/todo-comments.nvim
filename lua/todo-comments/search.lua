local uv = vim.loop
local Config = require("todo-comments.config")
local Highlight = require("todo-comments.highlight")

local M = {}

function M.search(cb)
  cb = vim.schedule_wrap(cb)
  local stdin = nil
  local stdout = uv.new_pipe(false)
  local stderr = nil
  local results = {}

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

  uv.spawn("rg", opts, function()
    if not stdout:is_closing() then stdout:close() end
    cb(results)
  end)

  stdout:read_start(function(err, data, is_complete)
    if err or not data or is_complete then return end
    data = data:gsub("\r", "")
    for _, line in pairs(vim.split(data, "\n", true)) do
      if line ~= "" then
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
    end
  end)
end

function M.setqflist(opts)
  opts = opts or { open = true }
  M.search(function(results)
    vim.fn.setqflist({}, " ", { title = "Todo", id = "$", items = results })
    if opts.open then vim.cmd [[copen]] end
    local win = vim.fn.getqflist({ winid = true })
    if win.winid ~= 0 then Highlight.highlight_win(win.winid, true) end
  end)
end

return M
