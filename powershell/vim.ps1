# Install a code-completion engine for vim
# Link: https://github.com/Valloric/YouCompleteMe
function Install-YouCompleteMe ([string] $dir) {
  Write-Host 'Installing Vim plugin ''https://github.com/Valloric/YouCompleteMe''' -ForegroundColor Yellow
  Install-Package '7zip'
  $env:Path+= ";$($env:ProgramFiles)\7-Zip"
  Install-Package 'cmake'
  $env:Path+= ";$($env:ProgramFiles)\CMake\bin"
  python $dir\install.py
}

function Install-TernForVim ([string] $dir) {
  Write-Host 'Installing Vim plugin ''https://github.com/ternjs/tern_for_vim''' -ForegroundColor Yellow
  Push-Location $dir
  npm install
  Pop-Location
}

# Install a plugin manager for vim
# Link: https://github.com/junegunn/vim-plug
function Install-Plug {
  Write-Host 'Installing Vim plugin manager ''https://github.com/junegunn/vim-plug'''
  Create-DirectoryIfNotFound "$HOME\.vim" {
    Create-DirectoryIfNotFound "$HOME\.vim\autoload" {
      Invoke-WebRequest -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" -OutFile "$HOME\.vim\autoload\plug.vim"
    }
  }
}

####################################################################################################
#                                                                                                  #
#                                            Setup Vim                                             #
#                                                                                                  #
####################################################################################################

# Run vim, install plugins and quit vim
if (!(Test-Path "$HOME\.vim\autoload\plug.vim")) {
  Install-Plug
  vim +PlugInstall +qall
  Install-YouCompleteMe "$HOME\.vim\plugged\YouCompleteMe"
#  Install-TernForVim "$HOME\.vim\plugged\tern_for_vim"
}
