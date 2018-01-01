####################################################################################################
#                                                                                                  #
#                                       Installation Script                                        #
#                                                                                                  #
####################################################################################################

param(
  [Parameter(Position = 0, Mandatory = $true)] [string]$gitEmail,
  [Parameter(Position = 1, Mandatory = $true)] [string]$gitName
)
$ErrorActionPreference = "Stop"

. .\powershell\modules\util-functions\util-functions.ps1
. .\powershell\installation\input.ps1


. .\powershell\installation\setup-chocolatey.ps1
Setup-Chocolatey -Verbose

. .\powershell\installation\setup-powershellmodules.ps1
Setup-PowerShellModules -Verbose

. .\PowerShell\installation\setup-directories.ps1
$ToolsDirectory = Setup-Directories -Verbose

. .\powershell\installation\setup-files.ps1
Setup-Files -Verbose

. .\PowerShell\installation\setup-git.ps1
Setup-Git -Verbose

. .\powershell\installation\setup-linters.ps1
Setup-Linters -Verbose

Write-Host 'Script Finished!' -ForegroundColor Green
