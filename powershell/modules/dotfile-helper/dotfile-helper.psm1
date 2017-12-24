function Save-Dotfile {
  [CmdletBinding()]
  param (
    [Parameter(Position=0, Mandatory=1)][System.IO.DirectoryInfo] $dotfilesDirectory,
    [Parameter(Position=1, Mandatory=1)][string] $commitMessage,
    [Parameter(Position=2, Mandatory=1)][bool] $pushRepo,
    [Parameter(Position=3, Mandatory=1)][System.IO.FileInfo] $sourceFile,
    [Parameter(Position=4, Mandatory=1)][System.IO.FileInfo] $targetFile
  )

  if (Test-Path $dotfilesDirectory) {
    if (Test-Path $sourceFile) {
      Push-Location $dotfiles
      Write-Host "Copying '$($sourceFile.FullName)' to '$($targetFile.FullName)'."
      Copy-Item $sourceFile $targetFile
      git commit $targetFile -m $commitMessage
      if ($pushRepo) { git push }
      Pop-Location
    } else {
      throw "Source file '$sourceFile' not found."
    }
  } else {
    throw "Dotfile directory '$dotfilesDirectory' not found."
  }
}

<#
  .SYNOPSIS
  Saves the ConEmu config file to the dotfiles directory.
#>
function Save-ConEmu {
  [CmdletBinding()]
  param (
    [System.IO.DirectoryInfo] $dotfiles = "$HOME\dotfiles",
    [string] $commitMessage = 'Update ConEmu settings',
    [bool] $pushRepo = $false,
    [System.IO.FileInfo] $sourceFile = "$($env:APPDATA)\ConEmu.xml",
    [System.IO.FileInfo] $targetFile = "$dotfiles\conemu\$($sourceFile.Name)"
  )
  Save-Dotfile $dotfiles $commitMessage $pushRepo $sourceFile $targetFile
}

<#
  .SYNOPSIS
  Saves the PowerShell profile ($PROFILE) file to the dotfiles directory.
#>
function Save-PowerShellProfile {
  [CmdletBinding()]
  param (
    [System.IO.DirectoryInfo] $dotfiles = "$HOME\dotfiles",
    [string] $commitMessage = 'Update PowerShell profile',
    [bool] $pushRepo = $false,
    [System.IO.FileInfo] $sourceFile = $PROFILE,
    [System.IO.FileInfo] $targetFile = "$dotfiles\powershell\$($PROFILE.Name)"
  )
  Save-Dotfile $dotfiles $commitMessage $pushRepo $sourceFile $targetFile
}

<#
  .SYNOPSIS
  Saves the GitConfig file to the dotfiles directory.
#>
function Save-GitConfig {
  [CmdletBinding()]
  param (
    [System.IO.DirectoryInfo] $dotfiles = "$HOME\dotfiles",
    [string] $commitMessage = 'Update GitConfig',
    [bool] $pushRepo = $false,
    [System.IO.FileInfo] $sourceFile = "$HOME\.GitConfig",
    [System.IO.FileInfo] $targetFile = "$dotfiles\git\$($sourceFile.Name)"
  )
  Save-Dotfile $dotfiles $commitMessage $pushRepo $sourceFile $targetFile
}


<#
  .SYNOPSIS
  Saves the .Vimrc file to the dotfiles directory.
#>
function Save-VimConfig {
  [CmdletBinding()]
  param (
    [System.IO.DirectoryInfo] $dotfiles = "$HOME\dotfiles",
    [string] $commitMessage = 'Update Vim config',
    [bool] $pushRepo = $false,
    [System.IO.FileInfo] $sourceFile = "$HOME\.vimrc",
    [System.IO.FileInfo] $targetFile = "$dotfiles\vim\$($sourceFile.Name)"
  )
  Save-Dotfile $dotfiles $commitMessage $pushRepo $sourceFile $targetFile
}

function Save-VimPluginsConfig {
  [CmdletBinding()]
  param (
    [System.IO.DirectoryInfo] $dotfiles = "$HOME\dotfiles",
    [string] $commitMessage = 'Update Vim plugins',
    [bool] $pushRepo = $false,
    [System.IO.FileInfo] $sourceFile = "$HOME\.vimrc.plugins",
    [System.IO.FileInfo] $targetFile = "$dotfiles\vim\$($sourceFile.Name)"
  )
  Save-Dotfile $dotfiles $commitMessage $pushRepo $sourceFile $targetFile
}

$exportModuleMemberParams = @{
    Function = @(
        'Save-ConEmu',
        'Save-PowerShellProfile',
        'Save-GitConfig',
        'Save-VimConfig',
        'Save-VimPluginsConfig'
    )
}

Export-ModuleMember @exportModuleMemberParams
