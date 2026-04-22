# To make zsh work with configs in ~/.config/zsh
export ZDOTDIR=~/.config/zsh
# Nix
if [ -e /etc/profile.d/nix.sh ]; then
  . /etc/profile.d/nix.sh
fi
