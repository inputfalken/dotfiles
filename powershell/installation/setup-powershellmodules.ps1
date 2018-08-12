####################################################################################################
#                                                                                                  #
#                                    Install PowerShell Modules                                    #
#                                                                                                  #
####################################################################################################

# TODO instead of using $PSScriptRoot, find the root directory by using git.
function Setup-PowerShellModules {
  [CmdletBinding()]
  param()

  # "Installs" local modules.
  Join-Path $PSScriptRoot '..\modules\' `
    | Get-ChildItem -ErrorAction Stop `
    | Copy-Item -Destination  (Join-Path ($PROFILE | Get-Item).DirectoryName 'modules') -Force -ErrorAction Stop


  Install-Module -Name 'posh-git' -Scope CurrentUser -AllowClobber -Force
  Install-Module -Name 'PowerShell-Beautifier' -Scope CurrentUser -AllowClobber -Force
  Install-Module -Name 'Get-ChildItemColor' -Scope CurrentUser -AllowClobber -Force
  Install-Module -Name 'PSScriptAnalyzer' -Scope CurrentUser -AllowClobber -Force
}
