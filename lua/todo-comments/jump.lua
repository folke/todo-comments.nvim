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
  local line_count =  vim.api.nvim_buf_line_count(buf)

  local to
  local from

  if opts.last and up then
    from = 1
    to = line_count
    up = not up
  elseif opts.last and not up then
    from = line_count
    to = 1
    up = not up
  elseif up then
    from = pos[1] - 1
    to = 1
  else
    from = pos[1] + 1
    to = line_count
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
      return true
    end
  end
  return false
end

function M.next(opts)
  if jump(false, opts) then
    return
  end

  if config.options.wrap or opts.wrap then
    opts.last = true
    jump(true, opts)
  else
    util.warn("No more todo comments to jump to")
  end
end

function M.prev(opts)
  if jump(true, opts) then
    return
  end

  if config.options.wrap or opts.wrap then
    opts.last = true
    jump(false, opts)
  else
    util.warn("No more todo comments to jump to")
  end
end

return M
