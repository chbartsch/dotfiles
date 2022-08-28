#!/bin/bash

prompt_install() {
	echo -n "$1 is not installed. Would you like to install it? (y/n) " >&2
	old_stty_cfg=$(stty -g)
	stty raw -echo
	answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
	stty $old_stty_cfg && echo
	if echo "$answer" | grep -iq "^y" ;then
		# This could def use community support
		if [ -x "$(command -v apt-get)" ]; then
			sudo apt-get install $1 -y

		elif [ -x "$(command -v brew)" ]; then
			brew install $1

		elif [ -x "$(command -v pkg)" ]; then
			sudo pkg install $1

		elif [ -x "$(command -v pacman)" ]; then
			sudo pacman -S $1

		else
			echo "I'm not sure what your package manager is! Please install $1 on your own and run this deploy script again." 
		fi 
	fi
}

check_for_software() {
	echo "Checking to see if $1 is installed"
	if ! ( [ -x "$(command -v $1)" ] || [ "$(dpkg -l | grep $1)" ] ); then
		prompt_install $1
	else
		echo "$1 is installed."
	fi
}

check_default_shell() {
	if [ -z "${SHELL##*zsh*}" ] ;then
		echo "Default shell is zsh."
	else
		echo -n "Default shell is not zsh. Do you want to chsh -s \$(which zsh)? (y/n)"
		old_stty_cfg=$(stty -g)
		stty raw -echo
		answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
		stty $old_stty_cfg && echo
		if echo "$answer" | grep -iq "^y" ;then
			chsh -s $(which zsh)
		else
			echo "Warning: Your configuration won't work properly. If you exec zsh, it'll exec tmux which will exec your default shell which isn't zsh."
		fi
	fi
}

echo "We're going to do the following:"
echo "1. Check to make sure you have zsh, wget, vim, tmux and fonts-powerline"
echo "2. We'll help you install them if you don't"
echo "3. We're going to check to see if your default shell is zsh"
echo "4. We'll try to change it if it's not" 

echo "Let's get started? (y/n)"
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ;then
	echo 
else
	echo "Quitting, nothing was changed."
	exit 0
fi


# base requirements
check_for_software wget
echo
check_for_software vim
echo
check_for_software tmux
echo
check_for_software git
echo
check_for_software zsh
echo

# oh-my-zsh "agnoster"-theme requirements
check_for_software fonts-powerline
echo

# oh-my-tmux requirements
check_for_software awk
echo
check_for_software sed
echo
check_for_software perl
echo
check_for_software xclip
echo


# backup current dotfiles
echo
echo -n "Would you like to backup your current dotfiles? (y/n) "
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
now=$(date +"%Y-%m-%d_%H-%M-%S")
if echo "$answer" | grep -iq "^y" ;then
	mv $HOME/.tmux.conf $HOME/.tmux.conf.${now}
	mv $HOME/.vimrc $HOME/.vimrc.${now}
	mv $HOME/.config/Code/User/settings.json $HOME/.config/Code/User/settings.json.${now}
	mv $HOME/.config/Code/User/keybindings.json $HOME/.config/Code/User/keybindings.json.${now}
else
	echo -e "\nNot backing up old dotfiles."
fi


# the directory this script is in
BASEDIR=$(dirname "$0")


echo "Install oh-my-zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
	(cd $HOME/.oh-my-zsh && git pull --rebase)
else
	sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
fi

echo "Install oh-my-tmux"
if [ -d "$HOME/.oh-my-tmux" ]; then
	(cd $HOME/.oh-my-tmux && git pull --rebase)
else
	git clone https://github.com/gpakosz/.tmux.git $HOME/.oh-my-tmux
fi
ln -s -f $HOME/.oh-my-tmux/.tmux.conf $HOME/.tmux.conf


# check for default shell
check_default_shell


# symlink custom configs from this folder
ln -s -f $HOME/$BASEDIR/zsh/.zshrc $HOME/.zshrc
ln -s -f $HOME/$BASEDIR/tmux/.tmux.conf.local $HOME/.tmux.conf.local
printf "so $HOME/$BASEDIR/vim/vimrc.vim" > $HOME/.vimrc

mkdir -p $HOME/.config/Code/User/
ln -s -f $HOME/$BASEDIR/vscode/settings.json $HOME/.config/Code/User/settings.json
ln -s -f $HOME/$BASEDIR/vscode/keybindings.json $HOME/.config/Code/User/keybindings.json


echo
echo "Please log out and log back in for default shell to be initialized."
