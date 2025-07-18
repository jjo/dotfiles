# autosuggestions install:
# Good resource -> https://catalins.tech/zsh-plugins/
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
plugins=($plugins zsh-autosuggestions zsh-syntax-highlighting)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=2'
