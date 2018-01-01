Import-Module posh-git
Import-Module dotfile-helper
Import-Module Get-ChildItemColor
Import-Module util-functions 3> $null
Import-Module PowerShell-Beautifier.psd1

Set-Alias ls Get-ChildItemColorFormatWide -Option AllScope
Set-PSReadlineOption -EditMode vi -BellStyle None
Set-Alias vi vim

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path ($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
  param($commandName, $wordToComplete, $cursorPosition)
  dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

function gRootDirectory {
  if (git rev-parse --is-inside-work-tree 2> $null) {
    $location = git rev-parse --show-toplevel `
      | Resolve-Path `
      | Get-Item
    if ((Get-Location).Path -eq $location) { return }
    else { Push-Location $location }
  } else { throw "'$(Get-Location)' is not a git directory/repository." }
}
