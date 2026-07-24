# Initialize the oh-my-posh prompt with the Catppuccin Mocha theme.
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/catppuccin_mocha.omp.json)"

# Default terminal editor used by CLI tools; Codex uses VISUAL first for Ctrl+G prompt editing, then EDITOR as a fallback.
export VISUAL=vim
export EDITOR=vim

# Prevent accidental shell exit on Ctrl-D.
setopt ignore_eof

# Tell nvm where its installation and Node versions live.
export NVM_DIR="$HOME/.nvm"

# Load nvm when its startup script exists.
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Load nvm command completion when available.
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Launch the configured Codex sandbox from ~/Code/agent-sandbox.
alias codex-sandbox="sbx run --name agent-sandbox"

alias gs="git status"
alias gd="git diff"
alias gco="git checkout"
alias gds="git diff --staged"
alias gdwd="git diff --word-diff"
alias gp="git push"
alias gppfwl="git push --force-with-lease"
alias pull="git remote update && git pull"
