"https://otavio.dev/2018/09/30/migrating-from-vim-to-neovim/
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
