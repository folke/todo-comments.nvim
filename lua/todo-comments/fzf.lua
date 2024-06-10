local Config = require("todo-comments.config")
local Grep = require("fzf-lua.providers.grep")
local utils = require("fzf-lua.utils")

local M = {}

---@param opts_keywords? string|string[]
local function keywords_filter(opts_keywords)
  local all_keywords = vim.tbl_keys(Config.keywords)
  if not opts_keywords then
    return all_keywords
  end
  local filters = type(opts_keywords) == "string" and { opts_keywords } or opts_keywords
  return vim.tbl_filter(function(kw)
    return vim.tbl_contains(filters, kw)
  end, all_keywords)
end

---@param opts? {keywords: string[]}
function M.todo(opts)
  if not opts then
    opts = {}
  end
  opts.no_esc = true
  -- match whole words only (#968)
  opts.search = [[\b]] .. utils.rg_escape(vim.fn.expand("<cword>")) .. [[\b]]
  opts.search = Config.search_regex(keywords_filter(opts.keywords))
  return Grep.grep(opts)
end

return M
