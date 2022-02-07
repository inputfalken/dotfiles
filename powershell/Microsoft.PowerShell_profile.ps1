$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"
Import-Module util-functions 3> $null

## posh-git {
  # Needed for autcomplete
  Import-Module posh-git
#}

## oh-my-posh {
  $env:POSH_GIT_ENABLED = $true
  Import-Module oh-my-posh
  oh-my-posh --init --shell pwsh --config ~/jandedobbeleer.omp.json | Invoke-Expression
#}

# Terminal Icons {
  Import-Module -Name Terminal-Icons
#}

# PSReadline {
  Set-PSReadlineOption -BellStyle None
  Set-PSReadlineOption -EditMode vi
  Set-PSReadLineOption -PredictionSource History
  Set-PSReadLineOption -PredictionViewStyle ListView
  Set-PSReadLineKeyHandler -Key Tab -Function Complete
  Set-PSReadlineKeyhandler -Key ctrl+n -Function ViTabCompleteNext
  Set-PSReadlineKeyhandler -Key ctrl+p -Function ViTabCompletePrevious
  Set-PSReadlineKeyhandler -Key Shift+Insert -Function Paste
  Remove-PSReadLineKeyHandler -Key ctrl+v
#}

# PowerShell parameter completion shim for the dotnet CLI {
  Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
      [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
  }
#}

## NeoVim {
  Set-Alias vi nvim
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
#}
