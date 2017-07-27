# Create the directory if it's not found
function New-DirectoryIfNotFound ([string] $path, [scriptblock] $function) {
  if (!(Test-Path $path)) {
    New-Item -ItemType Directory -Force -Path $path
  }
  $function.Invoke()
}

# Prompts user for y/n input.
function Confirm-Option ([string] $message) {
  while  (1) {
    Write-Host $message -NoNewLine -ForegroundColor yellow
    Write-Host ' [y/n] ' -NoNewLine -ForegroundColor magenta
    switch(Read-Host) {
      'y' { return $true }
      'n' { return $false }
    }
  }
}

# Check if argument is a number
function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

# Prompts user to choose an item from the array $options.
# Then returns the index of that item.
function Select-Index ([string[]] $options, [string] $property = 'Item') {
  $table = $options | % { $index = 1 } { [PSCustomObject] @{ Option = $index; $property = $_ }; $index++ } | Format-Table -AutoSize | Out-String
  while (1) {
    Write-Host $table
    Write-Host 'Select one of the options.'
    $option = Read-Host
      if (Is-Numeric $option) {
        $index = (iex $option) -1
          if (($index -gt -1) -and ($index -lt $options.length)) {
            return [int] $index
          }
      }
    Write-Host "Error: Please select a number between 1 and $($options.length)" -ForegroundColor red
  }
}

# Install a code-completion engine for vim
# Link: https://github.com/Valloric/YouCompleteMe
function Install-YouCompleteMe {
  # this only works for 64 bit machines.
  # TODO resolve requirements from https://github.com/Valloric/YouCompleteMe#windows
  $env:Path+= ";$($env:ProgramFiles)\CMake\bin"
  $env:Path+= ";$($env:ProgramFiles)\7-Zip"
}

# Install a plugin manager for vim
# Link: https://github.com/junegunn/vim-plug
function Install-Plug {
  New-DirectoryIfNotFound "$HOME\.vim" {
    New-DirectoryIfNotFound "$HOME\.vim\autoload" {
      Invoke-WebRequest -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" -OutFile "$HOME\.vim\autoload\plug.vim"
    }
  }
}

# Check if the command exists.
function Check-Command($cmdname) {
  return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Gets the installed choco packages
function Get-InstalledPackages {
  # Gets the packages names
  $packages = (choco list --local-only) | % { $_.Split(' ') | select -first 1 }
  # if packages is not null
  if ($packages) {
    # Remove the last item where it says the amount of installed packages.
    $packages = $packages[1..($packages.length - 2)]
    return $packages
  } else {
    # Return empty array if $packages is null
    return ,@()
  }
}

# Reload the system path variable.
function Reload-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
}

# Install choco package
function Install-Package ([string] $package, [Object[]] $packages, [bool] $prompt = $false) {
  if ($packages -contains $package) {
    Write-Host "Package '$package' is already installed, skipping..." -ForegroundColor yellow
  } else {
    if ($prompt) {
      if (Confirm-Option "Would you like to install package '$package'?") {
        choco install $package -y
      } else {
        Write-Host "Ignoring package '$package'" -ForegroundColor yellow
      }
    } else {
      choco install $package -y
    }
  }
}

# Installs the choco package manager
# Source: https://chocolatey.org/
function Install-Choco {
  if (Get-ExecutionPolicy -eq 'Restricted') {
    Set-ExecutionPolicy AllSigned
  }
  # Execute the choco installation script.
  iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  Reload-Path
}

# Copies the $file to the home directory.
function Copy-Home ([string] $file) {
  Copy-Item ".\$file" $HOME
}

# Install choco if necessary.
if ((Check-Command choco) -ne $true) {
  Install-Choco
}
####################################################################################################
#                                                                                                  #
#                                           Installation                                           #
#                                                                                                  #
####################################################################################################
$installedPackages = Get-InstalledPackages
Install-Package '7zip' $installedPackages
Install-Package 'cmake' $installedPackages
Install-Package 'git' $installedPackages
Install-Package 'googlechrome' $installedPackages
Install-Package 'googledrive' $installedPackages
Install-Package 'keepass' $installedPackages
Install-Package 'nodejs' $installedPackages
Install-Package 'python2' $installedPackages
Install-Package 'skype' $installedPackages
Install-Package 'slack' $installedPackages
Install-Package 'spotify' $installedPackages
Install-Package 'vim' $installedPackages
Install-Package 'vlc' $installedPackages
Install-Package 'winrar' $installedPackages
Install-Package 'nuget.commandline' $InstalledPackages
Install-Package 'visualstudio2017community' $installedPackages $true
Reload-Path
####################################################################################################
#                                                                                                  #
#                                   Copy files to home directory                                   #
#                                                                                                  #
####################################################################################################
Copy-Home '.gitconfig'
Copy-Home '.gitignore_global'
Copy-Home '.tern-project'
Copy-Home '.vimrc'
Copy-Home '.vimrc.omnisharp'
Copy-Home '.vimrc.plugins'
Copy-Home '.vimrc.syntastic'
# TODO only use .vsvimrc if visual studio is installed.
Copy-Home '.\.visualStudio\.vsvimrc'
####################################################################################################
#                                                                                                  #
#                                            Setup Vim                                             #
#                                                                                                  #
####################################################################################################
if (Confirm-Option 'Do you want to setup vim?') {
  # Run vim, install plugins and quit vim
  if (!(Test-Path "$HOME\.vim\autoload\plug.vim")) {
    Write-Host 'Plug not found, starting installation.' -ForegroundColor yellow
    Install-Plug
  }
  vim +PlugInstall +qall
}
if (Confirm-Option 'Do you want to install standardJS?') {
  npm install standard --global
}
## Check for updates in chocolatey
#cup all -y
