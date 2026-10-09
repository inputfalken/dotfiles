Import-Module util-functions 3> $null

## posh-git {
  # Only needed for git autocomplete, so load it on the first git tab completion
  Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    Import-Module posh-git
    Expand-GitCommand $commandAst.Extent.Text.Substring(0, $cursorPosition - $commandAst.Extent.StartOffset)
  }
#}

## oh-my-posh {
  # `--print` skips the temporary init script, see https://ohmyposh.dev/docs/installation/prompt (PowerShell).
  & ([ScriptBlock]::Create((oh-my-posh init pwsh --config ~/minimal.omp.json --print) -join "`n"))
#}

# Terminal Icons {
  Import-Module -Name Terminal-Icons
#}

# PSReadline {
  # EditMode resets key handlers, so it is set before them.
  Set-PSReadLineOption -BellStyle None -EditMode vi -PredictionSource History -PredictionViewStyle ListView
  Set-PSReadlineKeyhandler -Key ctrl+n -Function ViTabCompleteNext
  Set-PSReadlineKeyhandler -Key ctrl+p -Function ViTabCompletePrevious
  Set-PSReadlineKeyhandler -Key Shift+Insert -Function Paste
  Remove-PSReadLineKeyHandler -Key ctrl+v
  Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
#}

# PowerShell parameter completion shim for the dotnet CLI {
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
#}

## Azure CLI {
Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    $completion_file = New-TemporaryFile
    $env:ARGCOMPLETE_USE_TEMPFILES = 1
    $env:_ARGCOMPLETE_STDOUT_FILENAME = $completion_file
    $env:COMP_LINE = $wordToComplete
    $env:COMP_POINT = $cursorPosition
    $env:_ARGCOMPLETE = 1
    $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
    $env:_ARGCOMPLETE_IFS = "`n"
    $env:_ARGCOMPLETE_SHELL = 'powershell'
    az 2>&1 | Out-Null
    Get-Content $completion_file | Sort-Object | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
    }
    Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, Env:\ARGCOMPLETE_USE_TEMPFILES, Env:\COMP_LINE, Env:\COMP_POINT, Env:\_ARGCOMPLETE, Env:\_ARGCOMPLETE_SUPPRESS_SPACE, Env:\_ARGCOMPLETE_IFS, Env:\_ARGCOMPLETE_SHELL
}
#}

## KubeCtl {
  # Only needed for kubectl tab completion, so the script `kubectl completion powershell` generates is loaded on the
  # first completion. It lives in a module so its helper functions outlive this scriptblock.
  Register-ArgumentCompleter -Native -CommandName kubectl -ScriptBlock {
    $module = New-Module kubectl-completion ([scriptblock]::Create((kubectl completion powershell | Out-String))) | Import-Module -Global -PassThru
    & (& $module { $__kubectlCompleterBlock }) @args
  }
#}

# Machine-local profile {
  # Untracked, per-machine additions live next to $PROFILE (outside the dotfiles repo)
  $localProfile = Join-Path (Split-Path $PROFILE) 'profile.local.ps1'
  if (Test-Path $localProfile) { . $localProfile }
  Remove-Variable localProfile
#}
