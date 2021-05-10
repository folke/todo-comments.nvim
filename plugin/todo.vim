
command! TodoQuickFix lua require("todo-comments.search").setqflist()
command! TodoTelescope Telescope todo-comments todo
command! TodoTrouble LspTrouble todo
