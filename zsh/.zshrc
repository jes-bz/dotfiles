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
alias nix-rebuild='nix flake update --flake ~/.config/nix && sudo darwin-rebuild switch  --flake ~/.config/nix'


# eza aliases
alias ls='eza --color=always --group-directories-first --icons'
alias ll='eza -la --icons --octal-permissions --group-directories-first'
alias l='eza -bGF --header --git --color=always --group-directories-first --icons'
alias llm='eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons' 
alias la='eza --long --all --group --group-directories-first'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons'

alias lS='eza -1 --color=always --group-directories-first --icons'
alias lt='eza --tree --level=2 --color=always --group-directories-first --icons'
alias l.="eza -a | grep -E '^.'"

# bat aliases
alias cat="bat --paging=never --theme=\$(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo GitHub)"

# ripgrep aliases
alias grep="rg -uuu"

alias ghcs="gh copilot suggest"
alias gc="gemini --model gemini-3-pro-preview"

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh

export PATH="/opt/local/bin:/opt/local/sbin:/Users/jesse/.local/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# . "$HOME/.local/bin/env"
# eval "$(atuin init zsh)"
source <(fzf --zsh)

up-line-or-fzf-history() {
  if [[ $LBUFFER == *$'\n'* ]]; then
    zle up-line
  else
    zle fzf-history-widget
  fi
}

zle -N up-line-or-fzf-history
bindkey "^[OA" up-line-or-fzf-history

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

source /Users/jesse/.config/zsh/fzf-git/fzf-git.sh

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#e8e8e8,fg+:#ffffff,bg:#000000,bg+:#2d2d2d
  --color=hl:#d9b98c,hl+:#ff9e3b,info:#b9d665,marker:#f08d49
  --color=prompt:#ff6b6b,spinner:#ffb86c,pointer:#ff9e3b,header:#d9b98c
  --color=gutter:000000,border:#636363,label:#aeaeae,query:#ffffff
  --border="bold" --border-label="" --preview-window="border-bold" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'

export BAT_THEME="catthode"

# VS Code shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

#
# Gemini CLI tool to generate and execute commands
#
uhh() {
  # Get the user's request from the command-line arguments
  local user_request="$*"

  # Prepare the prompt for Gemini
  local prompt="You are a helpful assistant that translates natural language descriptions into shell commands.
  You will be given a description of a task and you need to provide a shell command to achieve that task.
  
  You must return the response in this exact format:
  Command: [the shell command here]
  Description: [a brief description of what the command does]
  
  Example response:
  Command: ls -la
  Description: List all files in the current directory with detailed information.
  
  The command should be a one-liner with no line breaks.
  Only return the Command and Description lines, nothing else.
  
  Here is some information about the user's environment:
  - Shell: $SHELL
  - Operating System: $(uname)
  
  Here is the user's request: '$user_request'"

  # Call the Gemini CLI
  local gemini_response=$(gemini -p "$prompt" | tail -n +2)

  # Extract the command and description from the response
  local command=$(echo "$gemini_response" | grep "^Command:" | sed "s/^Command: //")
  local description=$(echo "$gemini_response" | grep "^Description:" | sed "s/^Description: //")

  # Check if we got valid output
  if [[ -z "$command" || -z "$description" ]]; then
    echo "Error: Could not parse Gemini response:"
    echo "$gemini_response"
    return 1
  fi

  # Display the command and description to the user
  echo "Suggested command:"
  echo "  $command"
  echo "\nDescription:"
  echo "  $description"

  # Ask the user for confirmation
  read -q "?Execute this command? (y/n) "
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Execute the command
    eval "$command"
  else
    echo "Command not executed."
  fi
}

# Custom git command
unalias g &>/dev/null
g() {
  if [ $# -eq 0 ]; then
    command git status
  else
    command git "$@"
  fi
}
