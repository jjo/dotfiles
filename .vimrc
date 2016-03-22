" syntastic
" cd ~/.vim/bundle && \
" git clone https://github.com/scrooloose/syntastic.git
"  execute pathogen#infect()
"  set statusline+=%#warningmsg#
"  set statusline+=%{SyntasticStatuslineFlag()}
"  set statusline+=%*
"  
"  let g:syntastic_always_populate_loc_list = 1
"  let g:syntastic_auto_loc_list = 1
"  let g:syntastic_check_on_open = 1
"  let g:syntastic_check_on_wq = 0

set rtp+=~/.vim/bundle/vundle/
call vundle#begin()

" Let Vundle manage Vundle
Bundle 'gmarik/vundle'

Bundle 'jnwhiteh/vim-golang.git'
Bundle 'klen/python-mode.git'
Bundle 'scrooloose/nerdtree'
Bundle 'ervandew/supertab'

call vundle#end()
let g:pymode_rope_autoimport = 0

au BufRead,BufNewFile *.go set filetype=go
  \ ts=4 et sts=4 sw=4 si

" Highlight >80cols, extra space, and others
highlight ExtraSpace ctermbg=grey ctermfg=white guibg=#707070
au BufWinEnter * let w:m1=matchadd('ExtraSpace', ' \+$', -1)
au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+\|XXX\|TODO.jjo.', -1)
"let g:pymode_lint_checker = "pyflakes,pep8,mccabe,pylint"
let g:pymode_lint_checker = "pyflakes,pep8,pylint"

set modeline
filetype plugin indent on
syntax on

" pythonisms
autocmd FileType python compiler pylint
autocmd FileType lua,puppet,python,yaml set sw=4 ts=4 sts=4 et ai smarttab
autocmd FileType python set omnifunc=pythoncomplete#Complete

"imap <F2> :r !date +[\%T]o
"map <F2> :r !date +[\%T]
imap <F2> <Esc>:NERDTreeToggle<CR>
map <F2> :NERDTreeToggle<CR>
map <F8> :new<CR>:read !cg-diff<CR>:set syntax=diff buftype=nofile<CR>gg
map <F9> :make
map <F10> :cn! <C-M>
map <F11> :cp! <C-M>
map ,cu mX:s,/[*] \(.*\) [*]/,\1,<C-M>:nohls<C-M>
map ,cc :s,.*,/* & */,<C-M>:nohls<C-M>

" arduino pde files
au BufNewFile,BufRead *.pde set filetype=arduino
function! ArduinoSetup()
  setlocal cindent
  call GnuIndent()
  " arduino_make.sh doesnt support actual targets, use as:
  "    :make compile
  "    :make upload
  set makeprg=~/bin/arduino_make.sh\ $*\ 2\>\&1\\\|\ egrep\ -v\ commands.for.target
  "set makeprg=~/bin/arduino_make.sh\ $*\ 2\>\\\&1\\\|\ sed\ -n\ 's,applet/arduino.cpp,arduino.pde,'
endfunction

au FileType arduino call ArduinoSetup()
filetype plugin indent on


au BufRead,BufNewFile *.txt,README*,TODO*,CHANGELOG,NOTES
        \ setlocal autoindent expandtab tabstop=8 softtabstop=2 shiftwidth=2 filetype=asciidoc
        \ textwidth=70 wrap formatoptions=tcqn
        \ formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\\|^\\s*<\\d\\+>\\s\\+\\\\|^\\s*[a-zA-Z.]\\.\\s\\+\\\\|^\\s*[ivxIVX]\\+\\.\\s\\+
        \ comments=s1:/*,ex:*/,://,b:#,:%,:XCOMM,fb:-,fb:*,fb:+,fb:.,fb:>


" switched myself to gnu indentation (flames>/dev/null :P)
function! GnuIndent()
  setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
  setlocal shiftwidth=2
  setlocal tabstop=8
endfunction
au FileType c,cpp,arduino call GnuIndent()

au BufRead,BufNewFile *.proto set filetype=cpp
  \ ts=2 et sts=2 sw=2 ai

au BufRead,BufNewFile *.szl set filetype=szl
  \ ts=2 et sts=2 sw=2 ai

set bg=dark
set mouse=a
" allow erasing previous characters, in insert mode:
set backspace=2
