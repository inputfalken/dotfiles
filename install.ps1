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

. .\powershell\installation\utils.ps1
. .\powershell\Microsoft.PowerShell_profile.ps1
. .\powershell\installation\input.ps1


. .\powershell\installation\setup-chocolatey.ps1
Setup-Chocolatey

. ./powershell/installation/setup-powershellmodules.ps1
Setup-PowerShellModules

. .\powershell\installation\setup-vim.ps1
Setup-Vim

. .\powershell\installation\setup-files.ps1
Setup-Files

. .\powershell\installation\setup-linters.ps1
Setup-Linters

## Check for updates in chocolatey
#cup all -y
# Play sound when finished
Write-Host 'Script Finished!' -ForegroundColor Green
(New-Object System.Media.SoundPlayer "$env:windir\Media\tada.wav").play()
