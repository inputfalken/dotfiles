####################################################################################################
#                                                                                                  #
#                                       Installation Script                                        #
#                                                                                                  #
####################################################################################################

param(
  [Parameter(Position=0, Mandatory=$true)][string] $gitEmail,
  [Parameter(Position=1, Mandatory=$true)][string] $gitName
)
$ErrorActionPreference = "Stop"

. .\powershell\installation\exec.ps1
. .\powershell\Microsoft.PowerShell_profile.ps1
. .\powershell\installation\input.ps1


. .\powershell\installation\chocolatey.ps1
Setup-Chocolatey

. ./powershell/installation/powershellmodules.ps1
Setup-PowerShellModules

. .\powershell\installation\vim.ps1
Setup-Vim

. .\powershell\installation\fileplacement.ps1
Setup-Files

## Check for updates in chocolatey
#cup all -y
# Play sound when finished
Write-Host 'Script Finished!' -ForegroundColor Green
(New-Object System.Media.SoundPlayer "$env:windir\Media\tada.wav").play()
