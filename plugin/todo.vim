
command! -nargs=* TodoQuickFix lua require("todo-comments.search").setqflist(<f-args>)
command! -nargs=* TodoLocList lua require("todo-comments.search").setloclist(<f-args>)
command! -nargs=* TodoTelescope Telescope todo-comments todo <args>
command! -nargs=* TodoTrouble Trouble todo <args>
