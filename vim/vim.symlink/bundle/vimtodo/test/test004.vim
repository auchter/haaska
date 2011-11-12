"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Test in file settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" We create the settings entries first because we are testing functionality
" that occurs when the plugin is loaded
insert
:SETTINGS:
    +DONEFILE: done2.txt
    +LOGDONE: 0
    +LOGDRAWER: ALTERNATE
    +STATES: TODO INPROGRESS | DONE
    +STATES: WAITING(w) FOO(f) | BAR(b)
    +STATECOLORS: TODO:green, DONE : blue
    +STATECOLORS: INPROGRESS: magenta , FOO:red
    +CHECKBOXSTATES: A B C
    +CHECKBOXSTATES: 1 2 3
    +TASKURL: http://www.google.com/%s
    +BROWSER: firefox
.

source setup_tests.inc
call vimtap#Plan(8)

call vimtap#Is(g:todo_log_done, 0, "LOGDONE")
call vimtap#Is(g:todo_log_into_drawer, "ALTERNATE", "LOGDRAWER")
call vimtap#Is(g:todo_done_file, "done2.txt", "DONEFILE")
call vimtap#Is(g:todo_states, [["TODO", "INPROGRESS", "|", "DONE"],
            \["WAITING(w)", "FOO(f)", "|", "BAR(b)"]], "STATES")
call vimtap#Is(g:todo_state_colors, { "TODO": "green", "DONE": "blue",
            \ "INPROGRESS": "magenta", "FOO": "red" }, "STATECOLORS")
call vimtap#Is(g:todo_checkbox_states, [["A", "B", "C"], ["1", "2", "3"]],
            \ "CHECKBOXSTATES")
call vimtap#Is(g:todo_taskurl, "http://www.google.com/%s", "TASKURL")
call vimtap#Is(g:todo_browser, "firefox", "BROWSER")

call vimtest#Quit()
