" Vim filetype plugin for heirarchical TODO lists
" Maintainer:   Mark Harrison <mark@mivok.net>
" License:      ISC - See LICENSE file for details

" Utility functions
" TodoParseTaskState - Parse TODO(t) into state and shortcut key {{{1
function! vimtodo#TodoParseTaskState(state)
    let state=matchstr(a:state, '^[A-Z]\+')
    let key=matchstr(a:state, '\(^[A-Z]\+(\)\@<=[a-zA-Z0-9]\()\)\@=')
    return { "state": state, "key": key }
endfunction
"1}}}

" Default settings
" Set - setup script variables {{{1
function! vimtodo#Set(varname, value)
    if !exists(a:varname)
        exec "let" a:varname "=" string(a:value)
    endif
endfunction
"1}}}

" Default variables {{{1
function! vimtodo#SetDefaultVars()
    call vimtodo#Set("g:todo_states",
        \[["TODO(t)", "|", "DONE(d)", "CANCELLED(c)"],
        \["WAITING(w)", "CLOSED(l)"]])
    call vimtodo#Set("g:todo_state_colors", { "TODO" : "Blue", "DONE": "Green",
        \ "CANCELLED" : "Red", "WAITING": "Yellow", "CLOSED": "Grey" })
    call vimtodo#Set("g:todo_checkbox_states", [[" ", "X"], ["+", "-", "."],
        \["Y", "N", "?"]])
    call vimtodo#Set("g:todo_log_done", 1)
    call vimtodo#Set("g:todo_log_into_drawer", "LOGBOOK")
    call vimtodo#Set("g:todo_done_file", "done.txt")
endfunction
"1}}}
