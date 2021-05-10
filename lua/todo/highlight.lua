local Config = require("todo.config")

local M = {}
M.bufs = {}
M.wins = {}

-- PERF: folke was here
-- HACK: ..
-- TODO: dsadasd
-- PERF: dsdasds
-- NOTE: dddd
-- XXX: dsaasdd
-- FIXME: dddd
-- FIX: asdasd
-- TODO: dooo
-- WARN: dadads
-- TODO: dasdasdas
-- WARNING: dasdasdas

function M.match(str)
  for kw in pairs(Config.keywords) do
    local start, finish = str:find("(" .. kw .. "):")
    if start then return start, finish, kw end
  end
end

-- highlights the range for the given buf
function M.highlight(buf, first, last)
  vim.api.nvim_buf_clear_namespace(buf, Config.ns, first, last + 1)

  -- clear signs
  for _, sign in pairs(vim.fn.sign_getplaced(buf, { group = "todo-signs" })[1]
                         .signs) do
    if sign.lnum - 1 >= first and sign.lnum - 1 <= last then
      vim.fn.sign_unplace("todo-signs", { buffer = buf, id = sign.id })
    end
  end

  local lines = vim.api.nvim_buf_get_lines(buf, first, last + 1, false)

  for l, line in ipairs(lines) do
    local start, finish, kw = M.match(line)
    local lnum = first + l - 1

    if start then
      start = start - 1
      finish = finish - 1
      kw = Config.keywords[kw] or kw
      local opts = Config.options.keywords[kw]

      local hl_fg = "TodoFg" .. kw
      local hl_bg = "TodoBg" .. kw

      local hl = Config.options.highlight

      -- before highlights
      if hl.before == "fg" then
        vim.api.nvim_buf_add_highlight(buf, Config.ns, hl_fg, lnum, 0, start)
      elseif hl.before == "bg" then
        vim.api.nvim_buf_add_highlight(buf, Config.ns, hl_bg, lnum, 0, start)
      end

      -- tag highlights
      if hl.tag == "wide" then
        vim.api.nvim_buf_add_highlight(buf, Config.ns, hl_bg, lnum,
                                       math.max(start - 1, 0), finish + 1)
      elseif hl.tag == "bg" then
        vim.api.nvim_buf_add_highlight(buf, Config.ns, hl_bg, lnum, start,
                                       finish)
      elseif hl.tag == "fg" then
        vim.api.nvim_buf_add_highlight(buf, Config.ns, hl_bg, lnum, start,
                                       finish)
      end

      -- after highlights
      if hl.after == "fg" then
        vim.api.nvim_buf_add_highlight(buf, Config.ns, hl_fg, lnum, finish,
                                       #line)
      elseif hl.after == "bg" then
        vim.api.nvim_buf_add_highlight(buf, Config.ns, hl_bg, lnum, finish,
                                       #line)
      end

      -- signs
      local show_sign = Config.options.signs
      if opts.signs ~= nil then show_sign = opts.signs end
      if show_sign then
        vim.fn.sign_place(0, "todo-signs", "todo-sign-" .. kw, buf,
                          { lnum = lnum + 1, priority = 8 })
      end
    end
  end
end

-- highlights the visible range of the window
function M.highlight_win(win)
  win = win or vim.api.nvim_get_current_win()
  local current_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local first = vim.fn.line("w0") - 1
  local last = vim.fn.line("w$")
  M.highlight(buf, first, last)
  vim.api.nvim_set_current_win(current_win)
end

-- will attach to the buf in the window and highlight the active buf if needed
function M.attach(win)
  win = win or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)

  if not M.bufs[buf] then
    vim.api.nvim_buf_attach(buf, false, {
      on_lines = function(event, buf, tick, first, last, last_new)
        -- HACK: use defer, because after an undo, nvim_buf_get_lines returns lines before undo
        vim.defer_fn(function() M.highlight(buf, first, last_new) end, 0)
      end,
      on_detach = function() M.bufs[buf] = nil end,
    })
    M.bufs[buf] = true
    M.highlight_win(win)
  end
  if not M.wins[win] then
    M.highlight_win(win)
    M.wins[win] = true
  end
end

function M.start()
  -- setup autocmds
  vim.api.nvim_exec([[
    augroup Todo
      autocmd!
      autocmd BufWinEnter * lua require("todo.highlight").attach()
      autocmd WinScrolled * lua require("todo.highlight").highlight_win()
      autocmd ColorScheme * lua vim.defer_fn(require("todo.config").colors, 10)
    augroup end
  ]], false)

  -- attach to all bufs in visible windows
  for _, win in pairs(vim.api.nvim_list_wins()) do M.attach(win) end
end

return M
