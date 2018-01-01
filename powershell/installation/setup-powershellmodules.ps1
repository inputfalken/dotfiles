####################################################################################################
#                                                                                                  #
#                                    Install PowerShell Modules                                    #
#                                                                                                  #
####################################################################################################

function Setup-PowerShellModules {
  function Install-LocalPowerShellModule {
      param(
        [Parameter(Position=0, Mandatory=1)][string] $module,
        [Parameter(Position=1)][string] $localModules = "./powershell/modules/$module"
      )

      if (Test-Path $localModules) {
        try {
          $profileDirectory = '~\Documents\WindowsPowerShell\Modules'
          Copy-Item -Recurse -Force -Path $localModules -Destination "$profileDirectory"
          Write-Host "Successfully installed module '$module'." -ForegroundColor Green
        }
        catch {
          Write-Host "Failed to install module '$module'." -ForegroundColor -Red
        }
      } else {
        Write-Host "Path '$localModules' not found" -ForegroundColor Red
      }
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
    function Is-Installed () {
      Write-Host "Looking if PowerShell module '$module' is installed."
      Get-Module -ListAvailable -Name $module
    }

    if (Is-Installed) {
      Write-Host -NoNewLine 'Online PowerShell module '
      Write-Host -NoNewLine $module -ForegroundColor yellow
      Write-Host -NoNewLine ' is already installed, attempting to update.'
      Write-Host
      Write-Host "Attempting to update module '$module'."
      Update-Module -Name $module -Force
      $modules = (Get-Module -Name 'z' -ListAvailable) | Sort-Object -Property Version -Descending
      if ($modules.length -gt 1) {
        Write-Host "Update added for module '$module'."
        Write-Host "Removing old versions of module '$module'."
        $oldModules = $modules[1..$modules.Length] | Select-Object -ExpandProperty Path | Remove-Item -Force -Recurse -Verbose
      } else {
        Write-Host "No update found for module '$module'."
      }
    } else {
      PowerShellGet\Install-Module -Name $module -Scope CurrentUser -AllowClobber -Force -Verbose
    }
  }
  Install-PowerShellModule 'posh-git'
  Install-PowerShellModule 'z'
  Install-PowerShellModule 'Get-ChildItemColor'
  Install-LocalPowerShellModule 'dotfile-helper'
  Install-LocalPowerShellModule 'util-functions'
}
