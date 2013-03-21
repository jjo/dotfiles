" Highlight >80cols
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

syntax on
set modeline
imap <F2> :r !date +[\%T]o
map <F2> :r !date +[\%T]
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

"autocmd FileType python compiler pylint
autocmd FileType python set ts=2 et sts=2 sw=2 ai

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

" GO (golang.org)
"   cp $GOROOT/misc/vim/{ftdetect,syntax} ~/.vim/
au BufRead,BufNewFile *.go set filetype=go
  \ ts=2 et sts=2 sw=2 ai


au BufRead,BufNewFile *.proto set filetype=cpp
  \ ts=2 et sts=2 sw=2 ai

au BufRead,BufNewFile *.szl set filetype=szl
  \ ts=2 et sts=2 sw=2 ai

" java/android
"

au BufRead,BufNewFile build.xml,*.java
  \ set makeprg=ant\ -emacs

" low-weight cscope
if has("cscope")
  set csprg=/usr/bin/cscope
  set csto=0
  set cst
  set nocsverb
  " add any database in current directory
  if filereadable("cscope.out")
    cs add cscope.out
    " else add database pointed to by environment
  elseif $CSCOPE_DB != ""
    cs add $CSCOPE_DB
  endif
  set csverb
  map g<C-]> :cs find 3 <C-R>=expand("<cword>")<CR><CR>
endif

" avoid autoindent when pasting w/middle click
set bg=dark
set mouse=a
