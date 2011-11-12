" Vim filetype plugin for heirarchical TODO lists
" Maintainer:   Mark Harrison <mark@mivok.net>
" Last Change:  Oct 2, 2010
" License:      ISC - See LICENSE file for details

" This file has folded functions - Use zR to show all source code if you
" aren't familiar with folding in vim.

" Only load if we haven't already {{{1
if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1
"1}}}
" Make sure we aren't running in compatible mode {{{1
let s:save_cpo = &cpo
set cpo&vim
"1}}}

" Utility Functions
" s:Map - mapping helper function {{{1
function! s:Map(keys, funcname)
    if !hasmapto('<Plug>Todo'.a:funcname)
        exe "map <buffer> <silent> <unique> <LocalLeader>".a:keys.
                    \" <Plug>Todo".a:funcname
    endif
    exe "noremap <buffer> <silent> <unique> <script> <Plug>Todo".a:funcname.
                \" <SID>".a:funcname
    exe "noremap <buffer> <silent> <SID>".a:funcname." :call <SID>".
                \a:funcname."()<CR>"
endfunction
"1}}}
" s:NewScratchBuffer - Create a new buffer {{{1
function! s:NewScratchBuffer(name, split)
    if a:split
        split
    endif
    " Set the buffer name
    let name="[".a:name."]"
    if !has("win32")
        let name = escape(name, "[]")
    endif
    " Switch buffers
    if has("gui")
        exec "silent keepjumps drop" name
    else
        exec "silent keepjumps hide edit" name
    endif
    " Set the new buffer properties to be a scrach buffer
    setlocal bufhidden=delete
    setlocal buftype=nofile
    setlocal modifiable " This needs to be changed once the buffer has stuff in
    setlocal noswapfile
    setlocal nowrap     " This can be changed if needed
endfunction
"1}}}
" s:GetState - Gets the state for a line, and its index {{{1
function! s:GetState(line)
    let line=getline(a:line)
    let regex="\\(^\\s*\\)\\@<=[A-Z]\\+\\(\\s\\|$\\)\\@="
    let idx=match(line, regex)
    let state=matchstr(line, regex)
    return [state, idx]
endfunction
"1}}}
" s:IsDoneState - Tests if a state is considered 'done' {{{1
function! s:IsDoneState(state)
    for group in g:todo_states
        let idx = index(group, "|")
        if idx == len(group)
            continue
        elseif idx != -1
            let idx = idx + 1
        endif
        " Note, having idx set to -1 (when there is no |) means we will be
        " looking at the last item, which is the desired behavior.
        for teststate in group[idx+0:]
            if vimtodo#TodoParseTaskState(teststate)["state"] == a:state
                return 1
            endif
        endfor
    endfor
    return 0
