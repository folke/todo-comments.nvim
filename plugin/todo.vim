command! -nargs=* TodoQuickFix lua require("todo-comments.search").setqflist(<q-args>)
command! -nargs=* TodoLocList lua require("todo-comments.search").setloclist(<q-args>)
command! -nargs=* TodoTelescope Telescope todo-comments todo <args>
command! -nargs=* TodoFzfLua lua require("todo-comments.fzf").todo() <args>
command! -nargs=* TodoTrouble Trouble todo <args>
