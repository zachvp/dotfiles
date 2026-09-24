" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Load Pathogen to enable plugins in bundle directory
execute pathogen#infect()

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" custom colorscheme
colorscheme apprentice

" enable line numbers
set number

" indentation settings
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Markdown plugin settings
let g:vim_markdown_fenced_languages = ['bash=sh', 'python', 'json', 'javascript', 'ruby']
