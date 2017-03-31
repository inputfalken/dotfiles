#!/bin/bash
function linuxInstallation {
  printf 'Installing for linux \n\n'
  printf 'Installing software-properties'
  apt-get install -qq software-properties-common -y
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886 > /dev/null 2>&1
  printf 'Adding spotify repository'
  printf deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list > /dev/null 2>&1
  printf 'Adding nevim repository'
  add-apt-repository ppa:neovim-ppa/stable -y > /dev/null 2>&1
  #sudo add-apt-repository ppa:jonathonf/vim
  printf 'Updating packages list...'
  apt-get -qq update  # To get the latest package lists
  printf 'installing Spotify'
  apt-get -qq install spotify-client
  printf 'Installing neovim'
  apt-get -qq install neovim
  printf 'Installing nodeJs'
  apt-get -qq install nodejs -y
  printf 'Installing cmake'
  apt-get -qq install cmake -y
  printf 'Installing python enviroment'
  apt-get -qq install python python3 python-dev python3-dev python-pip -y
  #apt-get install vim
}

function linkItem() {
  if [ -f ~/$1 ] # Check if file exist
  then
    printf $1 'exists, you have to remove it in order to link it' # ask user to delete it
    rm ~/$1 -i
  fi
  if [ ! -f ~/$1 ] # If file does not exist
  then
    printf 'Linking ' $1
    link ./$1 ~/$1
  fi
}

if [ "$(uname)" == "Darwin" ]; then
  printf 'Mac osx'
  linkItem .gitconfig
  linkItem .vimrc
  linkItem .vimrc.plugins
  linkItem .gitignore_global
  linkItem .tmux.conf
  linkItem .vimrc.syntastic
  linkItem .tern-project
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  linkItem .gitconfig
  linkItem .vimrc
  linkItem .vimrc.plugins
  linkItem .gitignore_global
  linkItem .tmux.conf
  linkItem .vimrc.syntastic
  linkItem .tern-project
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  printf 'Windows 32 bit'
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
  linkItem .gitignore_global
  linkItem .gitconfig
  linkItem .vimrc
  linkItem .vimrc.plugins
  linkItem .vimrc.syntastic
fi
