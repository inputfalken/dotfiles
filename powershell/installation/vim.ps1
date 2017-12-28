####################################################################################################
#                                                                                                  #
#                                            Setup Vim                                             #
#                                                                                                  #
####################################################################################################

function Setup-Vim {
  # Install a code-completion engine for vim
  # Link: https://github.com/Valloric/YouCompleteMe
  function Install-YouCompleteMe ([string] $dir) {
    Write-Host 'Installing Vim plugin ''https://github.com/Valloric/YouCompleteMe''' -ForegroundColor Yellow
    $env:Path+= ";$($env:ProgramFiles)\7-Zip"
    $env:Path+= ";$($env:ProgramFiles)\CMake\bin"
    Exec { python $dir\install.py }
  }

  function Install-TernForVim ([string] $dir) {
    Write-Host 'Installing Vim plugin ''https://github.com/ternjs/tern_for_vim''.' -ForegroundColor Yellow
    try {
      Push-Location $dir
      Exec { npm install }
      Pop-Location
    }
    catch {
      throw "Failed installing 'Tern For vim'."
    }
  }

  # Install a plugin manager for vim
  # Link: https://github.com/junegunn/vim-plug
  function Install-Plug {
    # Create the directory if it's not found
    function Create-DirectoryIfNotFound ([string] $path, [scriptblock] $function) {
      if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path
      }
      $function.Invoke()
    }

    Write-Host 'Installing Vim plugin manager ''https://github.com/junegunn/vim-plug'''
    Create-DirectoryIfNotFound "$HOME\.vim" {
      Create-DirectoryIfNotFound "$HOME\.vim\autoload" {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" -OutFile "$HOME\.vim\autoload\plug.vim"
      }
    }
  }

  try {
    if (Get-Command vim) {
      # Run vim, install plugins and quit vim
      if (!(Test-Path "$HOME\.vim\autoload\plug.vim")) {
        Install-Plug
        Exec { vim +PlugInstall +qall }
        Install-YouCompleteMe "$HOME\.vim\plugged\YouCompleteMe"
        #Install-TernForVim "$HOME\.vim\plugged\tern_for_vim"
      }
    }
  }
  catch {
    throw "Could not find editor vim"
  }
}
