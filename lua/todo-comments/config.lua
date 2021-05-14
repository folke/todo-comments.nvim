local Util = require("todo-comments.util")

--- @class TodoConfig
local M = {}

M.keywords = {}
--- @type TodoOptions
M.options = {}
M.loaded = false

M.ns = vim.api.nvim_create_namespace("todo-comments")

--- @class TodoOptions
-- TODO: add support for markdown todos
local defaults = {
  signs = true, -- show icons in the signs column
  -- keywords recognized as todo comments
  keywords = {
    FIX = {
      icon = " ", -- icon used for the sign, and in search results
      color = "error", -- can be a hex color, or a named color (see below)
      alt = { "FIXME", "BUG", "FIXIT", "FIX", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
      -- signs = false, -- configure signs for some keywords individually
    },
    TODO = { icon = " ", color = "info" },
    HACK = { icon = " ", color = "warning" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
  },
  -- highlighting of the line containing the todo comment
  -- * before: highlights before the keyword (typically comment characters)
  -- * keyword: highlights of the keyword
  -- * after: highlights after the keyword (todo text)
  highlight = {
    before = "", -- "fg" or "bg" or empty
    keyword = "wide", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
    after = "fg", -- "fg" or "bg" or empty
  },
  -- list of named colors where we try to extract the guifg from the
  -- list of hilight groups or use the hex color if hl not found as a fallback
  colors = {
    error = { "LspDiagnosticsDefaultError", "ErrorMsg", "#DC2626" },
    warning = { "LspDiagnosticsDefaultWarning", "WarningMsg", "#FBBF24" },
    info = { "LspDiagnosticsDefaultInformation", "#2563EB" },
    hint = { "LspDiagnosticsDefaultHint", "#10B981" },
    default = { "Identifier", "#7C3AED" },
  },
  -- regex that will be used to match keywords.
  -- don't replace the (KEYWORDS) placeholder
  pattern = "(KEYWORDS):",
  -- pattern = "(KEYWORDS)", -- match without the extra colon. You'll likely get false positives
  -- pattern = "-- (KEYWORDS):", -- only match in lua comments
}

M._options = nil

function M.setup(options)
  M._options = options
  -- lazy load setup after VimEnter
  if vim.api.nvim_get_vvar("vim_did_enter") == 0 then
    vim.cmd([[autocmd VimEnter * ++once lua require("todo-comments.config")._setup()]])
  else
    M._setup()
  end
end

function M._setup()
  M.options = vim.tbl_deep_extend("force", {}, defaults, M._options or {})

  -- keywords should always be fully overriden
  if M._options and M._options.keywords then
    M.options.keywords = M._options.keywords
  end

  for kw, opts in pairs(M.options.keywords) do
    M.keywords[kw] = kw
    for _, alt in pairs(opts.alt or {}) do
      M.keywords[alt] = kw
    end
  end
  local tags = table.concat(vim.tbl_keys(M.keywords), "|")
  M.rg_regex = M.options.pattern:gsub("KEYWORDS", tags)
  M.colors()
  M.signs()
  if vim.fn.executable('rg') == 1 then
    require("todo-comments.commands")
  else
    Util.warn("Missing ripgrep, commands are not available")
  end
  require("todo-comments.highlight").start()
  M.loaded = true
end

function M.signs()
  for kw, opts in pairs(M.options.keywords) do
    vim.fn.sign_define("todo-sign-" .. kw, {
      text = opts.icon,
      texthl = "TodoSign" .. kw,
    })
  end
end

function M.colors()
  local normal = Util.get_hl("Normal")
  local fg_dark = Util.is_dark(normal.foreground or "#ffffff") and normal.foreground or normal.background
  local fg_light = Util.is_dark(normal.foreground or "#ffffff") and normal.background or normal.foreground
  fg_dark = fg_dark or "#000000"
  fg_light = fg_light or "#ffffff"

  local sign_hl = Util.get_hl("SignColumn")
  local sign_bg = (sign_hl and sign_hl.background) and sign_hl.background or "NONE"

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
    if not hex then
      error("Todo: no color for " .. kw)
    end
    local fg = Util.is_dark(hex) and fg_light or fg_dark

    vim.cmd("hi def TodoBg" .. kw .. " guibg=" .. hex .. " guifg=" .. fg .. " gui=bold")
    vim.cmd("hi def TodoFg" .. kw .. " guibg=NONE guifg=" .. hex .. " gui=NONE")
    vim.cmd("hi def TodoSign" .. kw .. " guibg=" .. sign_bg .. " guifg=" .. hex .. " gui=NONE")
  end
end

return M
