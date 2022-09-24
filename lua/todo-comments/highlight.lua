local Config = require("todo-comments.config")

local M = {}
M.enabled = false
M.bufs = {}
M.wins = {}

-- PERF: fully optimised
-- HACK: hmmm, this looks a bit funky
-- TODO: What else?
-- NOTE: adding a note
-- FIX: this needs fixing
-- WARNING: ???
-- FIX: ddddd
--
-- TODO: Whoa, there's a huge problem here
--       that I had to describe in a lot of detail
-- but this isn't part of it

-- WARNING: with space immediately after
--          to check if this multiline works too
--         and doesn't highlight this, it's too short

-- FIXME: prevent trailing comments from being flagged
local _dont_delete_me_this_is_a_test = {
    blah = true -- trailing comment
}

-- todo: fooo
-- @TODO foobar
-- @hack foobar

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
      local kw = m[2]
      local start = str:find(kw)
      return start, start + #kw, kw
    end
  end
end

-- This method returns nil if this buf doesn't have a treesitter parser
-- @return true or false otherwise
function M.is_comment(buf, line)
  local highlighter = require("vim.treesitter.highlighter")
  local hl = highlighter.active[buf]

  if not hl then
    return
  end

  local is_comment = false
  hl.tree:for_each_tree(function(tree, lang_tree)
    if is_comment then
      return
    end

    local query = hl:get_query(lang_tree:lang())
    if not (query and query:query()) then
      return
    end

    local iter = query:query():iter_captures(tree:root(), buf, line, line + 1)

    for capture, _ in iter do
      if query._query.captures[capture] == "comment" then
        is_comment = true
      end
    end
  end)
  return is_comment
end

local function add_highlight(buffer, ns, hl, line, from, to)
  -- vim.api.nvim_buf_set_extmark(buffer, ns, line, from, {
  --   end_line = line,
  --   end_col = to,
  --   hl_group = hl,
  --   priority = 500,
  -- })
  vim.api.nvim_buf_add_highlight(buffer, ns, hl, line, from, to)
end

local function is_multiline_todo(buf, lnum, line, last_match)
  if not Config.options.highlight.comments_only or not Config.options.highlight.multiline or M.is_quickfix(buf) or not M.is_comment(buf, lnum) or last_match == nil then
      return false
  end
  -- finish in last_match is where the match ended on the previous line, and we
  -- know the keyword too. So character at finish should be preceded by a
  -- number of spaces at least equal to the length of the match
  -- we also have to be careful with tabs
  local without_tabs = line:gsub("\t", string.rep(" ", vim.o.tabstop))
  -- add 1 to account for the colon after the keyword
  local fin = last_match["finish"] + 1
  local kw = last_match["kw"]
  local substring = without_tabs:sub(fin - #kw, fin)
  if substring ~= string.rep(" ", #substring) then
      return false
  end

  -- use greater than to account for colon
  return #substring > #kw
end

-- highlights the range for the given buf
function M.highlight(buf, first, last, _event)
  -- print("highlight: [" .. first .. ", " .. last .. "] " .. tostring(event))
  -- vim.api.nvim_err_writeln(vim.inspect({ first, last }))
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

  local last_match = nil
  for l, line in ipairs(lines) do
    local ok, start, finish, kw = pcall(M.match, line)
    local lnum = first + l - 1

    if ok and start then
      if Config.options.highlight.comments_only and not M.is_quickfix(buf) and M.is_comment(buf, lnum) == false then
        kw = nil
      end
      last_match = nil
    else
      if is_multiline_todo(buf, lnum, line, last_match) then
        kw = last_match["kw"]
        start = last_match["start"]
        finish = last_match["finish"]
      else
        last_match = nil
      end
    end

    if kw then
      kw = Config.keywords[kw] or kw
    end

    local opts = Config.options.keywords[kw]

    if opts then
      start = start - 1
      finish = finish - 1

      local hl_fg = "TodoFg" .. kw
      local hl_bg = "TodoBg" .. kw

      local hl = Config.options.highlight

      -- before highlights
      if hl.before == "fg" then
        add_highlight(buf, Config.ns, hl_fg, lnum, 0, start)
      elseif hl.before == "bg" then
        add_highlight(buf, Config.ns, hl_bg, lnum, 0, start)
      end

      -- tag highlights
      if start ~= finish then
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

      -- signs
      local show_sign = Config.options.signs
      if opts.signs ~= nil then
        show_sign = opts.signs
      end

      if last_match ~= nil then
        show_sign = false
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
      if Config.options.highlight.multiline then
        last_match = {kw = kw, start = finish + 1, finish = finish + 1}
      end
    end
  end
end

-- highlights the visible range of the window
function M.highlight_win(win, force)
  win = win or vim.api.nvim_get_current_win()
  if force ~= true and not M.is_valid_win(win) then
    return
  end

  vim.api.nvim_win_call(win, function()
    local buf = vim.api.nvim_win_get_buf(win)
    local first = vim.fn.line("w0") - 1
    local last = vim.fn.line("w$")
    M.highlight(buf, first, last)
  end)
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
  return vim.api.nvim_buf_get_option(buf, "buftype") == "quickfix"
end

function M.is_valid_buf(buf)
  -- Skip special buffers
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
  if buftype ~= "" and buftype ~= "quickfix" then
    return false
  end
  local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
  if vim.tbl_contains(Config.options.highlight.exclude, filetype) then
    return false
  end
  return true
end

-- will attach to the buf in the window and highlight the active buf if needed
function M.attach(win)
  win = win or vim.api.nvim_get_current_win()
  if not M.is_valid_win(win) then
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)

  if not M.bufs[buf] then
    vim.api.nvim_buf_attach(buf, false, {
      on_lines = function(_event, _buf, _tick, first, _last, last_new)
        if not M.enabled then
          return true
        end
        -- detach from this buffer in case we no longer want it
        if not M.is_valid_buf(buf) then
          return true
        end

        -- HACK: use defer, because treesitter resets highlights
        M.highlight(buf, first, last_new, "buf:on_lines")
      end,
      on_detach = function()
        M.bufs[buf] = nil
      end,
    })

    local highlighter = require("vim.treesitter.highlighter")
    local hl = highlighter.active[buf]
    if hl then
      -- also listen to TS changes so we can properly update the buffer based on is_comment
      hl.tree:register_cbs({
        on_changedtree = function(changes)
          for _, ch in ipairs(changes or {}) do
            vim.defer_fn(function()
              M.highlight(buf, ch[1], ch[3] + 1, "on_changedtree")
            end, 0)
          end
        end,
      })
    end

    M.bufs[buf] = true
    M.highlight_win(win)
    M.wins[win] = true
  elseif not M.wins[win] then
    M.highlight_win(win)
    M.wins[win] = true
  end
end

function M.stop()
  M.enabled = false
  pcall(vim.cmd, "autocmd! Todo")
  pcall(vim.cmd, "augroup! Todo")
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
  -- TODO: make some of the below configurable
  vim.api.nvim_exec(
    [[augroup Todo
        autocmd!
        autocmd BufWinEnter,WinNew * lua require("todo-comments.highlight").attach()
        autocmd BufWritePost * silent! lua require'trouble'.refresh({auto = true, provider = "todo"})
        autocmd WinScrolled * lua require("todo-comments.highlight").highlight_win()
        autocmd ColorScheme * lua vim.defer_fn(require("todo-comments.config").colors, 10)
      augroup end]],
    false
  )

  -- attach to all bufs in visible windows
  for _, win in pairs(vim.api.nvim_list_wins()) do
    M.attach(win)
  end
end

return M
