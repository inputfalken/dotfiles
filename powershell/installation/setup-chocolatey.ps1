####################################################################################################
#                                                                                                  #
#                              Install Chocolatey & Install Packages                               #
#                                                                                                  #
####################################################################################################


function Setup-Chocolatey {
  [CmdletBinding()]
  param()
  # Installs the choco package manager
  # Source: https://chocolatey.org/
  function Install-Chocolatey {
    $command = Get-Command -CommandType Application -Name 'choco' -ErrorAction SilentlyContinue
    if ($command) {
      Write-Host "$($command.Source) exists, skipping installation."
    } else {
      $uri = 'https://chocolatey.org/install.ps1' 
      Write-Host "Installing package manager Chocolatey from '$uri'."
      Invoke-WebRequest -Uri $uri`
        | Select-Object -ExpandProperty content `
        | Invoke-Expression
      Reload-Path
    }
  }

  Install-Chocolatey
  $installedPackages = Exec { Get-ChocolateyPackages | Select-Object -ExpandProperty Package }

  function Install-ChocolateyPackage ([string]$Package, [bool]$Prompt = $false) {
    if ($installedPackages -contains $Package) {
      Write-Host "Package $package is already installed, skipping installment."
    } else {
      if ($Prompt -and !(Confirm-Option "Would you like to install package '$Package'?")) { return }
      Exec { choco install $Package -y }
    }
  }

  Install-ChocolateyPackage '7zip'
  Install-ChocolateyPackage 'awscli'
  Install-ChocolateyPackage 'dotnetcore'
  Install-ChocolateyPackage 'Firefox'
  Install-ChocolateyPackage 'git'
  Install-ChocolateyPackage 'GoogleChrome'
  # Google Play Music Desktop Player UNOFFICIAL
  Install-ChocolateyPackage 'gpmdp'
  Install-ChocolateyPackage 'jdk8'
  Install-ChocolateyPackage 'neovim'
  Install-ChocolateyPackage 'nodejs'
  Install-ChocolateyPackage 'nuget.commandline'
  Install-ChocolateyPackage 'postman'
  Install-ChocolateyPackage 'powershell-core'
  Install-ChocolateyPackage 'python2'
  Install-ChocolateyPackage 'python3'
  Install-ChocolateyPackage 'ruby'
  Install-ChocolateyPackage 'slack'
  Install-ChocolateyPackage 'vim'
  Install-ChocolateyPackage 'vlc'
  Reload-Path
}
