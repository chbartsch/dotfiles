# start tmux only if we are not root
if test (id -u) -ne 0
	# Run tmux if exists
	if command -v tmux>/dev/null
    #[ -z $TMUX ] && { { tmux attach || exec tmux new-session } && exit; }
    [ -z $TMUX ]; and begin; begin; tmux attach; or exec tmux new-session; end; and exit; end;
  else 
		echo "tmux not installed. Run ./deploy to configure dependencies";
	end
end

echo "updating configuration"
#(cd ~/dotfiles && time_out 2 git pull && time_out 2 git submodule update --init --recursive)
cd ~/dotfiles && git pull --rebase && git submodule update --init --recursive
omf update
#source ~/dotfiles/zsh/zshrc.sh
