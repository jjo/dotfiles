# autosuggestions install:
# Good resource -> https://catalins.tech/zsh-plugins/
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
# git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
#plugins=($plugins zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete clipboard)
plugins=($plugins zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting clipboard)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=2'
