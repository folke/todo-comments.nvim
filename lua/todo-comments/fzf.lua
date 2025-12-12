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

---@param opts? {keywords: string[], cwd: string, user_args: string}
function M.todo(opts)
  --- `opts.user_args` being set implies that the call was made through the `TodoFzfLua` user command defined in "plugin/todo.vim". In that case, we must parse the arguments accordingly.
  if opts and opts.user_args then
    for _, arg_str in ipairs(vim.split(opts.user_args, " ")) do
      local k, v = table.unpack(vim.split(arg_str, "="))
      if k == "keywords" then
        opts.keywords = vim.split(v, ",")
      elseif k == "cwd" then
        opts.cwd = v
      end
    end
    opts.user_args = nil
  end
  opts = vim.tbl_extend("force", {
    no_esc = true,
    multiline = true,
  }, opts or {})
  opts.no_esc = true
  opts.search = Config.search_regex(keywords_filter(opts.keywords))
  return Grep.grep(opts)
end

return M
