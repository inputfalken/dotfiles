# Sets the outputencoding to UTF8 so Vim works with XTerm.
# NOTE this however affects all commands. A solution would be to find a way to only use this encoding for Vim.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Import-Module posh-git
Import-Module dotfile-helper
Set-PSReadlineOption -EditMode vi

<#
.SYNOPSIS
  Reloads the System Envrionmental variable PATH
#>
function Reload-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

<#
.SYNOPSIS
  Lists the choco packages installed.
#>
function Get-ChocolateyPackages {
  Write-Host 'Getting installed packages' -ForegroundColor Yellow
  # Gets the packages names
  $packages = (choco list --local-only) | % { $_.Split(' ') | select -first 1 }
  # if packages is not null
  if ($packages) {
    # Remove the last item where it says the amount of installed packages.
    $packages = $packages[1..($packages.length - 2)]
    return $packages
  } else {
    # Return empty array if $packages is null
    return ,@()
  }
}

function Create-Link ($target, $link) {
  New-Item -Path $link -ItemType SymbolicLink -Value $target
}

Set-Alias vi vim

function Tail-File {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string]$path
    )
    Get-Content $path -Wait
}

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
