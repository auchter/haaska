"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Test checkboxes
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source setup_tests.inc
call vimtap#Plan(13)

call vimtap#Diag("Normal checkbox")
insert
[ ]
.
normal \cc
call vimtap#Is(getline('.'), '[X]', "Checked box")
normal \cc
call vimtap#Is(getline('.'), '[ ]', "Unchecked box")

call vimtap#Diag("Y/N/? checkbox")
append
[Y]
.
normal \cc
call vimtap#Is(getline('.'), '[N]', "Checkbox - N")
normal \cc
call vimtap#Is(getline('.'), '[?]', "Checkbox - ?")
normal \cc
call vimtap#Is(getline('.'), '[Y]', "Checkbox - Y")

call vimtap#Diag("+/-/. checkbox")
append
[+]
.
normal \cc
call vimtap#Is(getline('.'), '[-]', "Checkbox - -")
normal \cc
call vimtap#Is(getline('.'), '[.]', "Checkbox - .")
normal \cc
call vimtap#Is(getline('.'), '[+]', "Checkbox - +")

call vimtap#Diag("Checkbox with text")
append
[ ] Some text
.
normal \cc
call vimtap#Is(getline('.'), '[X] Some text', "Box checked, text unmodified")
append
    [ ] Some text
.
normal \cc
call vimtap#Is(getline('.'), '    [X] Some text',
            \"Box checked, indent preserved")

call vimtap#Diag("Adding a checkbox")
append
Some text
.
normal \cb
call vimtap#Is(getline('.'), '[ ] Some text', "Checkbox added")
normal \cb
call vimtap#Is(getline('.'), '[ ] Some text',
            \"Repeated \cb commands don't add more checkboxes")
normal \cc
normal \cb
call vimtap#Is(getline('.'), '[X] Some text',
            \"Repeat \cb command on a checked box doesn't add more checkboxes")


call vimtest#Quit()
