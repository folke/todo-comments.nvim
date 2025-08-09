local Config = require("todo-comments.config")
local Grep = require("fzf-lua.providers.grep")

local M = {}

---@param filter? string|string[]
local function keywords_filter(filter)
  local all = vim.tbl_keys(Config.keywords)
  if not filter then
    return all
  end
  local filters = type(filter) == "string" and { filter } or filter
  return vim.tbl_filter(function(kw)
    return vim.tbl_contains(filters, kw)
  end, all)
end

---@param opts? {keywords: string[]}
function M.todo(opts)
  opts = vim.tbl_extend("force", {
    no_esc = true,
    multiline = true,
  }, opts or {})
  opts.no_esc = true
  opts.search = Config.search_regex(keywords_filter(opts.keywords))
  return Grep.grep(opts)
end

return M
