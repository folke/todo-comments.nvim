-- FIX: dddddd
-- TODO: foobar
-- dddddd
local Config = require("todo-comments.config")

---@module 'uv'

local M = {}
M.enabled = false
M.bufs = {} ---@type table<number, boolean>
M.wins = {} ---@type table<number, boolean>

-- PERF: fully optimised
-- FIX: ddddddasdasdasdasdasda
-- PERF: dddd
-- ddddd
-- dddddd
-- ddddddd
-- FIXME: dddddd
-- FIX: ddd
-- HACK: hmmm, this looks a bit funky
-- TODO: What else?
-- NOTE: adding a note
--
-- FIX: this needs fixing
-- WARNING: ???
-- FIX: ddddd
--       continuation
-- @TODO foobar
-- @hack foobar

---@type table<number, {valid: table<number, boolean>}>
M.state = {}
---@type uv.uv_timer_t?
M.timer = assert(vim.uv.new_timer())

---@return number? start, number? finish, string? kw
function M.match(str, patterns)
  local max_line_len = Config.options.highlight.max_line_len

  if max_line_len and #str > max_line_len then
    return
  end

  patterns = patterns or Config.hl_regex
  if not type(patterns) == "table" then
    patterns = { patterns }
  end

  for _, pattern in pairs(patterns) do
    local m = vim.fn.matchlist(str, [[\v\C]] .. pattern)
    if #m > 1 and m[2] then
      local match = m[2]
      local kw = m[3] ~= "" and m[3] or m[2]
      local start = str:find(match, 1, true)
      return start, start + #match, kw
    end
  end
end

-- This method returns nil if this buf doesn't have a treesitter parser
--- @return boolean? true or false otherwise
function M.is_comment(buf, row, col)
  if vim.treesitter.highlighter.active[buf] then
    local captures = vim.treesitter.get_captures_at_pos(buf, row, col)
    for _, c in ipairs(captures) do
      if c.capture == "comment" then
        return true
      end
    end
  else
    local win = vim.fn.bufwinid(buf)
    return win ~= -1
      and vim.api.nvim_win_call(win, function()
        for _, i1 in ipairs(vim.fn.synstack(row + 1, col)) do
          local i2 = vim.fn.synIDtrans(i1)
          local n1 = vim.fn.synIDattr(i1, "name")
          local n2 = vim.fn.synIDattr(i2, "name")
          if n1 == "Comment" or n2 == "Comment" then
            return true
          end
        end
      end)
  end
end

---@param buf number
---@param ns number
---@param hl string
---@param line number
---@param from number
---@param to number
local function add_highlight(buf, ns, hl, line, from, to)
  vim.api.nvim_buf_set_extmark(buf, ns, line, from, {
    end_col = to,
    hl_group = hl,
    priority = 500,
  })
end

function M.get_state(buf)
  if not M.state[buf] then
    M.state[buf] = { valid = {} }
  end
  return M.state[buf]
end

---@param buf number
function M.invalidate(buf, first, last)
  local state = M.get_state(buf)
  if first == 0 and last == -1 then
    state.valid = {}
  else
    first = math.max(first - Config.options.highlight.multiline_context, 0)
    last = math.min(last + Config.options.highlight.multiline_context, vim.api.nvim_buf_line_count(buf))
    for i = first, last do
      state.valid[i] = nil
    end
  end
  M.update()
end

function M.update()
  if not M.timer:is_active() then
    M.timer:start(Config.options.highlight.throttle, 0, vim.schedule_wrap(M._update))
  end
end

function M._update()
  for buf, state in pairs(M.state) do
    if vim.api.nvim_buf_is_valid(buf) then
      local todo = {} ---@type table<number, boolean>
      local wins = vim.fn.win_findbuf(buf)
      for _, win in pairs(wins) do
        local first = vim.fn.line("w0", win) - 1
        local last = vim.fn.line("w$", win)
        for i = first, last do
          if not state.valid[i] then
            todo[i] = true
          end
        end
      end

      local dirty = vim.tbl_keys(todo)
      table.sort(dirty)
      if #dirty > 0 then
        local i = 1
        while i <= #dirty do
          local first = dirty[i]
          local last = dirty[i]
          while dirty[i + 1] == dirty[i] + 1 do
            i = i + 1
            last = dirty[i]
          end
          M.highlight(buf, first, last)
          for j = first, last do
            state.valid[j] = true
          end
          i = i + 1
        end
      end
    else
      M.state[buf] = nil
    end
  end
