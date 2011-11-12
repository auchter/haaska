"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Test Archiving
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Absolute path
let currfile=fnameescape(expand('<sfile>:rp'))
let g:todo_done_file=currfile.'.out'
exe 'edit '.currfile.'.in'
source setup_tests.inc
normal \ca
" Relative path
let currfile=fnameescape(expand('<sfile>:rt'))
let g:todo_done_file=currfile.'.out'
exe 'edit! '.currfile.'.in2'
source setup_tests.inc
normal \ca

call vimtest#Quit()
