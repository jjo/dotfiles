" syntastic
" cd ~/.vim/bundle && \
" git clone https://github.com/scrooloose/syntastic.git
"  execute pathogen#infect()
"  set statusline+=%#warningmsg#
"  set statusline+=%{SyntasticStatuslineFlag()}
"  set statusline+=%*
"  let g:syntastic_always_populate_loc_list = 1
"  let g:syntastic_auto_loc_list = 1
"  let g:syntastic_check_on_open = 1
"  let g:syntastic_check_on_wq = 0

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'

Plugin 'jnwhiteh/vim-golang.git'
Plugin 'klen/python-mode.git'
Plugin 'scrooloose/nerdtree'
Plugin 'ervandew/supertab'
Plugin 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plugin 'google/vim-jsonnet'
Plugin 'airblade/vim-gitgutter'
Plugin 'mileszs/ack.vim'
Plugin 'buoto/gotests-vim'
Plugin 'hashivim/vim-terraform'
Plugin 'jjo/vim-cue'
Plugin 'tsandall/vim-rego'
Plugin 'dense-analysis/ale'
Plugin 'cappyzawa/starlark.vim'
Plugin 'cappyzawa/ytt.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
"Plugin 'pedrohdz/vim-yaml-folds'
"Plugin 'AndrewRadev/splitjoin.vim'
Plugin 'crusoexia/vim-monokai'
Plugin 'morhetz/gruvbox'
Plugin 'sainnhe/sonokai'
Plugin 'junegunn/seoul256.vim'
"Plugin 'LnL7/vim-nix'
" Plugin 'prabirshrestha/vim-lsp'
" Plugin 'mattn/vim-lsp-settings'
Plugin 'nathanaelkane/vim-indent-guides'
"Plugin 'Exafunction/codeium.vim'
Plugin 'jjo/vim-promql'
Plugin 'neoclide/coc.nvim', {'branch': 'release'}
" Markdown
"Plugin 'godlygeek/tabular'
"Plugin 'preservim/vim-markdown'
if has('nvim')
   Plugin 'glepnir/galaxyline.nvim' , { 'branch': 'main' }
   Plugin 'nvim-lua/plenary.nvim'
   Plugin 'sindrets/diffview.nvim'
   Plugin 'folke/tokyonight.nvim'
   Plugin 'rebelot/kanagawa.nvim'
   Plugin 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

   "avante.nvim"
   Plugin 'stevearc/dressing.nvim'
   Plugin 'MunifTanjim/nui.nvim'
   " Optional deps
   Plugin 'nvim-tree/nvim-web-devicons' "or Plug 'echasnovski/mini.icons'
   Plugin 'HakonHarnes/img-clip.nvim'
   Plugin 'zbirenbaum/copilot.lua'
   " Yay, pass source=true if you want to build from source
   Plugin 'yetone/avante.nvim', { 'branch': 'main', 'do': { -> avante#build() }, 'on': 'AvanteAsk' }
endif


call vundle#end()

let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

"coc + jsonnet-language-server
" GoTo code navigation.
"--jjo, 2022-0211
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <C-]> <Plug>(coc-definition)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
" Use silversearch-ag "ag" instead of perl'ian ack-grep for
" :Ack
let g:ackprg = 'ag --vimgrep'

filetype plugin indent on    " required

let g:pymode_rope_autoimport = 0
" 80cols is getting forgotten by the new hipsters :( ...
let g:pymode_lint_ignore = "E501"

au BufNewFile,BufRead *.jsonnet,*.libsonnet set filetype=jsonnet sw=2 ts=2 sts=2 et si
au BufNewFile,BufRead *.cue set filetype=cue sw=4 ts=4 noet si
au BufNewFile,BufRead *.rego set filetype=rego sw=2 ts=2 et si
au BufNewFile,BufRead *.promql,*.rules set filetype=promql sw=2 ts=2 sts=2 et si
" Do auto jsonnet fmt on save:
let g:jsonnet_fmt_on_save = 1

" Highlight >80cols, extra space, and others
highlight ExtraSpace ctermbg=grey ctermfg=white guibg=#707070
au BufWinEnter * let w:m1=matchadd('ExtraSpace', ' \+$', -1)
"au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+\|XXX\|TODO.jjo.', -1)
au BufWinEnter * let w:m2=matchadd('ErrorMsg', 'XXX\|TODO.jjo.', -1)


"let g:pymode_lint_checker = "pyflakes,pep8,mccabe,pylint"
let g:pymode_lint_checker = "pyflakes3,pep8,pylint"

set modeline
filetype plugin indent on
syntax on

" pythonisms
autocmd FileType python compiler pylint
autocmd FileType lua,puppet,python set sw=4 ts=4 sts=4 et ai smarttab
autocmd FileType yaml set sw=2 ts=2 sts=2 et ai smarttab
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType ruby set sw=2 ts=2 sts=2 et ai smarttab
autocmd FileType javascript set sw=2 ts=2 sts=2 et ai smarttab
"autocmd FileType python &makeprg=pylint\ --reports=n\ --output-format=parseable\ %:p
"autocmd BufWritePost *.py make

"imap <F2> :r !date +[\%T]o
"map <F2> :r !date +[\%T]
imap <F2> <Esc>:NERDTreeToggle<CR>
map <F2> :NERDTreeToggle<CR>
map <C-n> :cnext<CR>
map <C-p> :cprev<CR>
map <C-k> :make
map ,cu mX:s,/[*] \(.*\) [*]/,\1,<C-M>:nohls<C-M>
map ,cc :s,.*,/* & */,<C-M>:nohls<C-M>
map <C-h> :GitGutterNextHunk<CR>

"Go using faith/vim-go bundle
au FileType go set ts=4 et sts=4 sw=4 si
au FileType go map <C-k> :GoTest<CR>

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

"mail:
autocmd FileType mail set spell tw=74

"others:
autocmd FileType markdown set sw=2 ts=2 sts=2 et si smarttab
autocmd FileType sh set sw=4 ts=4 sts=4 et si smarttab
autocmd FileType eruby set sw=2 ts=2 sts=2 et si smarttab
autocmd FileType groovy set sw=2 ts=2 sts=2 et si smarttab

set bg=dark
set mouse=a
" allow erasing previous characters, in insert mode:
set backspace=2

" don't bother w/mouse support in a text console (!)
if has("gui_running")
    set mouse=a
else
    set mouse=
endif
"colorscheme monokai
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
