" Vim syntax file
" Maintainer:   Mark Harrison <mark@mivok.net>
" Last Change:  Aug 15, 2009
" License:      ISC - See LICENSE file for details

" au BufRead,BufNewFile todo.txt,*.todo.txt,recur.txt,*.todo set filetype=todo

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" Load default variables if not already set
call vimtodo#SetDefaultVars()

syn match       todoProject     /+\S\+/
syn match       todoContext     /\s@\S\+/
syn match       todoPriority    /([A-Z])/
"syn match       todoDone        /^\s*\[\?[xX]\]\?\s.*/

syn match       todoDate        /\w\?{[^}]\+}[+=-]\?/
syn match       todoDate        /\d\{4\}-\d\{2\}-\d\{2\}/
syn match       todoTasknum     /tid\d\+/

syn match       todoURI         /\w\+:\/\/\S\+/
syn match       todoEmail       /\S\+@\S\+\.\S\+/

syn match       todoBold        /\*[^*]\+\*/
syn match       todoUline       /_[^_]\{2,}_/
syn match       todoComment     /\s*#.*$/
syn match       todoLog         /\(^\s*\)\@<=[A-Z]\+:/
syn match       todoDrawer      /\(^\s*\)\@<=:[A-Z]\+:/

hi def link     todoProject     Statement
hi def link     todoContext     Identifier
hi def link     todoPriority    Special
hi def link     todoDone        Comment
hi def link     todoDate        Constant
hi def link     todoTasknum     Number

hi def link     todoBold        PreProc
hi def link     todoUline       PreProc
hi def link     todoComment     Comment
hi def link     todoLog         PreProc
hi def link     todoDrawer      Type

hi def link     todoURI         String
hi def link     todoEmail       String

" Highlight state colors
function! s:HighlightStatus(name, color)
    " Sets the highlight for a particular status to the given color
    let name=toupper(a:name)
    exe "syn match todoState".name." /\\(^\\s*\\)\\@<=".name.
        \":\\?\\(\\s\\|$\\)\\@=/ contains=todoDone"
    exe "hi def todoState".name." guifg=".a:color." ctermfg=".a:color.
        \" gui=bold cterm=bold"
endfunction
for state in keys(g:todo_state_colors)
    call s:HighlightStatus(state, g:todo_state_colors[state])
endfor

" Might want to make this dynamic so we can add 'contains=todoLogDONE' etc.
function! s:HighlightDone()
    for group in g:todo_states
        let idx = index(group, "|")
        if idx != -1
            let idx = idx + 1
        elseif idx == len(group)
            continue
        endif
        let parsed = []
        for state in group[idx+0:]
            call add(parsed, vimtodo#TodoParseTaskState(state)["state"])
        endfor
        let match = join(parsed, "\\|")
        exec "syn region todoDone start=\"^\\z(\\s*\\)\\%(".match."\\)\\s\"".
            \" end=\"^\\%(\\n*\\z1\\s\\)\\@!\"".
            \" contains=todoLog"
    endfor
endfunction
call s:HighlightDone()

let b:current_syntax = "todo"
