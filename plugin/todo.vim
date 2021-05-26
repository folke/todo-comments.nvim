
command! -nargs=* TodoQuickFix lua require("todo-comments.search").setqflist(<f-args>)
command! -nargs=* TodoTelescope Telescope todo-comments todo <args>
command! -nargs=* TodoTrouble Trouble todo <args>
