Import-Module posh-git
Import-Module dotfile-helper
Import-Module Get-ChildItemColor
Import-Module util-functions 3> $null

Set-Alias ls Get-ChildItemColorFormatWide -Option AllScope
Set-PSReadlineOption -BellStyle None
Set-PSReadlineOption -EditMode vi
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyhandler -Key ctrl+n -Function ViTabCompleteNext
Set-PSReadlineKeyhandler -Key ctrl+p -Function ViTabCompletePrevious
Set-PSReadlineKeyhandler -Key Shift+Insert -Function Paste
Remove-PSReadLineKeyHandler -Key ctrl+v


Set-Alias vi vim

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path ($ChocolateyProfile))
{
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
  [CmdletBinding()]
  Param(
    [Parameter(Position = 0, Mandatory = 0)][switch] $Push = $false
  )
  if (Get-Command -CommandType Application -Name 'git'  -ErrorAction SilentlyContinue) {
    if (git rev-parse --is-inside-work-tree 2> $null) {
      $location = git rev-parse --show-toplevel `
        | Resolve-Path `
        | Get-Item
      if ((Get-Location).Path -eq $location) { return } else {
        if ($Push) { Push-Location $location }
        else { Set-Location $location }
      }
    } else { throw "'$(Get-Location)' is not a git directory/repository." }
  } else { throw "Function 'gRootDirectory' requires 'git' to be globally available." }
}

$PowerShellAnalyzerRules = @{
  IncludeRules = @(
    'PSPlaceOpenBrace',
    'PSPlaceCloseBrace',
    'PSUseConsistentWhitespace',
    'PSUseConsistentIndentation',
    'PSAlignAssignmentStatement'
  )

  Rules        = @{
    PSPlaceOpenBrace           = @{
      Enable             = $true
      OnSameLine         = $true
      NewLineAfter       = $true
      IgnoreOneLineBlock = $true
    }

    PSPlaceCloseBrace          = @{
      Enable             = $true
      NewLineAfter       = $false
      IgnoreOneLineBlock = $true
      NoEmptyLineBefore  = $false
    }

    PSUseConsistentIndentation = @{
      Enable          = $true
      Kind            = 'space'
      IndentationSize = 2
    }

    PSUseConsistentWhitespace  = @{
      Enable         = $true
      CheckOpenBrace = $true
      CheckOpenParen = $true
      CheckOperator  = $true
      CheckSeparator = $true
    }

    PSAlignAssignmentStatement = @{
      Enable         = $true
      CheckHashtable = $true
    }
  }
}

# So neovim can exit properly by clearing itself.
$env:TERM='xterm-256color'
