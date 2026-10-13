Import-Module util-functions

## posh-git {
# Only needed for git autocomplete, so load it on the first git tab completion
Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  Import-Module posh-git
  Expand-GitCommand $commandAst.Extent.Text.Substring(0, $cursorPosition - $commandAst.Extent.StartOffset)
}
#}

# PSReadline {
# Key handlers are set before oh-my-posh, whose Enter wrapper emits OSC 133;C.
Set-PSReadLineOption -BellStyle None
# Predictions from history plus what Tab would complete (CompletionPredictor), shown as a list while typing.
if ([Console]::IsOutputRedirected -eq $false) {
Import-Module CompletionPredictor
Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView
}
Set-PSReadlineKeyhandler -Key ctrl+n -Function TabCompleteNext
Set-PSReadlineKeyhandler -Key ctrl+p -Function TabCompletePrevious
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
# Up/Down only walk the history entries that start with what is typed.
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
#}

# Editor {
# Tools that read VISUAL or EDITOR open Neovim (git uses core.editor). Inside a Neovim :terminal flatten.nvim opens the file
# in the hosting Neovim.
$env:VISUAL = 'nvim'
$env:EDITOR = 'nvim'
#}

# bat {
# `cat` prints with syntax highlighting and never pages, like cat. Piped output stays plain text. delta reads BAT_THEME too.
$env:BAT_THEME = 'gruvbox-dark'
Remove-Alias -Name cat -Force -ErrorAction Ignore
function cat { bat --paging=never @args }
#}

# Encoding {
# Native programs such as git and dotnet write UTF-8, which the console's legacy code page would garble (åäö).
[Console]::InputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
#}

# Progress {
# OSC 9;4 drives the Windows Terminal tab and taskbar progress indicator
$PSStyle.Progress.UseOSCIndicator = $true
#}

## oh-my-posh {
# `--print` skips the temporary init script, see https://ohmyposh.dev/docs/installation/prompt (PowerShell).
& ([ScriptBlock]::Create((oh-my-posh init pwsh --config ~/minimal.omp.json --print) -join "`n"))
#}

# Terminal Icons {
# Importing takes ~0.4 s, so it waits until the prompt is idle
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -SupportEvent -Action { Import-Module -Name Terminal-Icons -Global }
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
