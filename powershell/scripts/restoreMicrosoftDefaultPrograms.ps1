[CmdletBinding(SupportsShouldProcess = $True)]
param()
function Restore-WindowsApps {
  param()
  Get-AppxPackage -AllUsers | ForEach-Object {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
  }
}
Restore-WindowsApps
