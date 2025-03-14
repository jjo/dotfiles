" =============================================================================
" GENERAL SETTINGS
" =============================================================================
set nocompatible              " Use Vim settings, rather than Vi settings
filetype off                  " Required for Vundle setup
set encoding=utf-8            " Set default encoding
set fileencoding=utf-8        " Set file encoding
set modeline                  " Enable modeline
set mouse=a                   " Enable mouse in all modes
set backspace=indent,eol,start " Allow backspacing over everything
set hidden                    " Allow buffer switching without saving
set history=1000              " Store more history
set undofile                  " Persistent undo
set undodir=~/.vim/undo       " Undo directory
set backup                    " Keep backup files
set backupdir=~/.vim/backup   " Backup directory
set directory=~/.vim/swap     " Swap file directory
set updatetime=300            " Faster updatetime (default is 4000 ms)
set timeoutlen=500            " Shorter timeout for mappings
set ttimeoutlen=10            " Short timeout for key codes
set autoread                  " Auto-reload changed files
set wildmenu                  " Command line completion
set wildmode=list:longest,full " Command line completion behavior
set showcmd                   " Show partial commands
set lazyredraw                " Don't redraw while executing macros
set ttyfast                   " Faster redrawing
set showmatch                 " Show matching brackets
set number                    " Show line numbers
set cursorline                " Highlight current line
set scrolloff=5               " Keep 5 lines above/below cursor
set sidescrolloff=5           " Keep 5 columns left/right of cursor

" Search settings
set incsearch                 " Incremental search
set hlsearch                  " Highlight search results
set ignorecase                " Ignore case in search patterns
set smartcase                 " Override ignorecase when search includes uppercase

" Indentation settings
set autoindent                " Auto indent
set smartindent               " Smart indent
set expandtab                 " Use spaces instead of tabs
set shiftwidth=2              " Default to 4 spaces for indentation
set tabstop=2                 " Default to 4 spaces for tabs
set softtabstop=2             " Default to 4 spaces when pressing tab

" Appearance
set bg=dark                   " Dark background
set termguicolors             " True color support
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" =============================================================================
" PLUGIN MANAGEMENT (Vundle)
" =============================================================================
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'

" Development plugins
Plugin 'jnwhiteh/vim-golang.git'       " Go support
Plugin 'fatih/vim-go'                  " Enhanced Go support
Plugin 'klen/python-mode.git'          " Python support
Plugin 'hashivim/vim-terraform'        " Terraform support
Plugin 'google/vim-jsonnet'            " Jsonnet support
Plugin 'jjo/vim-cue'                   " CUE support
Plugin 'tsandall/vim-rego'             " Rego support
Plugin 'cappyzawa/starlark.vim'        " Starlark support
Plugin 'cappyzawa/ytt.vim'             " YTT support
Plugin 'jjo/vim-promql'                " PromQL support
Plugin 'buoto/gotests-vim'             " Go test generation

" Editor enhancements
Plugin 'scrooloose/nerdtree'           " File explorer
Plugin 'ervandew/supertab'             " Tab completion
Plugin 'airblade/vim-gitgutter'        " Git gutter
Plugin 'mileszs/ack.vim'               " Search tool
Plugin 'nathanaelkane/vim-indent-guides' " Indentation guides
Plugin 'dense-analysis/ale'            " Async linter
Plugin 'neoclide/coc.nvim', {'branch': 'release'} " Intellisense engine

" UI enhancements
Plugin 'vim-airline/vim-airline'       " Status bar
Plugin 'vim-airline/vim-airline-themes' " Status bar themes
Plugin 'crusoexia/vim-monokai'         " Monokai theme
Plugin 'morhetz/gruvbox'               " Gruvbox theme
Plugin 'sainnhe/sonokai'               " Sonokai theme
Plugin 'junegunn/seoul256.vim'         " Seoul256 theme

