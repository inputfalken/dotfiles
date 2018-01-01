# Sets the outputencoding to UTF8 so Vim works with XTerm when a ConEmu session is active.
# NOTE this however affects all commands. A solution would be to find a way to only use this encoding for Vim.
if ($env:ConEmuBuild){
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
}

Import-Module posh-git
Import-Module dotfile-helper
Import-Module Get-ChildItemColor
Import-Module util-functions

Set-Alias ls Get-ChildItemColorFormatWide -option AllScope
Set-PSReadlineOption -EditMode vi
Set-Alias vi vim

<#
.SYNOPSIS
  Recompiles the vim plugin 'YouCompleteMe' this is useful when updating YouCompleteMe.
  In order for this function to work; you need to have 7-Zip and CMake installed.
.EXAMPLE
  Compile-YCM "$HOME\.vim\plugged\YouCompleteMe"
#>
function Compile-YCM {
  [CmdletBinding()]
  param(
      [Parameter(Position=0,Mandatory=0)][string]$directory =  "$HOME\.vim\plugged\YouCompleteMe"
  )
  $env:Path+= ";$($env:ProgramFiles)\7-Zip"
  $env:Path+= ";$($env:ProgramFiles)\CMake\bin"
  python "$directory\install.py"
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
