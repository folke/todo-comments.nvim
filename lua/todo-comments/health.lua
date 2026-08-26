local Config = require("todo-comments.config")

local M = {}

local health = vim.health or require("health")
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local warn = health.warn or health.report_warn
local error = health.error or health.report_error
local info = health.info or health.report_info

function M.check()
  start("todo-comments.nvim")

  if not Config.loaded then
    pcall(Config._setup)
  end

  -- 1. Neovim Version Check
  if vim.fn.has("nvim-0.8.0") == 1 then
    ok("Neovim >= 0.8.0")
  else
    error("Neovim >= 0.8.0 is required. Current version is older.")
  end

  -- 2. Ripgrep (rg) Check
  local rg_cmd = (Config.options.search and Config.options.search.command) or "rg"
  if vim.fn.executable(rg_cmd) == 1 then
    ok(string.format("Search command '%s' is installed and executable in $PATH", rg_cmd))
  else
    warn(
      string.format("Search command '%s' was not found in $PATH.", rg_cmd),
      {
        "Install ripgrep: https://github.com/BurntSushi/ripgrep",
        "Or disable search commands / configure a different search tool in 'search.command'.",
      }
    )
  end

  -- 3. Required / Optional Plugins
  local plenary_ok = pcall(require, "plenary")
  if plenary_ok then
    ok("plenary.nvim is installed")
  else
    warn("plenary.nvim is not installed. Global search and module reloading require plenary.nvim.")
  end

  local telescope_ok = pcall(require, "telescope")
  if telescope_ok then
    ok("telescope.nvim is installed (Telescope picker integration active)")
  else
    info("telescope.nvim is not installed (optional). Install 'nvim-telescope/telescope.nvim' for interactive search pickers.")
  end

  local trouble_ok = pcall(require, "trouble")
  if trouble_ok then
    ok("trouble.nvim is installed (Trouble list integration active)")
  else
    info("trouble.nvim is not installed (optional). Install 'folke/trouble.nvim' for diagnostics and todo lists.")
  end

  local fzf_ok = pcall(require, "fzf-lua")
  if fzf_ok then
    ok("fzf-lua is installed (FZF picker integration active)")
  else
    info("fzf-lua is not installed (optional).")
  end

  local ts_ok = pcall(require, "nvim-treesitter")
  if ts_ok then
    ok("nvim-treesitter is installed (tree-sitter comment parsing active)")
  else
    info("nvim-treesitter is not installed (optional). Fallback to standard comment matching.")
  end

  -- 4. Feature Configuration Status
  local tasks_enabled = Config.options.tasks and Config.options.tasks.enabled
  if tasks_enabled then
    ok("Task checkboxes and progress tracking: ENABLED (TODO checklists: [ ], [/], [x])")
  else
    info("Task checkboxes and progress tracking: DISABLED ('tasks = { enabled = false }')")
  end

  local folding_enabled = Config.options.highlight and Config.options.highlight.folding and Config.options.highlight.folding.enabled
  if folding_enabled then
    ok("Multiline comment folding: ENABLED (:TodoToggleFold)")
  else
    info("Multiline comment folding: DISABLED ('highlight.folding = { enabled = false }')")
  end

  local search_badges = Config.options.search and Config.options.search.badges ~= false
  if search_badges then
    ok("Search picker badges ([N/M], [+N lines]): ENABLED")
  else
    info("Search picker badges: DISABLED ('search = { badges = false }')")
  end
end

return M
