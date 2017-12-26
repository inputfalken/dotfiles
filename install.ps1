param(
  [Parameter(Position=0, Mandatory=$true)][string] $gitEmail,
  [Parameter(Position=1, Mandatory=$true)][string] $gitName
)
$ErrorActionPreference = "Stop"

. .\powershell\Microsoft.PowerShell_profile.ps1
. .\powershell\input.ps1

# Create the directory if it's not found
function Create-DirectoryIfNotFound ([string] $path, [scriptblock] $function) {
  if (!(Test-Path $path)) {
    New-Item -ItemType Directory -Force -Path $path
  }
  $function.Invoke()
}

# Check if the command exists.
function Check-Command($cmdname) {
  return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Install choco package
function Install-ChocolateyPackage ([string] $package, [bool] $prompt = $false) {
  if ($installedPackages -contains $package) {
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
function Install-Chocolatey {
  Write-Host 'Installing Choco' -ForegroundColor Yellow
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


# Installs a PowerShell module
# First attempts to find a local module and then add/override it.
# If no local module is found it attempts to see if the module allready exists,
# if module exists nothing is done otherwise an attempt is made to locate it online and then install it.
function Install-PowerShellModule {
  param(
    [Parameter(Position=0)][string] $module,
    [Parameter(Position=1)][string] $localModules = "./powershell/modules/$module"
  )

  function Is-Local () {
    Write-Host "Looking localy for PowerShell module '$module'."
    Test-Path $localModules
  }
  function Is-Installed () {
    Write-Host "Looking if PowerShell module '$module' is installed."
    !(Get-Module -ListAvailable -Name $module)
  }
  if (Is-Local) {
    $profileDirectory = '~\Documents\WindowsPowerShell\Modules'
    Copy-Item -Recurse -Force -Path $localModules -Destination "$profileDirectory\modules"

    if ($?) { Write-Host "Successfully installed module '$module'." -ForegroundColor Green }
    else { Write-Host "Failed to install module '$module'." -ForegroundColor -Red }
  }
  elseif (Is-Installed) {
    PowerShellGet\Install-Module -Name $module -Scope CurrentUser -AllowClobber -Force
  } else {
    Write-Host -NoNewLine 'Online PowerShell module '
    Write-Host -NoNewLine $module -ForegroundColor yellow
    Write-Host -NoNewLine ' is already installed, skipping installment.'
    Write-Host
  }
}

# Install choco if necessary.
if (!(Check-Command choco)) {
  Install-Chocolatey
}
$installedPackages = (Get-ChocolateyPackages | Select-Object -ExpandProperty Package)

####################################################################################################
#                                                                                                  #
#                                           Installation                                           #
#                                                                                                  #
####################################################################################################

Install-ChocolateyPackage 'conemu'
Install-ChocolateyPackage 'dotnetcore'
Install-ChocolateyPackage 'dotnetcore-sdk'
Install-ChocolateyPackage 'git'
Install-ChocolateyPackage 'googlechrome'
Install-ChocolateyPackage 'nodejs'
Install-ChocolateyPackage 'nuget.commandline'
Install-ChocolateyPackage 'postman'
Install-ChocolateyPackage 'python2'
Install-ChocolateyPackage 'vim'
Install-ChocolateyPackage 'ruby'
Install-ChocolateyPackage 'googledrive'
Reload-Path

####################################################################################################
#                                                                                                  #
#                                         Setup PowerShell                                         #
#                                                                                                  #
####################################################################################################

Install-PowerShellModule 'posh-git'
Install-PowerShellModule 'z'
Install-PowerShellModule 'dotfile-helper'
Copy-Item '.\powershell\Microsoft.PowerShell_profile.ps1' $PROFILE
Unblock-File -Path $PROFILE
Copy-Item '.\conemu\ConEmu.xml' $env:APPDATA

####################################################################################################
#                                                                                                  #
#                                   Copy files to home directory                                   #
#                                                                                                  #
####################################################################################################

Copy-Home '.\git\.gitconfig'
git config --global user.email $gitEmail
git config --global user.name $gitName
Copy-Home '.\git\.gitignore_global'
Copy-Home '.\tern\.tern-project'
Copy-Home '.\vim\.gvimrc'
Copy-Home '.\vim\.vimrc'
Copy-Home '.\vim\.vimrc.omnisharp'
Copy-Home '.\vim\.vimrc.plugins'
Copy-Home '.\vim\.vimrc.syntastic'
Copy-Home '.\visualStudio\.vsvimrc'

. .\powershell\vim.ps1

## Check for updates in chocolatey
#cup all -y
# Play sound when finished
Write-Host 'Script Finished!' -ForegroundColor Green
(New-Object System.Media.SoundPlayer "$env:windir\Media\tada.wav").play()