" Neovim-specific plugins
if has('nvim')
  Plugin 'glepnir/galaxyline.nvim', {'branch': 'main'}
  Plugin 'nvim-lua/plenary.nvim'
  Plugin 'sindrets/diffview.nvim'
  Plugin 'folke/tokyonight.nvim'
  Plugin 'rebelot/kanagawa.nvim'
  Plugin 'glacambre/firenvim', {'do': {-> firenvim#install(0)}}

  " Avante and dependencies
  Plugin 'stevearc/dressing.nvim'
  Plugin 'MunifTanjim/nui.nvim'
  Plugin 'nvim-tree/nvim-web-devicons'
  Plugin 'HakonHarnes/img-clip.nvim'
  Plugin 'zbirenbaum/copilot.lua'
  Plugin 'yetone/avante.nvim', {'branch': 'main', 'do': {-> avante#build()}, 'on': 'AvanteAsk'}
  
  " Ghost support
  Plugin 'subnut/nvim-ghost.nvim'
  
  set undodir=~/.vim/undo-nvim
  if !isdirectory($HOME."/.vim/undo-nvim")
      call mkdir($HOME."/.vim/undo-nvim", "p")
  endif
endif

call vundle#end()
filetype plugin indent on    " Required after Vundle

" =============================================================================
" PLUGIN SETTINGS
" =============================================================================

" Coc.nvim settings
" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <C-]> <Plug>(coc-definition)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Ack.vim settings
" Use silversearch-ag "ag" instead of perl'ian ack-grep
let g:ackprg = 'ag --vimgrep'

" NERDTree settings
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = ['^\.git$', '^\.DS_Store$']

" vim-go settings
let g:go_def_mode = 'gopls'
let g:go_info_mode = 'gopls'
let g:go_fmt_command = 'goimports'
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1

" Python-mode settings
let g:pymode_rope_autoimport = 0
let g:pymode_lint_ignore = "E501"
let g:pymode_lint_checker = "pyflakes3,pep8,pylint"

" Jsonnet settings
let g:jsonnet_fmt_on_save = 1

" nvim-ghost settings
if has('nvim')
  let g:nvim_ghost_use_script = 1
  let g:nvim_ghost_python_executable = '/usr/local/bin/python3'
endif

" ALE settings
let g:ale_linters = {
\   'python': ['flake8', 'pylint'],
\   'go': ['golint', 'go vet'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['black'],
\   'go': ['gofmt', 'goimports'],
\}
let g:ale_fix_on_save = 1

" =============================================================================
" MAPPINGS
" =============================================================================
" Set leader key to space (more accessible than default backslash)
let mapleader = "\<Space>"
let maplocalleader = "\<Space>"

" NERDTree toggle
nnoremap <F2> :NERDTreeToggle<CR>
inoremap <F2> <Esc>:NERDTreeToggle<CR>

" Navigation mappings
map <C-n> :cnext<CR>
map <C-p> :cprev<CR>
map <C-h> :GitGutterNextHunk<CR>

" Build/test mappings
map <Leader>k :make<CR>
au FileType go map <Leader>t :GoTest<CR>

" Comment/uncomment lines
map <Leader>cc :s,.*,/* & */,<CR>:nohls<CR>
map <Leader>cu mX:s,/[*] \(.*\) [*]/,\1,<CR>:nohls<CR>

" Buffer navigation
nnoremap <Leader>b :buffers<CR>:buffer<Space>
nnoremap <Leader>n :bnext<CR>
nnoremap <Leader>p :bprevious<CR>

" Clear search highlighting
nnoremap <Leader>/ :nohlsearch<CR>

" Save file
nnoremap <Leader>w :w<CR>

" Quit
nnoremap <Leader>q :q<CR>

" =============================================================================
" AUTOCOMMANDS
" =============================================================================
augroup FileTypeSpecific
  autocmd!
  " Python
  autocmd FileType python compiler pylint
  autocmd FileType python set omnifunc=pythoncomplete#Complete

  " Go
  autocmd FileType go set ts=4 et sts=4 sw=4 si

  " Web languages
  autocmd FileType lua,puppet set sw=4 ts=4 sts=4 et ai smarttab
  autocmd FileType yaml set sw=2 ts=2 sts=2 et ai smarttab
  autocmd FileType ruby,javascript set sw=2 ts=2 sts=2 et ai smarttab
  autocmd FileType markdown set sw=2 ts=2 sts=2 et si smarttab
  autocmd FileType sh set sw=4 ts=4 sts=4 et si smarttab
  autocmd FileType eruby,groovy set sw=2 ts=2 sts=2 et si smarttab

  " Jsonnet/CUE/Rego/PromQL
  autocmd BufNewFile,BufRead *.jsonnet,*.libsonnet set filetype=jsonnet sw=2 ts=2 sts=2 et si
  autocmd BufNewFile,BufRead *.cue set filetype=cue sw=4 ts=4 noet si
  autocmd BufNewFile,BufRead *.rego set filetype=rego sw=2 ts=2 et si
  autocmd BufNewFile,BufRead *.promql,*.rules set filetype=promql sw=2 ts=2 sts=2 et si

  " Arduino
  autocmd BufNewFile,BufRead *.pde set filetype=arduino
  autocmd FileType arduino call ArduinoSetup()

  " Protocol buffers
  autocmd BufRead,BufNewFile *.proto set filetype=cpp ts=2 et sts=2 sw=2 ai
  
  " SZL
  autocmd BufRead,BufNewFile *.szl set filetype=szl ts=2 et sts=2 sw=2 ai
  
  " Mail
  autocmd FileType mail set spell tw=74
  
  " Text files
  autocmd BufRead,BufNewFile *.txt,README*,TODO*,CHANGELOG,NOTES
    \ setlocal autoindent expandtab tabstop=8 softtabstop=2 shiftwidth=2 filetype=asciidoc
    \ textwidth=70 wrap formatoptions=tcqn
    \ formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\\|^\\s*<\\d\\+>\\s\\+\\\\|^\\s*[a-zA-Z.]\\.\\s\\+\\\\|^\\s*[ivxIVX]\\+\\.\\s\\+
    \ comments=s1:/*,ex:*/,://,b:#,:%,:XCOMM,fb:-,fb:*,fb:+,fb:.,fb:>
augroup END

" Highlight extra spaces and trailing whitespace
highlight ExtraSpace ctermbg=grey ctermfg=white guibg=#707070
augroup HighlightTrailingSpaces
  autocmd!
  autocmd BufWinEnter * let w:m1=matchadd('ExtraSpace', ' \+$', -1)
  autocmd BufWinEnter * let w:m2=matchadd('ErrorMsg', 'XXX\|TODO.jjo.', -1)
augroup END

" =============================================================================
" CUSTOM FUNCTIONS
" =============================================================================
" GNU Indentation style
function! GnuIndent()
  setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
  setlocal shiftwidth=2
  setlocal tabstop=8
endfunction
autocmd FileType c,cpp,arduino call GnuIndent()

" Arduino setup
function! ArduinoSetup()
  setlocal cindent
  call GnuIndent()
  set makeprg=~/bin/arduino_make.sh\ $*\ 2\>\&1\\\|\ egrep\ -v\ commands.for.target
endfunction

" =============================================================================
" COLOR SCHEME AND UI
" =============================================================================
" Choose one of the installed color schemes:
colorscheme gruvbox     " Options: gruvbox, monokai, sonokai, seoul256

" Make line numbers more visible
highlight LineNr ctermfg=grey guifg=grey

" Configure airline
let g:airline_powerline_fonts = 1
let g:airline_theme = 'gruvbox'
let g:airline#extensions#tabline#enabled = 1

" Create necessary directories if they don't exist
if !isdirectory($HOME."/.vim/backup")
    call mkdir($HOME."/.vim/backup", "p")
endif
if !isdirectory($HOME."/.vim/swap")
    call mkdir($HOME."/.vim/swap", "p")
endif
if !isdirectory($HOME."/.vim/undo")
    call mkdir($HOME."/.vim/undo", "p")
endif
