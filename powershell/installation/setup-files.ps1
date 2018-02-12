####################################################################################################
#                                                                                                  #
#                                           Setup Files                                            #
#                                                                                                  #
####################################################################################################

function Setup-Files {
  [CmdletBinding()]
  param()
  # Copies the $file to the home directory.
  function Copy-Home {
    [CmdletBinding()]
    param(
      [string]$file
    )
    Copy-Item ".\$file" $HOME -Verbose
  }

  function Setup-GitConfig {
    [CmdletBinding()]
    param()
    Copy-Home '.\git\.gitconfig'
    Exec { git config --global user.email $gitEmail }
    Exec { git config --global user.name $gitName }
  }

  function Setup-PowerShellProfile {
    [CmdletBinding()]
    param()
    # Copy PowerShell Profile.
    Copy-Item '.\powershell\Microsoft.PowerShell_profile.ps1' $PROFILE
    Unblock-File -Path $PROFILE
  }

  # Copy ConEmu settings.
  Copy-Item '.\conemu\ConEmu.xml' $env:APPDATA
  # Copy files to home directory
  Copy-Home '.\git\.gitignore_global'
  Copy-Home '.\tern\.tern-project'
  Copy-Home '.\vim\.gvimrc'
  Copy-Home '.\vim\.vimrc'
  Copy-Home '.\vim\.vimrc.omnisharp'
  Copy-Home '.\vim\.vimrc.plugins'
  Copy-Home '.\vim\.vimrc.syntastic'
  Copy-Home '.\visualStudio\.vsvimrc'
  Setup-PowerShellProfile
  Setup-GitConfig
}
