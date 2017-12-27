####################################################################################################
#                                                                                                  #
#                                           Setup Files                                            #
#                                                                                                  #
####################################################################################################

function Setup-Files {
# Copies the $file to the home directory.
  function Copy-Home ([string] $file) {
    Write-Host -NoNewLine 'Copying '
    Write-Host -NoNewLine $File -ForegroundColor yellow
    Write-Host -NoNewLine ' to '
    Write-Host -NoNewLine $HOME -ForegroundColor yellow
    Write-Host
    Copy-Item ".\$file" $HOME
  }

  function Setup-GitConfig {
    Copy-Home '.\git\.gitconfig'
    git config --global user.email $gitEmail
    git config --global user.name $gitName
  }

  function Setup-PowerShellProfile {
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
