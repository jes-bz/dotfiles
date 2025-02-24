# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


export ZSH=/Users/jesse/.config/zsh/.oh-my-zsh
export TERM=xterm-256color

ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_CONFIG_FILE="~/.config/zsh/.p10k.zsh"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs anaconda)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_DELIMITER=""
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"
POWERLEVEL9K_ANACONDA_BACKGROUND=green

export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# CASE_SENSITIVE="true" # Uncomment the following line to use case-sensitive completion.
# DISABLE_AUTO_UPDATE="true" # Uncomment the following line to disable bi-weekly auto-update checks.
# export UPDATE_ZSH_DAYS=13 # Uncomment the following line to change how often to auto-update (in days).
# DISABLE_LS_COLORS="true" # Uncomment the following line to disable colors in ls.
# DISABLE_AUTO_TITLE="true" # Uncomment the following line to disable auto-setting terminal title.
# ENABLE_CORRECTION="true" # Uncomment the following line to enable command auto-correction.
# COMPLETION_WAITING_DOTS="true" # Uncomment the following line to display red dots whilst waiting for completion.
# DISABLE_UNTRACKED_FILES_DIRTY="true" # Uncomment the following line if you want to disable marking untracked files under VCS as dirty.
# HIST_STAMPS="mm/dd/yyyy" # Uncomment the following line if you want to change the command execution time stamp shown in the history command output.
# ZSH_CUSTOM=/path/to/new-custom-folder # Would you like to use another custom folder than $ZSH/custom?

plugins=(
  git
  fast-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

HISTFILE=$ZDOTDIR/.zsh_history

alias fixpr='git reset --soft HEAD~1 && git add . && git commit -m"$(git log --format=%B --reverse HEAD..HEAD@{1})"'
alias nix-rebuild='darwin-rebuild switch  --flake ~/.config/nix'


# eza aliases
alias ls='eza --color=always --group-directories-first --icons'
alias ll='eza -la --icons --octal-permissions --group-directories-first'
alias l='eza -bGF --header --git --color=always --group-directories-first --icons'
alias llm='eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons' 
alias la='eza --long --all --group --group-directories-first'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons'

alias lS='eza -1 --color=always --group-directories-first --icons'
alias lt='eza --tree --level=2 --color=always --group-directories-first --icons'
alias l.="eza -a | grep -E '^\.'"

# bat aliases
alias cat="bat --paging=never --theme=\$(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo GitHub)"
alias bat="bat --theme=\$(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo GitHub)"

# ripgrep aliases
alias grep="rg -uuu"

# superfile
alias spf="superfile"

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh

export PATH=/opt/local/bin:/opt/local/sbin:$PATH

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

. "$HOME/.local/bin/env"
eval "$(atuin init zsh)"

# VS Code shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

