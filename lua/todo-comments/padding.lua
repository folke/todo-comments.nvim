local Config = require("todo-comments.config")

---@class TodoPadding
local M = {}

-- Create dedicated namespace for padding extmarks
M.ns = vim.api.nvim_create_namespace("todo-comments-padding")

---Add padding extmarks around a keyword
---@param buf number buffer number
---@param lnum number 0-indexed line number
---@param kw string keyword name (e.g., "TODO", "FIX")
---@param kw_start number 0-indexed start position of keyword
---@param kw_end number 0-indexed end position of keyword (exclusive)
---@param line string the full line text
---@param on_cursor_line boolean whether the cursor is on this line
function M.add(buf, lnum, kw, kw_start, kw_end, line, on_cursor_line)
  if not Config.options.highlight.padding.enabled then
    return
  end

  local opts = Config.options.keywords[kw]
  if not opts then
    return
  end

  -- Get padding characters (per-keyword override or default)
  local padding_config = opts.padding or {}
  local left = padding_config.left or Config.options.highlight.padding.left
  local right = padding_config.right or Config.options.highlight.padding.right

  -- Determine if we should hide padding characters on cursor line
  local should_hide_padding = on_cursor_line and Config.options.highlight.padding.hide_on_cursor

  -- Add padding characters (unless hidden on cursor line)
  if not should_hide_padding and (left ~= "" or right ~= "") then
    local hl_fg = "TodoFg" .. kw
    local hl_bg = "TodoBg" .. kw

    -- Add background highlight to keyword itself
    vim.api.nvim_buf_set_extmark(buf, M.ns, lnum, kw_start, {
      end_col = kw_end,
      hl_group = hl_bg,
      priority = 500,
    })

    -- Add left padding (inline before keyword)
    if left ~= "" then
      vim.api.nvim_buf_set_extmark(buf, M.ns, lnum, kw_start, {
        virt_text = { { left, hl_fg } },
        virt_text_pos = "inline",
        priority = 501,
      })
    end

    -- Add right padding (inline after keyword)
    if right ~= "" then
      vim.api.nvim_buf_set_extmark(buf, M.ns, lnum, kw_end, {
        virt_text = { { right, hl_fg } },
        virt_text_pos = "inline",
        priority = 501,
      })
    end
  end

  -- Handle colon concealing (independent of padding, but respects hide_on_cursor)
  local hide_colon = padding_config.hide_colon
  if hide_colon == nil then
    hide_colon = Config.options.highlight.padding.hide_colon
  end

  -- Hide colon unless we're on cursor line AND hide_on_cursor is enabled
  local should_conceal_colon = hide_colon and not (on_cursor_line and Config.options.highlight.padding.hide_on_cursor)

  if should_conceal_colon then
    local colon_pos = kw_end
    if line:sub(colon_pos + 1, colon_pos + 1) == ":" then
      vim.api.nvim_buf_set_extmark(buf, M.ns, lnum, colon_pos, {
        end_col = colon_pos + 1,
        conceal = "",
        priority = 502,
      })
    end
  end
end

---Clear padding extmarks for a buffer range
---@param buf number buffer number
---@param first number first line (0-indexed)
---@param last number last line (0-indexed, inclusive)
function M.clear(buf, first, last)
  vim.api.nvim_buf_clear_namespace(buf, M.ns, first, last + 1)
end

return M