endfunction
"1}}}
" s:GetDoneStates - Returns a list of all done states {{{1
function! s:GetDoneStates()
    let states = []
    for group in g:todo_states
        let idx = index(group, "|")
        if idx == len(group)
            continue
        elseif idx != -1
            let idx = idx + 1
        endif
        for state in group[idx :]
            call add(states, vimtodo#TodoParseTaskState(state)['state'])
        endfor
    endfor
    return states
endfunction
"1}}}
" s:ParseDate {{{1
" Parses A string of the form YYYY-MM-DD into an integer for comparison
" purposes. Supports YYYY-M-D formats too
function! s:ParseDate(datestr)
    let ml = matchlist(a:datestr,
                \'\(\d\{4\}\)-\(\d\{1,2\}\)-\(\d\{1,2\}\)')
    if ml == []
        return 0
    endif
    let [y, m, d] = ml[1:3]
    return str2nr(printf("%d%02d%02d", y,m,d))
endfunction
" 1}}}
" Drawer Functions
" s:FindDrawer {{{1
function! s:FindDrawer(name, line)
    let line=a:line
    " Strings will evaluate to 0 - so process it with the line function if we
    " have a string.
    if line == 0
        let line = line(line)
    endif
    if line == -1
        " -1 means look for a top-level drawer
        let topindent = -1
        let indent = 0
        let line += 1
    else
        " Look for a drawer inside the current entry
        let topindent = indent(line)
        let line=line + 1
        let indent = indent(line)
    endif
    while indent(line) > topindent
        if indent(line) == indent &&
                    \ match(getline(line), '^\s*:'.toupper(a:name).':') != -1
            return line
        endif
        let line = line + 1
    endwhile
    return -1
endfunction
"1}}}
" s:FindOrMakeDrawer {{{1
function! s:FindOrMakeDrawer(name, line)
    let line = s:FindDrawer(a:name, a:line)
    if line != -1
        return line
    endif
    let topindent = indent(".")
    let indent = indent(line(".") + 1)
    if indent <= topindent
        let indent = topindent + &shiftwidth
    endif
    let indentstr=printf("%".indent."s", "") " generate indent spaces
    call append(line("."), indentstr.":".toupper(a:name).":")
    return line(".")+1
endfunction
"1}}}
" s:GetNextProperty {{{1
function! s:GetNextProperty(drawerline, propertyline)
    let indent = indent(a:drawerline)
    let propindent = indent(a:propertyline)
    if propindent <= indent
        " We exited the drawer, return nothing
        return ["",""]
    endif
    let match = matchlist(getline(a:propertyline),
                \'^\s\++\([A-Z]\+\):\s\?\(.*\)$')
    if match != []
        return match[1:2]
    else
        return ["",""]
    endif
endfunction
" 1}}}

" Settings
" Load default variables {{{1
call vimtodo#SetDefaultVars()
"1}}}
" Per file variables {{{1
let s:PropertyVars = {
            \'LOGDONE':         'g:todo_log_done',
            \'LOGDRAWER':       'g:todo_log_into_drawer',
            \'DONEFILE':        'g:todo_done_file',
            \'STATES':          'g:todo_states',
            \'STATECOLORS':     'g:todo_state_colors',
            \'CHECKBOXSTATES':  'g:todo_checkbox_states',
            \'TASKURL':         'g:todo_taskurl',
            \'BROWSER':         'g:todo_browser'
            \}
let s:PropertyTypes = {
            \'STATES':          'nestedlist',
            \'STATECOLORS':     'dict',
            \'CHECKBOXSTATES':  'nestedlist'
            \}
function! s:LoadFileVars()
    let drawerline=s:FindDrawer("SETTINGS", 0)
    if drawerline == -1
        return
    endif
    let propertyline=drawerline + 1
    let [name, val] = s:GetNextProperty(drawerline, propertyline)
    " Keep track of which variables have already been wiped - list/dict vars
    " need the original value overwriting for the first settings line, but
    " then have values appended for subsequent lines
    let wiped = {}
    while name != ""
        " Look up a name to variable mapping
        if has_key(s:PropertyVars, name)
            let type = get(s:PropertyTypes, name, "normal")
            if type == "normal"
                exe "let" s:PropertyVars[name]."=val"
            elseif type == "dict"
                if !has_key(wiped, name)
                    " Wipe the original value if needed
                    let wiped[name] = 1
                    exe "let" s:PropertyVars[name]."={}"
                endif
                let parts = split(val, ',')
                for part in parts
                    let [k,v] = split(part, ':')
                    " Strip spaces
                    let k = matchlist(k, '^\s*\(.*\S\)\s*$')[1]
                    let v = matchlist(v, '^\s*\(.*\S\)\s*$')[1]
                    exe "let" s:PropertyVars[name]."[k]=v"
                endfor
            elseif type == "nestedlist"
                if !has_key(wiped, name)
                    " Wipe the original value if needed
                    let wiped[name] = 1
                    exe "let" s:PropertyVars[name]."=[]"
                endif
                let parts = split(val, '\s\+')
                exe "call add("s:PropertyVars[name].",parts)"
            elseif type == "list"
                if !has_key(wiped, name)
                    " Wipe the original value if needed
                    let wiped[name] = 1
                    exe "let" s:PropertyVars[name]."=[]"
                endif
                let parts = split(val, '\s\+')
                exe "call extend("s:PropertyVars[name].",parts)"
            endif
        endif
        let propertyline += 1
        let [name, val] = s:GetNextProperty(drawerline, propertyline)
    endwhile
endfunction
call s:LoadFileVars()
" 1}}}
" Folding support {{{1
setlocal foldmethod=indent
setlocal foldtext=getline(v:foldstart).\"\ ...\"
setlocal fillchars+=fold:\ 
" 1}}}
" Mappings {{{1
call s:Map("cb", "InsertCheckbox")
call s:Map("cc", "CheckboxToggle")
call s:Map("cv", "PromptTaskState")
call s:Map("cs", "NextTaskState")
call s:Map("ct", "LoadTaskLink")
call s:Map("cl", "LoadLink")
call s:Map("ca", "ArchiveDone")
"1}}}

" Todo entry macros
" ds - Datestamp {{{1
iab ds <C-R>=strftime("%Y-%m-%d")<CR>
" cn, \cn - New todo entry {{{1
exe 'map <LocalLeader>cn o'.vimtodo#TodoParseTaskState(
            \g:todo_states[0][0])["state"].' ds '
