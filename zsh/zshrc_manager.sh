time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }

# start tmux only if we are not root
if [ $(id -u) -ne 0 ]; then
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
