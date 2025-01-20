---@diagnostic disable: inject-field
local Config = require("todo-comments.config")
local Highlight = require("todo-comments.highlight")

---@module 'snacks'

local M = {}

---@class snacks.picker.todo.Config: snacks.picker.grep.Config
---@field keywords? string[]

---@type snacks.picker.todo.Config|{}
M.source = {
  finder = "grep",
  live = false,
  supports_live = true,
  search = function(picker)
    local opts = picker.opts --[[@as snacks.picker.todo.Config]]
    ---@type string[]
    local keywords = vim.tbl_filter(function(kw)
      return Config.keywords[kw]
    end, opts.keywords or vim.tbl_keys(Config.keywords))
    return ({ Config.search_regex(keywords) })[1]
  end,
  ---@param item snacks.picker.Item
  ---@param picker snacks.Picker
  format = function(item, picker)
    local a = Snacks.picker.util.align
    local _, _, kw = Highlight.match(item.text)
    local ret = {} ---@type snacks.picker.Highlights
    if kw then
      kw = Config.keywords[kw] or kw
      local icon = vim.tbl_get(Config.options.keywords, kw, "icon") or ""
      ret[#ret + 1] = { a(icon, 2), "TodoFg" .. kw }
      ret[#ret + 1] = { a(kw, 6, { align = "center" }), "TodoBg" .. kw }
      ret[#ret + 1] = { " " }
    end
    return vim.list_extend(ret, Snacks.picker.format.file(item, picker))
  end,
  previewer = function(ctx)
    Snacks.picker.preview.file(ctx)
    Highlight.highlight_win(ctx.preview.win.win, true)
    Highlight.update()
  end,
}

---@param opts snacks.picker.todo.Config
function M.pick(opts)
  return Snacks.picker.pick("todo", opts)
end

return M
