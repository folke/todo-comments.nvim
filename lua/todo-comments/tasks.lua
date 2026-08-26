local Config = require("todo-comments.config")
local Highlight = require("todo-comments.highlight")

local M = {}

--- Finds the multiline comment block containing line `lnum` (0-indexed)
---@param buf number
---@param lnum number (0-indexed)
---@return { header_lnum: integer, end_lnum: integer, kw: string }?
function M.get_block_at(buf, lnum)
  local line_count = vim.api.nvim_buf_line_count(buf)
  if lnum < 0 or lnum >= line_count then
    return nil
  end

  local line = vim.api.nvim_buf_get_lines(buf, lnum, lnum + 1, false)[1] or ""
  local ok, start, _, kw = pcall(Highlight.match, line)

  -- Case 1: Cursor is directly on the header line
  if ok and start and kw then
    kw = Config.keywords[kw] or kw
    local end_lnum = lnum
    for next_l = lnum + 1, math.min(lnum + Config.options.highlight.multiline_context, line_count - 1) do
      local next_line = vim.api.nvim_buf_get_lines(buf, next_l, next_l + 1, false)[1] or ""
      local n_ok, n_start, _, n_kw = pcall(Highlight.match, next_line)
      if n_ok and n_start and n_kw then
        break -- found another header
      end
      if
        Highlight.is_comment(buf, next_l, start)
        and next_line:find(Config.options.highlight.multiline_pattern, start)
      then
        end_lnum = next_l
      else
        break
      end
    end
    return { header_lnum = lnum, end_lnum = end_lnum, kw = kw }
  end

  -- Case 2: Cursor is on a continuation child line; scan backwards
  for prev_l = lnum - 1, math.max(0, lnum - Config.options.highlight.multiline_context), -1 do
    local prev_line = vim.api.nvim_buf_get_lines(buf, prev_l, prev_l + 1, false)[1] or ""
    local p_ok, p_start, _, p_kw = pcall(Highlight.match, prev_line)
    if p_ok and p_start and p_kw then
      local block = M.get_block_at(buf, prev_l)
      if block and block.end_lnum >= lnum then
        return block
      end
      break
    end
  end

  return nil
end

--- Reads context lines from disk or memory and calculates task and line stats:
--- { total = M, done = N, doing = P, lines = K }
function M.get_block_stats(filename, lnum, start_col, kw)
  local stats = { total = 0, done = 0, doing = 0, lines = 0 }
  local max_context = (Config.options.highlight and Config.options.highlight.multiline_context) or 10

  local buf = vim.fn.bufnr(filename)
  local lines = {}
  if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
    lines = vim.api.nvim_buf_get_lines(buf, lnum, lnum + max_context, false)
  else
    if vim.fn.filereadable(filename) == 1 then
      local all_lines = vim.fn.readfile(filename, "", lnum + max_context)
      if #all_lines >= lnum then
        for i = lnum + 1, math.min(#all_lines, lnum + max_context) do
          table.insert(lines, all_lines[i])
        end
      end
    end
  end

  local tasks_opts = Config.options.tasks
  for _, line in ipairs(lines) do
    local ok, start, _, n_kw = pcall(Highlight.match, line)
    if ok and start and n_kw then
      break
    end

    local pattern = (Config.options.highlight and Config.options.highlight.multiline_pattern) or "^."
    if line:find(pattern, start_col or 1) then
      stats.lines = stats.lines + 1
      if kw == "TODO" and tasks_opts and tasks_opts.enabled then
        for state, cb_cfg in pairs(tasks_opts.checkboxes) do
          if line:find(cb_cfg.pattern) then
            stats.total = stats.total + 1
            if state == "done" then
              stats.done = stats.done + 1
            elseif state == "doing" then
              stats.doing = stats.doing + 1
            end
            break
          end
        end
      end
    else
      break
    end
  end

  return stats
end

--- Cycles checkbox on current line: [ ] -> [/] -> [x] -> [ ]
function M.toggle()
  local tasks_opts = Config.options.tasks
  if tasks_opts and tasks_opts.enabled == false then
    local Util = require("todo-comments.util")
    Util.warn("Task checkboxes are disabled. Enable them with 'tasks = { enabled = true }' or remove the :TodoToggle mapping.")
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lnum = cursor[1] - 1
  local line = vim.api.nvim_buf_get_lines(buf, lnum, lnum + 1, false)[1]
  if not line then
    return
  end

  local new_line = nil
  if line:find("%[%s*%]") then
    new_line = line:gsub("%[%s*%]", "[/]", 1)
  elseif line:find("%[%/%]") then
    new_line = line:gsub("%[%/%]", "[x]", 1)
  elseif line:find("%[[xX]%]") then
    new_line = line:gsub("%[[xX]%]", "[ ]", 1)
  else
    -- If line is inside a TODO block without a checkbox, insert [ ]
    local block = M.get_block_at(buf, lnum)
    if block and block.kw == "TODO" then
      if lnum == block.header_lnum then
        local start, finish = Highlight.match(line)
        if start and finish then
          new_line = line:sub(1, finish) .. " [ ]" .. line:sub(finish + 1)
        end
      else
        local prefix, rest = line:match("^(%s*[%-%#%/%*]*%s*)(.*)$")
        if prefix and rest then
          new_line = prefix .. "[ ] " .. rest
        end
      end
    end
  end

  if new_line and new_line ~= line then
    local max_context = (Config.options.highlight and Config.options.highlight.multiline_context) or 10
    vim.api.nvim_buf_set_lines(buf, lnum, lnum + 1, false, { new_line })
    Highlight.invalidate(buf, math.max(0, lnum - max_context), lnum + max_context)
    Highlight.update()
  end
end

--- Toggles folding for context lines under the current comment block
function M.toggle_fold()
  local hl_opts = Config.options.highlight
  if hl_opts and hl_opts.folding and hl_opts.folding.enabled == false then
    local Util = require("todo-comments.util")
    Util.warn("Multiline folding is disabled. Enable it with 'highlight = { folding = { enabled = true } }' or remove the :TodoToggleFold mapping.")
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lnum = cursor[1] - 1
  local block = M.get_block_at(buf, lnum)
  if not block or block.end_lnum <= block.header_lnum then
    vim.notify("No multiline context lines to fold", vim.log.levels.INFO)
    return
  end

  local fold_start = block.header_lnum + 2 -- 1-indexed next line after header
  local fold_end = block.end_lnum + 1

  local is_folded = vim.fn.foldclosed(fold_start) ~= -1
  if is_folded then
    pcall(vim.cmd, string.format("%d,%dfoldopen!", fold_start, fold_end))
  else
    pcall(vim.cmd, string.format("%d,%dfold", fold_start, fold_end))
  end

  Highlight.invalidate(buf, block.header_lnum, block.end_lnum)
  Highlight.highlight(buf, block.header_lnum, block.end_lnum)
  Highlight.update()
end

return M
