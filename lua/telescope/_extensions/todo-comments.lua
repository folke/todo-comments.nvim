local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugins requires nvim-telescope/telescope.nvim")
end

local pickers = require("telescope.builtin")
local Config = require("todo-comments.config")
local Highlight = require("todo-comments.highlight")
local make_entry = require("telescope.make_entry")

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
    ret.display = function(entry)
      local display = string.format("%s:%s:%s ", entry.filename, entry.lnum, entry.col)
      local text = entry.text
      local start, finish, kw = Highlight.match(text)

      local hl = {}

      if start then
        kw = Config.keywords[kw] or kw
        local icon = Config.options.keywords[kw].icon
        display = icon .. " " .. display
        table.insert(hl, { { 1, #icon + 1 }, "TodoFg" .. kw })
        text = vim.trim(text:sub(start))

        table.insert(hl, {
          { #display, #display + finish - start + 2 },
          "TodoBg" .. kw,
        })
        table.insert(hl, {
          { #display + finish - start + 1, #display + finish + 1 + #text },
          "TodoFg" .. kw,
        })
        display = display .. " " .. text
      end

      return display, hl
    end
    return ret
  end
  pickers.grep_string(opts)
end

return telescope.register_extension({ exports = { ["todo-comments"] = todo, todo = todo } })
