" vim: ft=vim
" Use TAP
call vimtest#StartTap()

" Set the autoload path
set rtp+=..

" Load the todo plugin
" This should have the same effect as set ft=todo
source ../ftplugin/todo.vim
source ../syntax/todo.vim

" Whitespace settings - makes checking indented text easy
setlocal sw=4 sts=4 et

