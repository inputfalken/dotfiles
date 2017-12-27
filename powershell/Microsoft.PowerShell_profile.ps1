# Sets the outputencoding to UTF8 so Vim works with XTerm when a ConEmu session is active.
# NOTE this however affects all commands. A solution would be to find a way to only use this encoding for Vim.
if ($env:ConEmuBuild){
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
}

Import-Module posh-git
Import-Module dotfile-helper
Import-Module Get-ChildItemColor
Set-Alias ls Get-ChildItemColorFormatWide -option AllScope

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
  Lists choco packages name and version.
  Returns an array of PSCustomObject with properties:
  * Package
  * Version
#>
function Get-ChocolateyPackages {
  function Take-While() {
    param ( [scriptblock]$pred = $(throw "Need a predicate") )
      begin {
        $take = $true
      }
    process {
      if ( $take ) {
        $take = & $pred $_
          if ( $take ) {
            $_
          }
      }
    }
  }
  Write-Host 'Getting installed packages' -ForegroundColor Yellow
  # Gets the packages names
  $packages = choco list --local-only
  # if packages is not null.
  if ($packages) {
    # Get rid of redundant info,
    $packages = $packages | Take-While { $args[0] -NotMatch '\d\spackages\sinstalled\.' }
    $packages | % {
      $split = $_.Split(' ')
      [PSCustomObject] @{ Package=$split[0] ; Version=$split[1] }
    } | Sort-Object Package
  } else {
    # Return empty array if $packages is null
    @()
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
