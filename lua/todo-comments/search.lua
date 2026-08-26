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
  local ok_tasks, Tasks = pcall(require, "todo-comments.tasks")
  local search_badges = Config.options.search and Config.options.search.badges ~= false

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

        local header_tasks = { total = 0, done = 0, doing = 0 }
        local tasks_opts = Config.options.tasks
        if kw == "TODO" and tasks_opts and tasks_opts.enabled then
          for state, cb_cfg in pairs(tasks_opts.checkboxes) do
            if text:find(cb_cfg.pattern) then
              header_tasks.total = header_tasks.total + 1
              if state == "done" then
                header_tasks.done = 1
              elseif state == "doing" then
                header_tasks.doing = 1
              end
              break
            end
          end
        end

        local stats = { total = 0, done = 0, doing = 0, lines = 0 }
        if ok_tasks and Tasks and Tasks.get_block_stats then
          local s_ok, s_res = pcall(Tasks.get_block_stats, file, item.lnum, start, kw)
          if s_ok and s_res then
            stats = s_res
          end
        end

        local total_tasks = header_tasks.total + stats.total
        local done_tasks = header_tasks.done + stats.done
        local doing_tasks = header_tasks.doing + stats.doing

        item.tasks = { total = total_tasks, done = done_tasks, doing = doing_tasks }
        item.context_lines = stats.lines

        if search_badges then
          local badges = {}

          -- Task progress badge
          if kw == "TODO" and total_tasks > 0 and tasks_opts and tasks_opts.enabled and tasks_opts.progress and tasks_opts.progress.enabled ~= false then
            local p_opts = tasks_opts.progress
            local parts = {}
            if p_opts.show_count ~= false then
              table.insert(parts, string.format(p_opts.count_format or "%d/%d", done_tasks, total_tasks))
            end
            if p_opts.show_percent == true then
              local pct = math.floor((done_tasks / total_tasks) * 100)
              table.insert(parts, string.format(p_opts.percent_format or "(%d%%)", pct))
            end
            if #parts > 0 then
              table.insert(badges, "[" .. table.concat(parts, " ") .. "]")
            end
          end

          -- Multiline context lines badge
          local hl_opts = Config.options.highlight
          if stats.lines > 0 and hl_opts and hl_opts.context and hl_opts.context.enabled ~= false then
            table.insert(badges, string.format("[+%d lines]", stats.lines))
          end

          if #badges > 0 then
            local badge_str = table.concat(badges, " ")
            item.text = item.text .. "  " .. badge_str
            item.message = item.message .. "  " .. badge_str
          end
        end

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

  if vim.fn.executable(command) ~= 1 then
    Util.error(command .. " was not found on your path")
    return
  end

  local ok, Job = pcall(require, "plenary.job")
  if not ok then
    Util.error("search requires https://github.com/nvim-lua/plenary.nvim")
    return
  end

  local args = {}
  vim.list_extend(args, Config.options.search.args)
  vim.list_extend(args, { Config.search_regex(keywords_filter(opts.keywords)), opts.cwd })

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
  opts.open = (opts.open ~= nil and { opts.open } or { true })[1]
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
      Highlight.attach(win.winid, true)
    end
  end, opts)
end

return M
