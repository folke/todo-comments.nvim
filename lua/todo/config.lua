local Util = require("todo.util")

--- @class Config
local M = {}

M.keywords = {}
--- @type Options
M.options = {}

M.ns = vim.api.nvim_create_namespace("todo")

--- @class Options
local defaults = {
  colors = {
    error = { "LspDiagnosticsDefaultError", "ErrorMsg", "#DC2626" },
    warning = { "LspDiagnosticsDefaultWarning", "WarningMsg", "#FBBF24" },
    info = { "LspDiagnosticsDefaultInformation", "#2563EB" },
    hint = { "LspDiagnosticsDefaultHint", "#10B981" },
    default = { "Identifier", "#7C3AED" },
  },
  signs = true,
  keywords = {
    TODO = { icon = " ", color = "info" },
    FIX = {
      icon = " ",
      color = "error",
      alt = { "FIXME", "BUG", "FIXIT", "FIX", "ISSUE" },
    },
    HACK = { icon = " ", color = "warning" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
  },
  highlight = {
    before = "", -- "fg" or "bg" or false
    tag = "wide", -- "fg", "bg" or "wide". (wide is the same as bg, but will also highlight surrounding characters)
    after = "fg", -- "fg" or "bg" or false
  },
}

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})

  for kw, opts in pairs(M.options.keywords) do
    M.keywords[kw] = kw
    for _, alt in pairs(opts.alt or {}) do M.keywords[alt] = kw end
  end
  local tags = table.concat(vim.tbl_keys(M.keywords), "|")
  M.rg_regex = "(" .. tags .. "):"
  M.colors()
  M.signs()
end

function M.signs()
  for kw, opts in pairs(M.options.keywords) do
    vim.fn.sign_define("todo-sign-" .. kw,
                       { text = opts.icon, texthl = "TodoFg" .. kw })
  end
end

function M.colors()
  local normal = Util.get_hl("Normal")
  local fg_dark = Util.is_dark(normal.foreground) and normal.foreground or
                    normal.background
  local fg_light = Util.is_dark(normal.foreground) and normal.background or
                     normal.foreground
  for kw, opts in pairs(M.options.keywords) do
    local kw_color = opts.color or "default"
    local hex

    if kw_color:sub(1, 1) == "#" then
      hex = kw_color
    else
      local colors = M.options.colors[kw_color]
      colors = type(colors) == "string" and { colors } or colors

      for _, color in pairs(colors) do
        if color:sub(1, 1) == "#" then
          hex = color
          break
        end
        local c = Util.get_hl(color)
        if c and c.foreground then
          hex = c.foreground
          break
        end
      end
    end
    if not hex then error("Todo: no color for " .. kw) end
    local fg = Util.is_dark(hex) and fg_light or fg_dark

    vim.cmd("hi def TodoBg" .. kw .. " guibg=" .. hex .. " guifg=" .. fg ..
              " gui=bold")
    vim.cmd("hi def TodoFg" .. kw .. " guibg=NONE guifg=" .. hex .. " gui=NONE")
  end
end

return M
