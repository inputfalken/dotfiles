####################################################################################################
#                                                                                                  #
#                                       Installation Script                                        #
#                                                                                                  #
####################################################################################################

param(
  [Parameter(Position = 0,Mandatory = $true)] [string]$gitEmail,
  [Parameter(Position = 1,Mandatory = $true)] [string]$gitName
)
$ErrorActionPreference = "Stop"

. .\powershell\modules\util-functions\util-functions.ps1
. .\powershell\installation\input.ps1


. .\powershell\installation\setup-chocolatey.ps1
Setup-Chocolatey -Verbose

. .\powershell\installation\setup-powershellmodules.ps1
Setup-PowerShellModules -Verbose

. .\powershell\installation\setup-vim.ps1
Setup-Vim -Verbose

. .\powershell\installation\setup-files.ps1
Setup-Files -Verbose

. .\powershell\installation\setup-linters.ps1
Setup-Linters -Verbose

## Check for updates in chocolatey
#cup all -y
# Play sound when finished
Write-Host 'Script Finished!' -ForegroundColor Green