end

-- highlights the range for the given buf
function M.highlight(buf, first, last, _event)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  vim.api.nvim_buf_clear_namespace(buf, Config.ns, first, last + 1)

  -- clear signs
  for _, sign in pairs(vim.fn.sign_getplaced(buf, { group = "todo-signs" })[1].signs) do
    if sign.lnum - 1 >= first and sign.lnum - 1 <= last then
      vim.fn.sign_unplace("todo-signs", { buffer = buf, id = sign.id })
    end
  end

  local lines = vim.api.nvim_buf_get_lines(buf, first, last + 1, false)

  ---@type {kw: string, start:integer}?
  local last_match

  ---@type {header_lnum: integer, kw: string, total: integer, done: integer, doing: integer, lines: integer, end_lnum: integer}?
  local current_block

  local function flush_block()
    if not current_block then
      return
    end

    local hl_opts = Config.options.highlight
    local tasks_opts = Config.options.tasks
    local virt_chunks = {}

    -- 1. Folding Icon (General for all keywords when context lines exist)
    local is_folded = (vim.fn.foldclosed(current_block.header_lnum + 2) ~= -1)
      or (vim.fn.foldclosed(current_block.header_lnum + 1) ~= -1)
    if hl_opts and hl_opts.folding and hl_opts.folding.enabled and current_block.lines > 0 then
      local fold_icon = is_folded and hl_opts.folding.closed_icon or hl_opts.folding.open_icon
      table.insert(virt_chunks, { fold_icon, "TodoFg" .. current_block.kw })
    end

    -- 2. Task Progress (Specific to TODO when tasks.progress.enabled and total > 0)
    if current_block.kw == "TODO" and tasks_opts and tasks_opts.enabled and tasks_opts.progress and tasks_opts.progress.enabled and current_block.total > 0 then
      local p_opts = tasks_opts.progress
      local parts = {}
      if p_opts.show_count then
        table.insert(parts, string.format(p_opts.count_format or "%d/%d", current_block.done, current_block.total))
      end
      if p_opts.show_percent then
        local pct = math.floor((current_block.done / current_block.total) * 100)
        table.insert(parts, string.format(p_opts.percent_format or "(%d%%)", pct))
      end
      if #parts > 0 then
        local prog_text = " " .. (p_opts.icon or "") .. table.concat(parts, " ")
        table.insert(virt_chunks, { prog_text, "TodoProgressRatio" })
      end
    end

    -- 3. Context Lines Counter (Shown when folded/hidden or if show_lines == true)
    if current_block.lines > 0 and hl_opts and hl_opts.context and hl_opts.context.enabled then
      local ctx_opts = hl_opts.context
      local should_show = false
      if ctx_opts.show_lines == "folded" then
        should_show = is_folded
      elseif ctx_opts.show_lines == true then
        should_show = true
      end

      if should_show then
        local lines_text = string.format(ctx_opts.lines_format or " (+%d lines)", current_block.lines)
        table.insert(virt_chunks, { lines_text, "TodoContextInfo" })
      end
    end

    if #virt_chunks > 0 then
      vim.api.nvim_buf_set_extmark(buf, Config.ns, current_block.header_lnum, 0, {
        virt_text = virt_chunks,
        virt_text_pos = "eol",
        priority = 500,
      })
    end

    current_block = nil
  end

  for l, line in ipairs(lines) do
    local ok, start, finish, kw = pcall(M.match, line)
    local lnum = first + l - 1

    if ok and start then
      ---@cast kw string
      if
        Config.options.highlight.comments_only
        and not M.is_quickfix(buf)
        and not M.is_comment(buf, lnum, start - 1)
      then
        kw = nil
      else
        last_match = { kw = kw, start = start }
      end
    end

    local is_multiline = false

    if not kw and last_match and Config.options.highlight.multiline then
      if
        M.is_comment(buf, lnum, last_match.start)
        and line:find(Config.options.highlight.multiline_pattern, last_match.start)
      then
        kw = last_match.kw
        start = last_match.start
        finish = start
        is_multiline = true
      else
        last_match = nil
      end
    end

    if kw then
      kw = Config.keywords[kw] or kw
    end

    if not is_multiline and kw then
      flush_block()
      current_block = {
        header_lnum = lnum,
        kw = kw,
        total = 0,
        done = 0,
        doing = 0,
        lines = 0,
        end_lnum = lnum,
      }
    elseif is_multiline and current_block then
      current_block.lines = current_block.lines + 1
      current_block.end_lnum = lnum
    elseif not is_multiline and not kw then
      flush_block()
    end

    local opts = Config.options.keywords[kw]

    if opts then
      start = start - 1
      finish = finish - 1

      local hl_fg = "TodoFg" .. kw
      local hl_bg = "TodoBg" .. kw

      local hl = Config.options.highlight

      if not is_multiline then
        -- before highlights
        if hl.before == "fg" then
          add_highlight(buf, Config.ns, hl_fg, lnum, 0, start)
        elseif hl.before == "bg" then
          add_highlight(buf, Config.ns, hl_bg, lnum, 0, start)
        end

        -- tag highlights
        if hl.keyword == "wide" or hl.keyword == "wide_bg" then
          add_highlight(buf, Config.ns, hl_bg, lnum, math.max(start - 1, 0), finish + 1)
        elseif hl.keyword == "wide_fg" then
          add_highlight(buf, Config.ns, hl_fg, lnum, math.max(start - 1, 0), finish + 1)
        elseif hl.keyword == "bg" then
          add_highlight(buf, Config.ns, hl_bg, lnum, start, finish)
        elseif hl.keyword == "fg" then
          add_highlight(buf, Config.ns, hl_fg, lnum, start, finish)
        end
      end

      -- after highlights
      if hl.after == "fg" then
        add_highlight(buf, Config.ns, hl_fg, lnum, finish, #line)
      elseif hl.after == "bg" then
        add_highlight(buf, Config.ns, hl_bg, lnum, finish, #line)
      end

      -- Markdown checkbox highlighting & parsing for TODOs
      local tasks_opts = Config.options.tasks
      if tasks_opts and tasks_opts.enabled and kw == "TODO" then
        for state, cb_cfg in pairs(tasks_opts.checkboxes) do
          local cb_s, cb_e = line:find(cb_cfg.pattern)
          if cb_s then
            local before = line:sub(1, cb_s - 1)
            local trimmed = vim.trim(before)
            local is_valid_pos = false
            if trimmed == "" then
              is_valid_pos = true
            else
              local without_comment = trimmed:gsub("^[%#%/%*%-;\"%%!]+", "")
              without_comment = vim.trim(without_comment)
              if
                without_comment == ""
                or without_comment:match("^[A-Z]+:?$")
                or without_comment:match("^[%-%*%+]%s*$")
                or without_comment:match("^%d+%.%s*$")
              then
                is_valid_pos = true
              end
            end

            if is_valid_pos then
              local name = state:sub(1, 1):upper() .. state:sub(2)
              add_highlight(buf, Config.ns, "TodoCheckbox" .. name, lnum, cb_s - 1, cb_e)

              if current_block then
                current_block.total = current_block.total + 1
                if state == "done" then
                  current_block.done = current_block.done + 1
                elseif state == "doing" then
                  current_block.doing = current_block.doing + 1
                end
              end

              if tasks_opts.signs and is_multiline then
                vim.fn.sign_place(
                  0,
                  "todo-signs",
                  "todo-sign-task-" .. state,
                  buf,
                  { lnum = lnum + 1, priority = Config.options.sign_priority }
                )
              end
              break
            end
          end
        end
      end

      if not is_multiline then
        -- signs
        local show_sign = Config.options.signs
        if opts.signs ~= nil then
          show_sign = opts.signs
        end
        if show_sign then
          vim.fn.sign_place(
            0,
            "todo-signs",
            "todo-sign-" .. kw,
            buf,
            { lnum = lnum + 1, priority = Config.options.sign_priority }
          )
        end
      end
    end
  end

  flush_block()
end

function M.is_float(win)
  local opts = vim.api.nvim_win_get_config(win)
  return opts and opts.relative and opts.relative ~= ""
end

function M.is_valid_win(win)
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  -- avoid E5108 after pressing q:
  if vim.fn.getcmdwintype() ~= "" then
    return false
  end
  -- dont do anything for floating windows
  if M.is_float(win) then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  return M.is_valid_buf(buf)
end

function M.is_quickfix(buf)
  return vim.bo[buf].buftype == "quickfix"
end

function M.is_valid_buf(buf)
  -- Skip special buffers
  local buftype = vim.bo[buf].buftype
  if buftype ~= "" and buftype ~= "quickfix" then
    return false
  end
  local filetype = vim.bo[buf].filetype
  if vim.tbl_contains(Config.options.highlight.exclude, filetype) then
    return false
  end
  return true
end

-- will attach to the buf in the window and highlight the active buf if needed
---@param win? number
---@param force? boolean
function M.attach(win, force)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  if not force and not M.is_valid_win(win) then
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  M.get_state(buf)

  if not M.bufs[buf] then
    vim.api.nvim_buf_attach(buf, false, {
      on_reload = function()
        if not M.enabled then
          return
        end
        -- detach from this buffer in case we no longer want it
        if not M.is_valid_buf(buf) then
          return
        end

        M.invalidate(buf, 0, -1)
      end,
      on_lines = function(_event, _buf, _tick, first, _last, last_new)
        if not M.enabled then
          return true
        end
        -- detach from this buffer in case we no longer want it
        if not M.is_valid_buf(buf) then
          return true
        end

        M.invalidate(buf, first, last_new)
      end,
      on_detach = function()
        M.state[buf] = nil
        M.bufs[buf] = nil
      end,
    })

    local highlighter = require("vim.treesitter.highlighter")
    local hl = highlighter.active[buf]
    if hl then
      -- also listen to TS changes so we can properly update the buffer based on is_comment
      hl.tree:register_cbs({
        on_bytes = function(_, _, row)
          M.invalidate(buf, row, row + 1)
        end,
        on_changedtree = function(changes)
          for _, ch in ipairs(changes or {}) do
            M.invalidate(buf, ch[1], ch[3] + 1)
          end
        end,
      })
    end
    M.bufs[buf] = true
  end

  if not M.wins[win] then
    M.wins[win] = true
    M.update()
  end
end

function M.stop()
  M.enabled = false
  pcall(vim.api.nvim_clear_autocmds, { group = "Todo" })
  pcall(vim.api.nvim_del_augroup_by_name, "Todo")
  M.wins = {}

  ---@diagnostic disable-next-line: missing-parameter
  vim.fn.sign_unplace("todo-signs")
  for buf, _ in pairs(M.bufs) do
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_clear_namespace, buf, Config.ns, 0, -1)
    end
  end
  M.bufs = {}
end

function M.start()
  if M.enabled then
    M.stop()
  end
  M.enabled = true
  -- setup autocmds
  local group = vim.api.nvim_create_augroup("Todo", { clear = true })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinNew" }, {
    group = group,
    callback = function(ev)
      M.attach()
    end,
  })
  vim.api.nvim_create_autocmd("WinScrolled", {
    group = group,
    callback = function(ev)
      M.update()
    end,
  })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function(ev)
      vim.defer_fn(require("todo-comments.config").colors, 10)
    end,
  })

  -- attach to all bufs in visible windows
  for _, win in pairs(vim.api.nvim_list_wins()) do
    M.attach(win)
  end
end

return M