exe 'iab cn '.vimtodo#TodoParseTaskState(g:todo_states[0][0])["state"].
            \' <C-R>=strftime("%Y-%m-%d")<CR>'
"1}}}

" Checkboxes
" s:InsertCheckbox {{{1
" Make a checkbox at the beginning of the line, removes any preceding bullet
" point dash
function! s:InsertCheckbox()
    echo "Insert checkbox"
    if match(getline('.'), '^\s*\[.\]') == -1
        let oldpos=getpos(".")
        s/^\(\s*\)\?\(- \)\?/\1[ ] /
        call setpos(".", oldpos)
    endif
endfunction
"1}}}
" s:CheckboxToggle {{{1
function! s:CheckboxToggle()
    echo "Toggle checkbox"
    let line=getline(".")
    let idx=match(line, "\\[[^]]\\]")
    if idx != -1
        for group in g:todo_checkbox_states
            let stateidx = 0
            while stateidx < len(group)
                if group[stateidx] == line[idx+1]
                    let stateidx=stateidx + 1
                    if stateidx >= len(group)
                        let stateidx = 0
                    endif
                    let val=group[stateidx]
                    let parts=[line[0:idx],line[idx+2:]]
                    call setline(".", join(parts, val))
                    return
                endif
                let stateidx=stateidx + 1
            endwhile
        endfor
    endif
endfunction
"1}}}

" Task status
" s:NextTaskState {{{1
function! s:NextTaskState()
    echo "Next task state"
    let [oldstate, idx] = s:GetState(".")
    if idx != -1
        for group in g:todo_states
            let stateidx = 0
            while stateidx < len(group)
                let teststate = vimtodo#TodoParseTaskState(group[stateidx]
                    \)["state"]
                if teststate == oldstate
                    let stateidx=(stateidx + 1) % len(group)
                    " Skip | separator
                    if group[stateidx] == "|"
                        let stateidx=(stateidx + 1) % len(group)
                    endif
                    let val=vimtodo#TodoParseTaskState(
                        \group[stateidx])["state"]
                    call s:SetTaskState(val, oldstate, idx)
                    return
                endif
                let stateidx=stateidx + 1
            endwhile
        endfor
    endif
endfunction
"1}}}
" s:PromptTaskState {{{1
function! s:PromptTaskState()
    let [oldstate, idx] = s:GetState(".")
    call s:NewScratchBuffer("StateSelect", 1)
    call append(0, "Pick the new task state")
    let statekeys = {}
    for group in g:todo_states
        let promptlist = []
        for statestr in group
            if statestr == "|"
                continue
            endif
            let state = vimtodo#TodoParseTaskState(statestr)
            if state["key"] != ""
                call add(promptlist, state["state"]." (".state["key"].")")
                let statekeys[state["key"]] = state["state"]
            endif
        endfor
        if len(promptlist)
            call append(line("$"), "    ".join(promptlist, ", "))
        endif
    endfor
    echo
    for key in keys(statekeys)
        exe "nnoremap <buffer> <silent> ".key.
                    \" :call <SID>SelectTaskState(\"".statekeys[key]."\"".
                    \",\"".oldstate."\",".idx.")<CR>"
    endfor
    call append(line("$"), "    Press Backspace to remove any existing state")
    exe "nnoremap <buffer> <silent> <BS> :call <SID>SelectTaskState(".
                \'"","'.oldstate.'", '.idx.')<CR>'
    call append(line("$"), "    Press Space to cancel")
    nnoremap <buffer> <silent> <Space> :bd<CR>
    setlocal nomodifiable " Make the buffer read only
