$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"
Import-Module posh-git
Import-Module dotfile-helper
Import-Module Get-ChildItemColor
Import-Module util-functions 3> $null
Import-Module oh-my-posh
Import-Module '~/Documents/PowerShell/Modules/JSON2Class/PowerShellModule.dll'


Set-Theme Agnoster
$DefaultUser = $env:UserName

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

if ($env:NVIM_LISTEN_ADDRESS) {
  $env:EDITOR = 'nvr'
  Set-Alias 'hh' 'nvr -o'
  Set-Alias 'vv' 'nvr -O'
  Set-Alias 'tt' 'nvr --remote-tab'
} else {
  $env:EDITOR = 'nvim'
}
$env:GIT_EDITOR = $EDITOR
$env:VISUAL = $EDITOR

function Get-ProcessByPort($port) {
  Get-Process -Id (Get-NetTCPConnection -LocalPort $port).OwningProcess
}
