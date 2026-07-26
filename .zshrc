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

# Launch the configured Codex sandbox.
#
# When run from ~/Code or any directory beneath it, Codex is started with that
# directory as its working root inside the sandbox. This works because ~/Code is
# the workspace mounted into the sandbox.
#
# When run from outside ~/Code, fall back to the sandbox's default directory
# instead of passing a host path that will not exist inside the container.
codex-sandbox() {
  local code_root="$HOME/Code"

  if [[ "$PWD" == "$code_root" || "$PWD" == "$code_root"/* ]]; then
    sbx run --name agent-sandbox -- -C "$PWD"
  else
    sbx run --name agent-sandbox
  fi
}

alias gs="git status"
alias gd="git diff"
alias gco="git checkout"
alias gds="git diff --staged"
alias gdwd="git diff --word-diff"
alias gp="git push"
alias gppfwl="git push --force-with-lease"
alias pull="git remote update && git pull"
