####################################################################################################
#                                                                                                  #
#                                           Setup Files                                            #
#                                                                                                  #
####################################################################################################

function Setup-Files {
  [CmdletBinding()]
  param()

  Get-ChildItem -Path '.\vim' -File `
    | Copy-Item -Destination $HOME -ErrorAction Stop

  Get-ChildItem -Path '.\git' -File `
    | Copy-Item -Destination $HOME -ErrorAction Stop

  Copy-Item `
    -Path '.\powershell\Microsoft.PowerShell_profile.ps1' `
    -Destination $PROFILE  `
    -PassThru `
    -ErrorAction Stop `
    | Unblock-File

  Copy-Item '.\conemu\ConEmu.xml' $env:APPDATA
  Copy-Item -Path '.\tern\.tern-project' -Destination $HOME
  Copy-Item -Path '.\visualStudio\.vsvimrc' -Destination $HOME
}
