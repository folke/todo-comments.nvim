local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  return {}
end

local Config = require("todo-comments.config")
local Highlight = require("todo-comments.highlight")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.builtin")

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

local function todo(opts)
  opts = opts or {}
  opts.vimgrep_arguments = { Config.options.search.command }
  vim.list_extend(opts.vimgrep_arguments, Config.options.search.args)

  opts.search = Config.search_regex(keywords_filter(opts.keywords))
  opts.prompt_title = "Find Todo"
  opts.use_regex = true
  local entry_maker = make_entry.gen_from_vimgrep(opts)
  opts.entry_maker = function(line)
    local ret = entry_maker(line)
    ret.display = function(entry, picker)
      local text = entry.text
      local start, finish, kw = Highlight.match(text)

      if not start then
        return text, {}
      end

      kw = Config.keywords[kw] or kw
      local icon = Config.options.keywords[kw].icon or " "
      local pos_info = string.format("%s:%s:%s ", entry.filename, entry.lnum, entry.col)
      local tag_str = vim.trim(text:sub(start, finish))
      local msg_str = vim.trim(text:sub(finish + 1))

      -- Progress & Context badges (Configurable and defensive)
      local prog_str = ""
      local lines_str = ""
      local search_badges = Config.options.search and Config.options.search.badges ~= false

      if search_badges then
        local ok_tasks, Tasks = pcall(require, "todo-comments.tasks")
        local stats = { total = 0, done = 0, doing = 0, lines = 0 }
        if ok_tasks and Tasks and Tasks.get_block_stats then
          local s_ok, s_res = pcall(Tasks.get_block_stats, entry.filename, entry.lnum, start, kw)
          if s_ok and s_res then
            stats = s_res
          end
        end

        local header_tasks = 0
        local header_done = 0
        local tasks_opts = Config.options.tasks
        if kw == "TODO" and tasks_opts and tasks_opts.enabled then
          for state, cb_cfg in pairs(tasks_opts.checkboxes) do
            local cb_s = text:find(cb_cfg.pattern)
            if cb_s then
              local before = text:sub(1, cb_s - 1)
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
                header_tasks = 1
                if state == "done" then
                  header_done = 1
                end
                break
              end
            end
          end
        end

        local total = header_tasks + stats.total
        local done = header_done + stats.done

        if kw == "TODO" and total > 0 and tasks_opts and tasks_opts.enabled and tasks_opts.progress and tasks_opts.progress.enabled ~= false then
          local p_opts = tasks_opts.progress
          local parts = {}
          if p_opts.show_count ~= false then
            table.insert(parts, string.format(p_opts.count_format or "%d/%d", done, total))
          end
          if p_opts.show_percent == true then
            local pct = math.floor((done / total) * 100)
            table.insert(parts, string.format(p_opts.percent_format or "(%d%%)", pct))
          end
          if #parts > 0 then
            prog_str = " [" .. table.concat(parts, " ") .. "]"
          end
        end

        local hl_opts = Config.options.highlight
        if stats.lines > 0 and hl_opts and hl_opts.context and hl_opts.context.enabled ~= false then
          lines_str = string.format(" [+%d lines]", stats.lines)
        end
      end
      local suffix = prog_str .. lines_str

      -- Available width inside the Telescope results window
      local win_w = 80
      if picker and picker.results_win and vim.api.nvim_win_is_valid(picker.results_win) then
        win_w = vim.api.nvim_win_get_width(picker.results_win)
      elseif vim.api.nvim_win_is_valid(0) then
        win_w = vim.api.nvim_win_get_width(0)
      end
      local max_w = math.max(20, win_w - 2)

      local prefix_str = icon .. " " .. pos_info
      local tag_with_space = tag_str .. " "
      local fixed_w = vim.api.nvim_strwidth(prefix_str) + vim.api.nvim_strwidth(tag_with_space) + vim.api.nvim_strwidth(suffix)
      local msg_w = vim.api.nvim_strwidth(msg_str)

      if fixed_w + msg_w > max_w then
        local avail_for_msg = max_w - fixed_w - 3 -- 3 for ellipsis "..."
        if avail_for_msg > 0 then
          msg_str = vim.fn.strcharpart(msg_str, 0, avail_for_msg) .. "..."
        else
          msg_str = "..."
        end
      end

      local hl = {}
      local display = ""

      -- 1. Keyword icon
      local icon_start = #display
      display = display .. icon .. " "
      table.insert(hl, { { icon_start, #display }, "TodoFg" .. kw })

      -- 2. File position (filename:lnum:col)
      display = display .. pos_info

      -- 3. Keyword tag with background highlight (TodoBg)
      local tag_start = #display
      display = display .. tag_str
      table.insert(hl, { { tag_start, #display }, "TodoBg" .. kw })
      display = display .. " "

      -- 4. Comment message
      local msg_start = #display
      display = display .. msg_str
      table.insert(hl, { { msg_start, #display }, "TodoFg" .. kw })

      -- 5. Task progress badge [N/M]
      if prog_str ~= "" then
        local prog_start = #display
        display = display .. prog_str
        table.insert(hl, { { prog_start, #display }, "TodoProgressRatio" })
      end

      -- 6. Multiline context lines badge [+N lines]
      if lines_str ~= "" then
        local lines_start = #display
        display = display .. lines_str
        table.insert(hl, { { lines_start, #display }, "TodoContextInfo" })
      end

      return display, hl
    end
    return ret
  end
  pickers.grep_string(opts)
end

return telescope.register_extension({ exports = { ["todo-comments"] = todo, todo = todo } })
