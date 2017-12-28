####################################################################################################
#                                                                                                  #
#                              Install Chocolatey & Install Packages                               #
#                                                                                                  #
####################################################################################################


function Setup-Chocolatey {
  . .\utils.ps1
  # Installs the choco package manager
  # Source: https://chocolatey.org/
  function Install-Chocolatey {
    # Install choco if necessary.
    if (!(Check-Command choco)) {
      Write-Host 'Installing package manager Chocolatey.' -ForegroundColor Yellow
      # Execute the choco installation script.
      iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
      Reload-Path
    } else {
      Write-Host 'Package manager Chocolatey is allready installed.'
    }
  }

  # Install a chocolatey package.
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
      Exec {  choco install $package -y  }
    }
  }
  Install-Chocolatey
  $installedPackages = Exec { Get-ChocolateyPackages | Select-Object -ExpandProperty Package }
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
  Install-ChocolateyPackage '7zip'
  Install-ChocolateyPackage 'cmake'
  Reload-Path
}
