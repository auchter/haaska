"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Test TODO state changes
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source setup_tests.inc
call vimtap#Plan(12)

" Regular expression to match a status timestamp
let timestampre='\d\{4\}-\d\{2\}-\d\{2\} \d\{2\}:\d\{2\}:\d\{2\}'

insert
TODO 2009-09-06 Test entry
.

let line=line('.')
let entry='2009-09-06 Test entry'

" Single state change
normal \cs
call vimtap#Is(getline('.'), 'DONE '.entry,
            \"State changed to DONE")
call vimtap#Like(getline(line+1), '^    CLOSED: '.timestampre,
            \"Added CLOSED: tag")
call vimtap#Like(getline(line+2), '^    :LOGBOOK:',
            \"Logbook drawer created")
call vimtap#Like(getline(line+3), '^        DONE: '.timestampre,
            \"Log entry added")
" More state changes
normal \cs
call vimtap#Is(getline('.'), 'CANCELLED '.entry,
            \"State changed to CANCELLED")
call vimtap#Like(getline(line+1), '^    CLOSED: '.timestampre,
            \"CLOSED tag present")
normal \cs
call vimtap#Is(getline('.'), 'TODO '.entry,
            \"State changed back to TODO")
call vimtap#Unlike(getline(line+1), '^    CLOSED: '.timestampre,
            \"CLOSED tag removed")
" Log entries
call vimtap#Is(getline(line+1), '    :LOGBOOK:',
            \"LOGBOOK drawer still present")
call vimtap#Like(getline(line+2), '^        TODO: '.timestampre,
            \"TODO Log entry added")
call vimtap#Like(getline(line+3), '^        CANCELLED: '.timestampre,
            \"CANCELLED Log entry added")
call vimtap#Like(getline(line+4), '^        DONE: '.timestampre,
            \"DONE Log entry still present")

call vimtest#Quit()
