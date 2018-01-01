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
    When-Command choco -Found {
      Write-Verbose 'Package manager Chocolatey is allready installed.'
    } -NotFound {
      Write-Verbose 'Installing package manager Chocolatey.'
      Invoke-WebRequest -Uri 'https://chocolatey.org/install.ps1' `
        | Select-Object -ExpandProperty content `
        | Invoke-Expression
      Reload-Path
    }
  }

  # Install a chocolatey package.
  function Install-ChocolateyPackage ([string]$package, [bool]$prompt = $false) {
    if ($installedPackages -contains $package) {
      Write-Verbose "Package $package is already installed, skipping installment."
    } else {
      # If prompt and the confirmation is false.
      if ($prompt -and !(Confirm-Option "Would you like to install package '$package'?")) {
        return
      }
      Exec { choco install $package -y }
    }
  }

  Install-Chocolatey
  $installedPackages = Exec { Get-ChocolateyPackages | Select-Object -ExpandProperty Package }
  Install-ChocolateyPackage '7zip'
  Install-ChocolateyPackage 'cmake'
  Install-ChocolateyPackage 'conemu'
  Install-ChocolateyPackage 'dotnetcore'
  Install-ChocolateyPackage 'dotnetcore-sdk'
  Install-ChocolateyPackage 'git'
  Install-ChocolateyPackage 'googlechrome'
  Install-ChocolateyPackage 'googledrive'
  Install-ChocolateyPackage 'jdk8'
  Install-ChocolateyPackage 'neovim'
  Install-ChocolateyPackage 'nodejs'
  Install-ChocolateyPackage 'nuget.commandline'
  Install-ChocolateyPackage 'postman'
  Install-ChocolateyPackage 'powershell-core'
  Install-ChocolateyPackage 'Python'
  Install-ChocolateyPackage 'python2'
  Install-ChocolateyPackage 'ruby'
  Install-ChocolateyPackage 'slack'
  Install-ChocolateyPackage 'vim'
  Reload-Path
}