endfunction
"1}}}
" s:SelectTaskState {{{1
function! s:SelectTaskState(state, oldstate, idx)
    bdelete
    call s:SetTaskState(a:state, a:oldstate, a:idx)
endfunction
"1}}}
" s:SetTaskState {{{1
function! s:SetTaskState(state, oldstate, idx)
    let line = getline(".")
    if a:idx > 0
        let parts=[line[0:a:idx-1],line[a:idx+len(a:oldstate):]]
    elseif a:idx == -1
        let parts=["", " ".line]
    else
        let parts=["",line[len(a:oldstate):]]
    endif
    if a:state != ""
        call setline(".", join(parts, a:state))
    else
        " Remove the state
        call setline(".", join(parts, "")[1:])
    endif
    " Logging code
    " Log all states
    if g:todo_log_into_drawer != ""
        let log=a:state
        if log != "" " Don't log removing a state
            let drawerline = s:FindOrMakeDrawer(g:todo_log_into_drawer, ".")
            call append(drawerline,
                        \ matchstr(getline(drawerline), "^\\s\\+").
                        \repeat(" ", &shiftwidth).
                        \log.": ".strftime("%Y-%m-%d %H:%M:%S"))
        endif
    endif
    " Logging done time
    if g:todo_log_done == 1
        let nextline = line(".") + 1
        let closedregex = '^\s\+CLOSED:'
        if s:IsDoneState(a:state)
            let closedstr = matchstr(getline("."), "^\\s\\+").
                        \ repeat(" ",&shiftwidth).
                        \ "CLOSED: ".strftime("%Y-%m-%d %H:%M:%S")
            " Set the CLOSED: status line
            if getline(nextline) !~ closedregex
                " Preserve whether the fold was open or closed for the
                " appended line
                let foldclosed = foldclosed(line(".") + 1)
                call append(".", closedstr)
                if foldclosed == -1
                    normal jzok
                endif
            else
                call setline(nextline, closedstr)
            endif
        else
            " Delete any CLOSED: status line if it exists
            if getline(nextline) =~ closedregex
                if foldclosed(nextline) == -1
                    " Need to temporarily open the fold if it is closed
                    normal jddk
                else
                    " Delete next line
                    normal jzoddzck
                endif
            endif
        endif
    endif
endfunction
"1}}}

" Task Links
" s:LoadTaskLink {{{1
"   Provides a link to a web based task manager
"   Need to set the todo_taskurl and todo_browser variables in .vimrc
"   E.g.
"   let todo_browser="gnome-open"
"   let todo_taskurl="http://www.example.com/tasks/?id=%s"
"   (The %s will be replaced with the task id)
function! s:LoadTaskLink()
    let tid=matchstr(getline("."), "tid\\d\\+")
    if tid != ""
        let tid = matchstr(tid, "\\d\\+")
        let taskurl = substitute(g:todo_taskurl, "%s", tid, "")
        call system(g:todo_browser . " " . taskurl)
        echo "Loading Task"
    else
        echo "No Task ID found"
    endif
endfunction
"1}}}
" s:LoadLink - URL Opening {{{1
" Uses todo_browser
function! s:LoadLink()
    let url=matchstr(getline("."), "https\\?://\\S\\+")
    if url != ""
        call system(g:todo_browser . " " . url)
        echo "Loading URL"
    else
        echo "No URL Found"
    endif
endfunction
"1}}}

