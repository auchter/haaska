"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Test TODO entry creation macros
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source setup_tests.inc
call vimtap#Plan(2)

" Get Today's date for matching with the auto-generated dates
let today=strftime("%Y-%m-%d")

call vimtap#Diag('TODO entry creation')
normal icn Test Entry
call vimtap#Is(getline('.'), 'TODO '.today.' Test Entry',
            \"TODO entry generated with cn abbreviation")

normal \cn
call vimtap#Is(getline('.'), 'TODO '.today.' ',
            \"TODO entry generated with \cn macro")

call vimtest#Quit()
