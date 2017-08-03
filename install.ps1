
# Create the directory if it's not found
function Create-DirectoryIfNotFound ([string] $path, [scriptblock] $function) {
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
# Then returns the selected item
function Select-Item ([string[]] $options, [string] $property = 'Item') {
  $table = $options | % { $index = 1 } { [PSCustomObject] @{ Option = $index; $property = $_ }; $index++ } | Format-Table -AutoSize | Out-String
  while (1) {
    Write-Host $table
    Write-Host 'Select one of the options.'
    $option = Read-Host
      if (Is-Numeric $option) {
        $index = (iex $option) -1
          if (($index -gt -1) -and ($index -lt $options.length)) {
            return [string] $options[$index]
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
  Create-DirectoryIfNotFound "$HOME\.vim" {
    Create-DirectoryIfNotFound "$HOME\.vim\autoload" {
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
function Install-Package ([string] $package, [string[]] $packages, [bool] $prompt = $false) {
  if ($packages -contains $package) {
    Write-Host -NoNewLine 'Package '
    Write-Host -NoNewLine $package -ForegroundColor yellow
    Write-Host -NoNewLine ' is already installed, skipping installment.'
    Write-Host
  } else {
    # If prompt and the confirmation is false.
    if ($prompt -and !(Confirm-Option "Would you like to install package '$package'?")) {
      return
    }
    choco install $package -y
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
  Write-Host -NoNewLine 'Copying '
  Write-Host -NoNewLine $File -ForegroundColor yellow
  Write-Host -NoNewLine ' to '
  Write-Host -NoNewLine $HOME -ForegroundColor yellow
  Write-Host
  Copy-Item ".\$file" $HOME
}

# Test a condition for a command
function Test-Any() { process { $true; break } end { $false } }

# Install Solarized-Dark
# From https://github.com/neilpa/cmd-colors-solarized solarized
function Install-Solarized ([string] $theme) {
    # Clone the repository
    git clone https://github.com/neilpa/cmd-colors-solarized solarized
    $powershellPath = "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk"
    #Run Update-Link
    .\solarized\Update-Link.ps1 $powershellPath $theme
    # Remove solarized without prompt
    Remove-Item .\solarized\ -Recurse -Force
    #TODO proper escaping, double quotes is not needed inside the string.
    $script =  '. (Join-Path -Path (Split-Path -Parent -Path $PROFILE) -ChildPath $(switch($HOST.UI.RawUI.BackgroundColor.ToString()){"White"{"Set-SolarizedLightColorDefaults.ps1"}"Black"{"Set-SolarizedDarkColorDefaults.ps1"}default{return}}))'
    # If the $script is not found in $PROFILE, append the script to $PROFILE.
    if ((Get-Content $PROFILE | ?{$_ -eq $script} | Test-Any) -eq $false) {
      Add-Content $PROFILE '# Source: https://github.com/neilpa/cmd-colors-solarized#update-your-powershell-profile'
      Add-Content $PROFILE $script
    }
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
Install-Package 'nodejs' $installedPackages
Install-Package 'python2' $installedPackages
Install-Package 'vim' $installedPackages
Install-Package 'nuget.commandline' $InstalledPackages
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
