####################################################################################################
#                                                                                                  #
#                                    Install PowerShell Modules                                    #
#                                                                                                  #
####################################################################################################

function Setup-PowerShellModules {
  [CmdletBinding()]
  param()

  [System.IO.DirectoryInfo] $profileDirectory = ([System.IO.FileInfo] $PROFILE).DirectoryName
  [System.IO.DirectoryInfo] $profileModules = "$profileDirectory\Modules"

  function Install-LocalPowerShellModule {
    [CmdletBinding()]
    param(
      [Parameter(Position=0, Mandatory=1)][string] $module,
      [Parameter(Position=1)][string] $dotfilesModules = "./powershell/modules/$module"
    )
    Copy-Item -Recurse -Force -Path $dotfilesModules -Destination $profileModules
  }

  # Installs a PowerShell module
  # First attempts to find a local module and then add/override it.
  # If no local module is found it attempts to see if the module allready exists,
  # if module exists nothing is done otherwise an attempt is made to locate it online and then install it.
  function Install-PowerShellModule {
    [CmdletBinding()]
    param(
      [Parameter(Position=0)][string] $module
    )

    function Is-Installed () {
      Get-Module -ListAvailable -Name $module
    }

    if (Is-Installed) {
      Update-Module -Name $module -Force
      $modules = (Get-Module -Name $module -ListAvailable) | Sort-Object -Property Version -Descending
      if ($modules.length -gt 1) {
        Write-Verbose "Update added for module '$module'."
        Write-Verbose "Removing old versions of module '$module'."
        $oldModules = $modules[1..$modules.Length] | Select-Object -ExpandProperty Path | Remove-Item -Force -Recurse
      } else {
        Write-Verbose "No update found for module '$module'."
      }
    } else {
      PowerShellGet\Install-Module -Name $module -Scope CurrentUser -AllowClobber -Force
    }
  }
  Install-PowerShellModule 'posh-git'
  Install-PowerShellModule 'z'
  Install-PowerShellModule 'Get-ChildItemColor'
  Install-LocalPowerShellModule 'dotfile-helper'
  Install-LocalPowerShellModule 'util-functions'
}
