function Save-Dotfile {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0,Mandatory = 1)] [System.IO.DirectoryInfo]$dotfilesRepo,
    [Parameter(Position = 1,Mandatory = 1)] [string]$message,
    [Parameter(Position = 2,Mandatory = 1)] [bool]$push,
    [Parameter(Position = 3,Mandatory = 1)] [System.IO.FileInfo]$sourceFile,
    [Parameter(Position = 4,Mandatory = 1)] [System.IO.FileInfo]$targetFile,
    [Parameter(Position = 5,Mandatory = 0)] [scriptblock]$beforeCommit = {}
  )

  if (Test-Path $dotfilesRepo) {
    if (Test-Path $sourceFile) {
      Push-Location $dotfilesRepo
      Write-Host "Copying '$($sourceFile.FullName)' to '$($targetFile.FullName)'."
      Copy-Item $sourceFile $targetFile
      Invoke-Command $beforeCommit
      git commit $targetFile -m $message
      if ($push) { git push }
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
  Saves the ConEmu config file to the dotfilesRepo directory.
#>
function Save-ConEmu {
  [CmdletBinding()]
  param(
    [System.IO.DirectoryInfo]$dotfilesRepo = "$HOME\dotfiles",
    [string]$message = 'Update ConEmu settings',
    [bool]$push = $false,
    [System.IO.FileInfo]$sourceFile = "$($env:APPDATA)\ConEmu.xml",
    [System.IO.FileInfo]$targetFile = "$dotfilesRepo\conemu\$($sourceFile.Name)"
  )
  Save-Dotfile -dotfilesRepo $dotfilesRepo -Message $message -push $push -sourceFile $sourceFile -targetFile $targetFile
}

<#
  .SYNOPSIS
  Saves the PowerShell profile ($PROFILE) file to the dotfilesRepo directory.
#>
function Save-PowerShellProfile {
  [CmdletBinding()]
  param(
    [System.IO.DirectoryInfo]$dotfilesRepo = "$HOME\dotfiles",
    [string]$message = 'Update PowerShell profile',
    [bool]$push = $false,
    [System.IO.FileInfo]$sourceFile = $PROFILE,
    [System.IO.FileInfo]$targetFile = "$dotfilesRepo\powershell\$($PROFILE.Name)"
  )
  Save-Dotfile -dotfilesRepo $dotfilesRepo -Message $message -push $push -sourceFile $sourceFile -targetFile $targetFile
}

<#
  .SYNOPSIS
  Saves the GitConfig file to the dotfilesRepo directory.
#>
function Save-GitConfig {
  [CmdletBinding()]
  param(
    [System.IO.DirectoryInfo]$dotfilesRepo = "$HOME\dotfiles",
    [string]$message = 'Update GitConfig',
    [bool]$push = $false,
    [System.IO.FileInfo]$sourceFile = "$HOME\.gitconfig",
    [System.IO.FileInfo]$targetFile = "$dotfilesRepo\git\$($sourceFile.Name)"
  )

  $name = git config --global user.name
  $email = git config --global user.email
  git config --global user.name 'Name'
  git config --global user.email 'Email'
  Save-Dotfile -dotfilesRepo $dotfilesRepo -Message $message -push $push -sourceFile $sourceFile -targetFile $targetFile -BeforeCommit {
    git config --global user.name $name
    git config --global user.email $email
  }
}

<#
  .SYNOPSIS
  Saves the .Vimrc file to the dotfilesRepo directory.
#>
function Save-VimConfig {
  [CmdletBinding()]
  param(
    [System.IO.DirectoryInfo]$dotfilesRepo = "$HOME\dotfiles",
    [string]$message = 'Update Vim config',
    [bool]$push = $false,
    [System.IO.FileInfo]$sourceFile = "$HOME\.vimrc",
    [System.IO.FileInfo]$targetFile = "$dotfilesRepo\vim\$($sourceFile.Name)"
  )
  Save-Dotfile -dotfilesRepo $dotfilesRepo -Message $message -push $push -sourceFile $sourceFile -targetFile $targetFile
}

function Save-VimPluginsConfig {
  [CmdletBinding()]
  param(
    [System.IO.DirectoryInfo]$dotfilesRepo = "$HOME\dotfiles",
    [string]$message = 'Update Vim plugins',
    [bool]$push = $false,
    [System.IO.FileInfo]$sourceFile = "$HOME\.vimrc.plugins",
    [System.IO.FileInfo]$targetFile = "$dotfilesRepo\vim\$($sourceFile.Name)"
  )
  Save-Dotfile -dotfilesRepo $dotfilesRepo -Message $message -push $push -sourceFile $sourceFile -targetFile $targetFile
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
