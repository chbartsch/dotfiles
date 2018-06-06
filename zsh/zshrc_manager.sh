time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }

# Try to run tmux only if we are *not* in a ssh remote session
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	# Run tmux if exists
	if command -v tmux>/dev/null; then
		[ -z $TMUX ] && { tmux attach || exec tmux new-session; }
	else 
		echo "tmux not installed. Run ./deploy to configure dependencies"
	fi
fi

echo "Updating configuration"
#(cd ~/dotfiles && time_out 3 git pull && time_out 3 git submodule update --init --recursive)
(cd ~/dotfiles && git pull && git submodule update --init --recursive)
source ~/dotfiles/zsh/zshrc.sh
