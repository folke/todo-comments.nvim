local highlight = require("todo-comments.highlight")
local config = require("todo-comments.config")
local util = require("todo-comments.util")

local M = {}

---@param up boolean
local function jump(up, opts)
  opts = opts or {}
  opts.keywords = opts.keywords or {}

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  local pos = vim.api.nvim_win_get_cursor(win)

  local from = pos[1] + 1
  local to = vim.api.nvim_buf_line_count(buf)

  if up then
    from = pos[1] - 1
    to = 1
  end

  for l = from, to, up and -1 or 1 do
    local line = vim.api.nvim_buf_get_lines(buf, l - 1, l, false)[1] or ""
    local ok, start, _, kw = pcall(highlight.match, line)

    if ok and start then
      if config.options.highlight.comments_only and highlight.is_comment(buf, l - 1, start) == false then
        kw = nil
      end
    end

    if kw and #opts.keywords > 0 and not vim.tbl_contains(opts.keywords, kw) then
      kw = nil
    end

    if kw then
      vim.api.nvim_win_set_cursor(win, { l, start - 1 })
      return
    end
  end
  util.warn("No more todo comments to jump to")
end

function M.next(opts)
  jump(false, opts)
end
function M.prev(opts)
  jump(true, opts)
end

return M
