local Config = require("todo-comments.config")
local Highlight = require("todo-comments.highlight")
local Util = require("todo-comments.util")

local M = {}

local function keywords_filter(opts_keywords)
  assert(not opts_keywords or type(opts_keywords) == "string", "'keywords' must be a comma separated string or nil")
  local all_keywords = vim.tbl_keys(Config.keywords)
  if not opts_keywords then
    return all_keywords
  end
  local filters = vim.split(opts_keywords, ",")
  return vim.tbl_filter(function(kw)
    return vim.tbl_contains(filters, kw)
  end, all_keywords)
end

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

function M.search(cb, opts)
  opts = opts or {}
  opts.cwd = opts.cwd or "."
  opts.cwd = vim.fn.fnamemodify(opts.cwd, ":p")
  opts.disable_not_found_warnings = opts.disable_not_found_warnings or false
  if not Config.loaded then
    Util.error("todo-comments isn't loaded. Did you run setup()?")
    return
  end

  local command = Config.options.search.command
  local fallback_command = Config.options.fallback_search.command

  local search_args = Config.options.search.args
  local search_pattern = Config.options.search.pattern

  local command_exists = vim.fn.executable(command) == 1
  local fallback_exists = vim.fn.executable(fallback_command) == 1

  if not command_exists and not fallback_exists then
    Util.error(command .. " and " .. fallback_command .. " were not found on your path")
    return
  end

  if not command_exists and fallback_exists and fallback_command then
    if Config.options.fallback_search.disable_warning ~= true then
      Util.warn(command .. " was not found on your path, using " .. fallback_command .. " instead.")
    end
    command = fallback_command
    search_args = Config.options.fallback_search.args
    search_pattern = Config.options.fallback_search.pattern
  end

  local ok, Job = pcall(require, "plenary.job")
  if not ok then
    Util.error("search requires https://github.com/nvim-lua/plenary.nvim")
    return
  end

  local args =
    vim.tbl_flatten({ search_args, Config.search_regex(keywords_filter(opts.keywords), search_pattern), opts.cwd })
  Job:new({
    command = command,
    args = args,
    on_exit = vim.schedule_wrap(function(j, code)
      if code == 2 then
        local error = table.concat(j:stderr_result(), "\n")
        Util.error(command .. " failed with code " .. code .. "\n" .. error)
      end
      if code == 1 and opts.disable_not_found_warnings ~= true then
        Util.warn("no todos found")
      end
      local lines = j:result()
      cb(M.process(lines))
    end),
  }):start()
end

local function parse_opts(opts)
  if not opts or type(opts) ~= "string" then
    return opts
  end
  return {
    keywords = opts:match("keywords=(%S*)"),
    cwd = opts:match("cwd=(%S*)"),
  }
end

function M.setqflist(opts)
  M.setlist(opts)
end

function M.setloclist(opts)
  M.setlist(opts, true)
end

function M.setlist(opts, use_loclist)
  opts = parse_opts(opts) or {}
  opts.open = (opts.open ~= nil) and opts.open or true
  M.search(function(results)
    if use_loclist then
      vim.fn.setloclist(0, {}, " ", { title = "Todo", id = "$", items = results })
    else
      vim.fn.setqflist({}, " ", { title = "Todo", id = "$", items = results })
    end
    if opts.open then
      if use_loclist then
        vim.cmd([[lopen]])
      else
        vim.cmd([[copen]])
      end
    end
    local win = vim.fn.getqflist({ winid = true })
    if win.winid ~= 0 then
      Highlight.highlight_win(win.winid, true)
    end
  end, opts)
end

return M
