#!/bin/bash
#TODO Create a proper install file
if [ "$(uname)" == "Darwin" ]; then
  echo 'Mac osx'
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  echo 'Linux'
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  echo 'Windows 32 bit'
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
  echo 'Windows 64 bit'
fi
link ./.gitconfig ~/.gitconfig
link ./.vimrc ~/.vimrc
link ./.vimrc.plugins ~/.vimrc.plugins
link ./.gitignore_global ~/.gitignore_global
link ./.tmux.conf ~/.tmux.conf
link ./.vimrc.syntastic ~/.gitconfig
link ./.tern-project ~/.tern-project