" Task searching
" s:TaskSearch {{{1
" daterange should be a list - [start, end] where start, end are numbers
" relative to today (0 = today, 1 = tomorrow, -1 = yesterday, -7 = this time
" last week). Use a blank list to not filter by date.
function! s:TaskSearch(daterange, ...)
    " Get comparable versions of the dates
    if a:daterange != []
        let startdate = str2nr(strftime(
                    \"%Y%m%d", localtime() + a:daterange[0] * 86400))
        let enddate = str2nr(strftime(
                    \"%Y%m%d", localtime() + a:daterange[1] * 86400))
    endif
    " Use vimgrep to find any task header lines
    if exists("g:todo_files")
        " Clear any existing list - we're using vimgrepadd
        call setloclist(0, [])
        for f in g:todo_files
            try
                exe 'lvimgrepadd /^\s*[A-Z]\+\s/j '.f
            catch /^Vim(\a\+):E480:/
            endtry
        endfor
    else
        try
            lvimgrep /^\s*[A-Z]\+\s/j %
        catch /^Vim(\a\+):E480:/
        endtry
    endif
    let results = []
    " Now filter these
    for d in getloclist(0)
        let matched = 1
        for pat in a:000
            if match(d.text, pat) == -1
                let matched = 0
            endif
        endfor
        if a:daterange != []
            " Filter by date
            let date = s:ParseDate(matchstr(d.text,
                        \'{\d\{4\}-\d\{1,2\}-\d\{1,2\}}'))
            if date < startdate
                let matched = 0
            endif
            if date > enddate
                let matched = 0
            endif
        endif
        if matched
            call add(results, d)
        endif
    endfor
    " Replace the results with the filtered results
    call setloclist(0, results, 'r')
    lw
endfunction
" 1}}}
" s:ShowDueTasks {{{1
function! s:ShowDueTasks(start, end)
    " Start/end are number of days relative to today
    " 0 == today, 1 == tomorrow, -1 == yesterday
    " Make start/end the same number for a single say search
    " Generate a regex to exclude all done states
    let donere = '^\s*\('.join(s:GetDoneStates(), '\|').'\)\@!'
    call s:TaskSearch([a:start, a:end], donere)
endfunction
"1}}}
" ShowDueTasks command definitions {{{1
command -buffer Today :call s:ShowDueTasks(0,0)
command -buffer Tomorrow :call s:ShowDueTasks(1,1)
command -buffer Week :call s:ShowDueTasks(0,7)
command -buffer Overdue :call s:ShowDueTasks(-365,-1)

if !hasmapto(':Today')
    map <buffer> <unique> <LocalLeader>cd :Today<CR>
endif
if !hasmapto(':Tomorrow')
    map <buffer> <unique> <LocalLeader>cf :Tomorrow<CR>
endif
if !hasmapto(':Week')
    map <buffer> <unique> <LocalLeader>cw :Week<CR>
endif
if !hasmapto(':Overdue')
    map <buffer> <unique> <LocalLeader>cx :Overdue<CR>
endif
"1}}}
" Task filter command definitions {{{1
command -buffer -nargs=+ Filter :call s:TaskSearch([], <q-args>)
"1}}}

" Task reorganizing
" s:ArchiveDone {{{1
function! s:ArchiveDone()
    let line=0
    let startline=-1 " Start line of a task
    let topstate="" " The state for the toplevel task
    while line < line('$')
        let line = line+1
        let [state, idx] = s:GetState(line)
        if idx == 0 " Start of a new task
            " Archive the old task if it is relevant
            if startline != -1 && s:IsDoneState(topstate)
                " We removed a chunk of text, set our line number correctly
                call s:ArchiveTask(startline, line - 1)
                let line=startline
            endif
            " Set the state for the new task
            let topstate=state
            let startline=line
        endif
    endwhile
    " Deal with the last task
    if startline != -1 && s:IsDoneState(topstate)
        call s:ArchiveTask(startline, line)
    endif
endfunction
" 1}}}
" s:ArchiveTask - Archives a range of lines {{{1
function! s:ArchiveTask(startline, endline)
    if match(g:todo_done_file, '/') == 0 || match(g:todo_done_file, '\~') == 0
        " Absolute path, don't add the current dir
        let filename=g:todo_done_file
    else
        " Non-absolute path
        let filename=fnamemodify(expand("%"),":p:h")."/".g:todo_done_file
    endif
    exe a:startline.",".a:endline."w! >>".filename
    exe a:startline.",".a:endline."d"
endfunction
" 1}}}

" Restore the old compatible mode setting {{{1
let &cpo = s:save_cpo
"1}}}
" vim:foldmethod=marker
