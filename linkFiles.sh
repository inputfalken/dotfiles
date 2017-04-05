#!/bin/bash

function linkItem() {
  if [ -f ~/$1 ] # Check if file exist
  then
    printf "$1 exists, you have to remove it in order to link it \n" # ask user to delete it
    rm ~/$1 -i
  fi
  if [ ! -f ~/$1 ] # If file does not exist
  then
    printf "Linking $1"
    link ./$1 ~/$1
    return 1 # If file was linked
  fi
  return 0 # If was not linked
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
