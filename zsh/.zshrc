# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


export PATH=$HOME/bin:/usr/local/bin:/opt/local/bin:/opt/local/sbin:$HOME/.local/bin:$PATH
export CLAUDE_ENV_FILE="$HOME/.claude/shell-init.sh"
export TERM=xterm-256color
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export MICRO_TRUECOLOR=1


# -- shell options --------------------------------------------------------

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt auto_menu
setopt complete_in_word
setopt always_to_end
setopt multios
setopt long_list_jobs
setopt interactivecomments
setopt prompt_subst
unsetopt menu_complete
unsetopt flowcontrol


# -- history --------------------------------------------------------------

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history


# -- completion -----------------------------------------------------------

autoload -U colors && colors
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit
zmodload -i zsh/complist

WORDCHARS=''

bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"


# -- key bindings ---------------------------------------------------------

bindkey -e

# terminal application mode for correct terminfo values
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init()   { echoti smkx }
  function zle-line-finish() { echoti rmkx }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

# history search with arrow keys
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-beginning-search

# Home / End / Delete
[[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]}"  ]] && bindkey "${terminfo[kend]}"  end-of-line
if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey "${terminfo[kdch1]}" delete-char
else
  bindkey "^[[3~" delete-char
fi

# Shift-Tab: reverse menu completion
[[ -n "${terminfo[kcbt]}" ]] && bindkey "${terminfo[kcbt]}" reverse-menu-complete

# Ctrl-arrow word navigation
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Ctrl-Delete: kill word forward
bindkey "^[[3;5~" kill-word

# Backspace
bindkey "^?" backward-delete-char

# Ctrl-x Ctrl-e: edit command in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# misc
bindkey '^r' history-incremental-search-backward
bindkey ' ' magic-space


# -- bracketed paste & url quoting ----------------------------------------

autoload -Uz bracketed-paste-magic url-quote-magic
zle -N bracketed-paste bracketed-paste-magic
zle -N self-insert url-quote-magic


# -- terminal title (precmd/preexec) --------------------------------------

autoload -Uz add-zsh-hook

function title {
  setopt localoptions nopromptsubst
  : ${2=$1}
  case "$TERM" in
    xterm*|putty*|rxvt*|konsole*|ansi|mlterm*|alacritty*|st*|foot*|contour*|wezterm*)
      print -Pn "\e]2;${2:q}\a\e]1;${1:q}\a" ;;
    screen*|tmux*)
      print -Pn "\ek${1:q}\e\\" ;;
  esac
}

function _title_precmd { title "%15<..<%~%<<" "%n@%m:%~." }
function _title_preexec {
  emulate -L zsh; setopt extended_glob
  local CMD="${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}"
  title "$CMD" "%100>...>${2:gs/%/%%}%<<"
}

add-zsh-hook precmd  _title_precmd
add-zsh-hook preexec _title_preexec


# -- powerlevel10k --------------------------------------------------------

source ~/.config/zsh/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
POWERLEVEL9K_DISABLE_GITSTATUS=true


# -- aliases --------------------------------------------------------------

alias spf="superfile"
alias grep="rg -uuu"

alias gc="gemini --model gemini-3-pro-preview"

uhh() {
  local user_request="$*"
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

  local gemini_response=$(gemini -p "$prompt" | tail -n +2)
  local command=$(echo "$gemini_response" | grep "^Command:" | sed "s/^Command: //")
  local description=$(echo "$gemini_response" | grep "^Description:" | sed "s/^Description: //")

  if [[ -z "$command" || -z "$description" ]]; then
    echo "Error: Could not parse Gemini response:"
    echo "$gemini_response"
    return 1
  fi

  echo "Suggested command:"
  echo "  $command"
  echo "\nDescription:"
  echo "  $description"

  read -q "?Execute this command? (y/n) "
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    eval "$command"
  else
    echo "Command not executed."
  fi
}

# eza
alias ls='eza --color=always --group-directories-first --icons'
alias lh='eza -lsh --color=always --group-directories-first --icons'
alias ll='eza -la --icons --octal-permissions --group-directories-first'
alias lm='eza -bGF --header --git --color=always --group-directories-first --icons'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons'
alias lS='eza -1 --color=always --group-directories-first --icons'
alias lt='eza --tree --level=4 --color=always --group-directories-first --icons'
alias l.="eza -a | grep -E '^\\.'"

# bat
alias cat="bat --paging=never"
alias bat="bat"

# nix
alias nix-rebuild='nix flake update --flake ~/.config/nix && nix shell ~/.config/nix'

# git
unalias g &>/dev/null
g() {
  if [ $# -eq 0 ]; then
    command git status
  else
    command git "$@"
  fi
}


# -- fzf ------------------------------------------------------------------

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

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() { fd --hidden --exclude .git . "$1" }
_fzf_compgen_dir()  { fd --type=d --hidden --exclude .git . "$1" }

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"                          "$@" ;;
    ssh)          fzf --preview 'dig {}'                                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview"                "$@" ;;
  esac
}

source ~/.config/zsh/fzf-git/fzf-git.sh

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#e8e8e8,fg+:#ffffff,bg:#000000,bg+:#2d2d2d
  --color=hl:#d9b98c,hl+:#ff9e3b,info:#b9d665,marker:#f08d49
  --color=prompt:#ff6b6b,spinner:#ffb86c,pointer:#ff9e3b,header:#d9b98c
  --color=gutter:000000,border:#636363,label:#aeaeae,query:#ffffff
  --border="bold" --border-label="" --preview-window="border-bold" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'

export BAT_THEME="catthode"


# -- VS Code --------------------------------------------------------------

if [[ -n "$VSCODE_GIT_ASKPASS_NODE" ]]; then
  code() { "$(dirname "$VSCODE_GIT_ASKPASS_NODE")/bin/remote-cli/code" "$@" }
fi
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"


# -- zoxide ---------------------------------------------------------------

eval "$(zoxide init zsh --cmd cd)"





# -- syntax highlighting (must be last) -----------------------------------

source ~/.config/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# Nix
if [ -e /etc/profile.d/nix.sh ]; then
  . /etc/profile.d/nix.sh
fi
