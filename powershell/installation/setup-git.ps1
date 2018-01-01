function Setup-Git {
  [CmdletBinding()]
  param()
  $gitConfigPath = Join-Path -Path $HOME -ChildPath '.gitconfig'
  if (Test-Path $gitConfigPath) {
    Write-Verbose "Setting git email to '$gitEmail'"
    Exec { git config --global user.email $gitEmail }
    Write-Verbose "Setting git username set to '$gitName'"
    Exec { git config --global user.name $gitName }
    Exec { npm install -g diff-so-fancy }
  } else {
    throw "Could not find path '$GitConfig'."
  }
}
