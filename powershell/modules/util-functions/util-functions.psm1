####################################################################################################
#                                                                                                  #
#                                     Shared Utility Functions                                     #
#                                                                                                  #
####################################################################################################

# Helpers {
# Case-insensitive wildcard match, case-sensitive as soon as the filter contains an uppercase letter.
function Test-SmartFilter ([string]$Text, [string]$Filter) {
  if ($Filter -cmatch '\p{Lu}') { return $Text -clike "*$Filter*" }
  $Text -like "*$Filter*"
}

function Test-GitRepository {
  if ($null -eq (Get-Command -CommandType Application -Name 'git' -ErrorAction SilentlyContinue)) {
    throw 'Git needs to be available globally.'
  }
  if ((git rev-parse --is-inside-work-tree 2>$null) -ne 'true') {
    throw "'$(Get-Location)' is not a git repository."
  }
}

# The repository root as a Windows path, git itself prints forward slashes.
function Get-GitRoot ([string]$Path = '.') {
  [System.IO.Path]::GetFullPath((git -C $Path rev-parse --show-toplevel))
}

# Full Windows paths of git's root-relative output.
function Join-GitPath ([string]$Root) {
  process { [System.IO.Path]::GetFullPath((Join-Path -Path $Root -ChildPath $_)) }
}

# True for an existing path, or a new file whose folder exists.
function Test-OpenablePath ([string]$Path) {
  if (Test-Path -LiteralPath $Path) { return $true }
  $full = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
  Test-Path -LiteralPath (Split-Path -Parent $full) -PathType Container
}

# True for anything git can resolve to commits, a single revision as well as a range such as main..feature.
function Test-GitRevision ([string]$Revision) {
  $commits = git rev-parse --revs-only --quiet $Revision 2>$null
  $LASTEXITCODE -eq 0 -and $null -ne $commits
}

# `git ls-files` with the listed items as files, deleted files (`-d`) as paths since there is no item to get.
function Get-GitListedFile ([string[]]$Arguments) {
  git -c core.quotepath=false ls-files @Arguments | ForEach-Object {
    if (Test-Path -LiteralPath $_) { Get-Item -LiteralPath $_ } else { $_ }
  }
}
# }

# Environment {

<#
.SYNOPSIS
  Reloads PATH from the machine and user environment, keeping entries added in this session.
#>
function Update-Path {
  [CmdletBinding()]
  param()
  $env:Path = (
    $env:Path, [System.Environment]::GetEnvironmentVariable('Path', 'Machine'), [System.Environment]::GetEnvironmentVariable('Path', 'User') -split ';' `
      | Where-Object { $_ } `
      | Select-Object -Unique -CaseInsensitive
  ) -join ';'
}
# }

# .NET {

# One directory Clear-DotnetProject removed or failed to remove; a class so completion knows its members.
class DotnetCleanResult {
  [string]$Project
  [string]$Target
  [string]$Result
}

<#
.SYNOPSIS
  Deletes bin and obj folders in .NET projects.
.DESCRIPTION
  Projects come from `git ls-files` inside a git repository, otherwise from a recursive search limited by -Depth.
  Asks once before removing, showing every project and folder.
.PARAMETER Path
  The directory to clean below, piped directories are cleaned one by one.
.PARAMETER Force
  Removes without asking, like -Confirm:$false.
.PARAMETER Depth
  How deep the file search looks for projects outside a git repository.
.PARAMETER ProjectExtensions
  Project file extensions to look for.
.PARAMETER RemovalDirectories
  Folder names to remove next to each project.
.EXAMPLE
  Clear-DotnetProject -WhatIf # Lists what would be removed below the current directory.
.EXAMPLE
  Clear-DotnetProject -RemovalDirectories bin, obj, TestResults -Force # Removes these folders without asking.
#>
function Clear-DotnetProject {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
  [OutputType([DotnetCleanResult])]
  param(
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container }, ErrorMessage = "'{0}' is not an existing directory.")]
    [string]$Path = '.\',
    [switch]$Force,
    [ValidateRange('NonNegative')] [int]$Depth = 5,
    [ArgumentCompletions('.csproj', '.fsproj', '.vbproj', '.sqlproj', '.esproj', '.dcproj')]
    [ValidatePattern('^\.\w+$', ErrorMessage = "'{0}' is not a file extension such as .csproj.")]
    [string[]]$ProjectExtensions = @('.csproj', '.fsproj', '.vbproj'),
    [ArgumentCompletions('bin', 'obj', '.vs', 'TestResults')]
    [ValidatePattern('^[^\\/:*?"<>|]+$', ErrorMessage = "'{0}' is not a plain directory name.")]
    [string[]]$RemovalDirectories = @('bin', 'obj')
  )

  # Runs once per piped directory.
  process {
    $Path = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    $projectPaths = if ((git -C $Path rev-parse --is-inside-work-tree 2>$null) -eq 'true') {
      $patterns = $ProjectExtensions | ForEach-Object { "*$_" }
      # Run from -Path, so only projects below it are listed.
      git -C $Path -c core.quotepath=false ls-files --full-name -- @patterns | Join-GitPath (Get-GitRoot $Path)
    } else {
      Get-ChildItem -LiteralPath $Path -Recurse -File -Depth $Depth `
        | Where-Object { $ProjectExtensions -contains $_.Extension } `
        | ForEach-Object { $_.FullName }
    }
    $projectPaths = @($projectPaths | Sort-Object -Unique)
    if ($projectPaths.Count -eq 0) { Write-Error "No files found whose extension matches: $($ProjectExtensions -join ', ')."; return }

    # Several projects can share a folder, so each folder is only collected once.
    $directories = @(
      $projectPaths `
        | ForEach-Object { Split-Path -Parent $_ } `
        | Sort-Object -Unique `
        | ForEach-Object { Get-ChildItem -LiteralPath $_ -Directory } `
        | Where-Object { $RemovalDirectories -contains $_.Name }
    )
    if ($directories.Count -eq 0) { Write-Error "No directories found whose name matches: $($RemovalDirectories -join ', ')."; return }

    $overview = (
      $directories `
        | Group-Object -Property Parent `
        | Select-Object @{ Name = 'Project'; Expression = { $_.Name } }, @{ Name = 'Directories'; Expression = { $_.Group.Name -join ', ' } } `
        | Sort-Object -Property Project `
        | Format-Table -AutoSize `
        | Out-String
    ).TrimEnd()
    # -Force skips the confirmation the same way -Confirm:$false does, -WhatIf still only reports.
    if ($Force) { $ConfirmPreference = 'None' }
    $action = "Remove $($directories.Count) directories in $($projectPaths.Count) projects"
    if ($PSCmdlet.ShouldProcess($overview, $action) -eq $false) { return }

    $directories | ForEach-Object {
      $failure = $null
      try { Remove-Item -LiteralPath $_.FullName -Force -Recurse -Confirm:$false -ErrorAction Stop }
      catch { $failure = $_ }
      [DotnetCleanResult]@{
        Project = $_.Parent.FullName
        Target  = $_.Name
        Result  = if ($failure) { "Failure: $($failure.Exception.Message)" } else { 'Success' }
      }
    }
  }
}
# }

# Neovim {

<#
.SYNOPSIS
  Neovim with piping functionality.
.DESCRIPTION
  Piped files and directories are opened together with the given paths.
  Inside a Neovim terminal flatten.nvim opens them in the Neovim hosting the terminal instead of a nested one,
  unless plugins are off (--noplugin, --clean).
.PARAMETER Path
  Piped files or directories to open.
.PARAMETER InputObject
  Text to open when `-` is given.
.PARAMETER ArgumentList
  Files to open (a new file only needs an existing folder), `-` to open the piped text, and any other Neovim
  argument, e.g. --noplugin.
.EXAMPLE
  Get-ChildItem -Recurse -File *.csproj | Start-Nvim # Opens every csproj below the current directory as buffers.
.EXAMPLE
  Get-ChildItem -Recurse -File *.fsproj | Start-Nvim -p # Opens every fsproj below the current directory in tabs.
.EXAMPLE
  Get-ChildItem -Recurse -File *.xml | Start-Nvim -p --noplugin # Opens every xml file below the current directory in tabs, with plugins disabled.
.EXAMPLE
  Write-Output 'hello' | Start-Nvim - # Opens the output in a new buffer.
.LINK
  https://neovim.io/doc/user/starting.html
#>
function Start-Nvim {
  [CmdletBinding(PositionalBinding = $false)]
  param(
    # Not positional, so typed paths and flags land in -ArgumentList and piped files still bind here.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [ValidateScript({ Test-OpenablePath $_ }, ErrorMessage = "'{0}' does not exist and neither does its folder.")]
    [string[]]$Path,
    [Parameter(ValueFromPipeline)] [object]$InputObject,
    # Neovim's -p, -o, -d, -R and -c, the aliases keep the familiar flags.
    [Alias('p')] [switch]$Tab,
    [Alias('o')] [switch]$Split,
    [Alias('d')] [switch]$Diff,
    [Alias('R')] [switch]$ReadOnly,
    [Alias('c')] [string[]]$Command,
    [Parameter(ValueFromRemainingArguments)] [string[]]$ArgumentList = @()
  )
  begin {
    $paths = [System.Collections.Generic.List[string]]::new()
    $piped = [System.Collections.Generic.List[object]]::new()
  }
  process {
    if ($null -ne $InputObject) { $piped.Add($InputObject) }
    foreach ($item in $Path) { if ($paths.Contains($item) -eq $false) { $paths.Add($item) } }
  }
  end {
    # Typed arguments are files, except flags (-x, --x), commands (+x) and `-` for the piped text.
    $fromStdin = $ArgumentList -contains '-'
    $flags = @($ArgumentList | Where-Object { $_ -match '^[-+].' })
    foreach ($item in $ArgumentList | Where-Object { $_ -notmatch '^[-+]' }) {
      if ((Test-OpenablePath $item) -eq $false) { throw "'$item' does not exist and neither does its folder." }
      $paths.Add($item)
    }
    if ($fromStdin -and $piped.Count -eq 0) { throw 'Stdin requires pipeline input.' }
    $nvimArgs = @(
      if ($Tab) { '-p' }
      if ($Split) { '-o' }
      if ($Diff) { '-d' }
      if ($ReadOnly) { '-R' }
      # +cmd is -c cmd, the form flatten.nvim forwards to the hosting Neovim.
      foreach ($item in $Command) { "+$item" }
    ) + $flags

    if ($fromStdin) {
      $piped | Out-String -Stream | nvim - @nvimArgs
      return
    }
    # Without files flatten.nvim hands over only commands, so +enew gives the hosting Neovim an empty buffer.
    if ($paths.Count -eq 0) { $nvimArgs += '+enew' }
    nvim @paths @nvimArgs
  }
}
# }

# Git {

<#
.SYNOPSIS
  The files `git diff` reports as added, modified or renamed.
.PARAMETER Revision
  Commits to compare: none compares the working tree with the index, one the working tree with that commit,
  two (or a range such as main..feature) those commits.
.PARAMETER Path
  Limits the diff to these files or folders.
.PARAMETER Cached
  Staged changes instead of the working tree.
.PARAMETER Filter
  Keeps paths containing this text, case-insensitive until it has an uppercase letter.
.PARAMETER GitArgument
  Any other `git diff` option, e.g. --ignore-all-space.
.EXAMPLE
  Get-GitDiffFile HEAD~1 -Filter Service # Added or modified files since the previous commit whose path contains 'Service'.
.EXAMPLE
  Get-GitDiffFile main, feature src # Files under src that differ between the two branches.
#>
function Get-GitDiffFile {
  [CmdletBinding()]
  [Alias('gdiffFiles')]
  [OutputType([System.IO.FileInfo])]
  param(
    [Parameter(Position = 0)]
    [ValidateCount(1, 2)]
    [ValidateScript({ $_ -like '-*' -or (Test-GitRevision $_) }, ErrorMessage = "'{0}' is not a commit or range.")]
    [string[]]$Revision,
    [Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [ValidateScript({ $_ -like '-*' -or (Test-Path -LiteralPath $_) }, ErrorMessage = "'{0}' does not exist.")]
    [string[]]$Path,
    [Alias('Staged')] [switch]$Cached,
    [ValidateNotNullOrEmpty()] [string]$Filter = '*',
    [Parameter(ValueFromRemainingArguments)] [string[]]$GitArgument
  )
  begin {
    Test-GitRepository
    $paths = [System.Collections.Generic.List[string]]::new()
    # A git option written first lands in -Revision or -Path, PowerShell fills positional parameters before the remaining arguments.
    $flags = [System.Collections.Generic.List[string]]::new()
    $revisions = @($Revision | Where-Object { $_ -notlike '-*' })
    foreach ($item in $Revision | Where-Object { $_ -like '-*' }) { $flags.Add($item) }
  }
  process {
    # git runs from the root below, so the paths are made absolute against this shell's location.
    foreach ($item in $Path) {
      if ($item -like '-*') { $flags.Add($item) }
      else { $paths.Add($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($item)) }
    }
  }
  end {
    $root = Get-GitRoot
    $options = @(if ($Cached) { '--cached' }) + @($flags) + @($GitArgument)
    git -C $root -c core.quotepath=false diff --name-only --diff-filter=AMR @options @revisions -- @paths `
      | Where-Object { Test-SmartFilter -Text $_ -Filter $Filter } `
      | Join-GitPath $root `
      | Where-Object { Test-Path -LiteralPath $_ } `
      | ForEach-Object { Get-Item -LiteralPath $_ }
  }
}

<#
.SYNOPSIS
  Files that `.gitignore` excludes.
.PARAMETER Filter
  Keeps paths containing this text, case-insensitive until it has an uppercase letter.
#>
function Get-GitIgnoredFile {
  [CmdletBinding()]
  [Alias('gignoredFiles')]
  [OutputType([System.IO.FileInfo])]
  param([ValidateNotNullOrEmpty()] [string] $Filter = '*')
  Test-GitRepository
  git -c core.quotepath=false ls-files -o -i --exclude-standard `
    | Where-Object { Test-SmartFilter -Text $_ -Filter $Filter } `
    | ForEach-Object { Get-Item -LiteralPath $_ }
}

<#
.SYNOPSIS
  Files that are neither tracked nor excluded by `.gitignore`.
.PARAMETER Filter
  Keeps paths containing this text, case-insensitive until it has an uppercase letter.
#>
function Get-GitUntrackedFile {
  [CmdletBinding()]
  [Alias('guntrackedFiles')]
  [OutputType([System.IO.FileInfo])]
  param([ValidateNotNullOrEmpty()] [string] $Filter = '*')
  Test-GitRepository
  $root = Get-GitRoot
  git -C $root -c core.quotepath=false ls-files -o --exclude-standard `
    | Where-Object { Test-SmartFilter -Text $_ -Filter $Filter } `
    | Join-GitPath $root `
    | ForEach-Object { Get-Item -LiteralPath $_ }
}

<#
.SYNOPSIS
  Local git branches.
#>
function Get-GitBranch {
  [CmdletBinding()]
  [Alias('gbranches')]
  [OutputType([string])]
  param()
  Test-GitRepository
  git for-each-ref refs/heads --format '%(refname:short)'
}

<#
.SYNOPSIS
  Changes (or with -Push pushes) the location to the repository root.
.PARAMETER Push
  Pushes the location, so Pop-Location returns.
#>
function Set-GitRootLocation {
  [CmdletBinding()]
  [Alias('gRootDirectory')]
  param([switch] $Push)
  Test-GitRepository
  $root = Get-GitRoot
  # Push-Location here would use the module's own location stack, which the caller's Pop-Location never sees.
  if ($Push) { $PSCmdlet.SessionState.Path.PushCurrentLocation('') }
  Set-Location -LiteralPath $root
}

<#
.SYNOPSIS
  Files tracked by git.
.DESCRIPTION
  This function wraps the functionality of `git ls-files` by adding default behaviour and piping support.
  Paths that exist are passed as they are, other names match any path containing them unless -Strict is given
  (case-insensitive until the name has an uppercase letter).
.PARAMETER Path
  Files, folders or names. Each piped element is its own `git ls-files` call, and a piped string can carry its own
  options, e.g. '.\src\ -m'.
.PARAMETER Strict
  Names match as given, as git pathspecs, instead of any path containing them.
.PARAMETER Modified
  Modified files (-m).
.PARAMETER Deleted
  Deleted files (-d), returned as paths.
.PARAMETER Others
  Untracked files (-o).
.PARAMETER Ignored
  Files .gitignore excludes (-i).
.PARAMETER GitArgument
  Any other `git ls-files` option, added to every call.
.EXAMPLE
  Get-GitFile # Every tracked file below the current directory.
.EXAMPLE
  Get-GitFile ./src/ # Every tracked file below ./src/.
.EXAMPLE
  './src/', './test/' | Get-GitFile # Every tracked file below the piped directories.
.EXAMPLE
  './src/', './test/' | Get-GitFile -Modified # Modified files below each piped directory.
.EXAMPLE
  '.\src\ -m', '.\test\' | Get-GitFile # Modified files in ./src/ and every file in ./test/.
.LINK
  https://git-scm.com/docs/git-ls-files
#>
function Get-GitFile {
  [CmdletBinding()]
  [Alias('glistFiles')]
  # Deleted files (`-d`) come back as path strings.
  [OutputType([System.IO.FileInfo], [string])]
  param(
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [string[]]$Path,
    [switch]$Strict,
    # git ls-files' -m, -d, -o and -i, the aliases keep the familiar flags.
    [Alias('m')] [switch]$Modified,
    [Alias('d')] [switch]$Deleted,
    [Alias('o')] [switch]$Others,
    [Alias('i')] [switch]$Ignored,
    [Parameter(ValueFromRemainingArguments)] [string[]]$GitArgument
  )
  begin {
    Test-GitRepository
    $shared = @(
      if ($Modified) { '-m' }
      if ($Deleted) { '-d' }
      if ($Others) { '-o' }
      if ($Ignored) { '-i'; '--exclude-standard' }
    ) + @($GitArgument)
    $called = $false
  }
  process {
    if ($null -eq $Path) { return }
    $called = $true
    $gitArgs = @(
      foreach ($item in $Path | ForEach-Object { -split $_ }) {
        if ($item -like '-*' -or $Strict -or (Test-Path -LiteralPath $item)) { $item }
        elseif ($item -cmatch '\p{Lu}') { "*$item*" }
        else { ":(icase)*$item*" }
      }
    ) + $shared
    Get-GitListedFile $gitArgs
  }
  end {
    if ($called -eq $false) { Get-GitListedFile $shared }
  }
}

Register-ArgumentCompleter -CommandName Get-GitDiffFile -ParameterName Revision -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete)
  git for-each-ref --format='%(refname:short)' refs/heads refs/remotes refs/tags 2>$null `
    | Where-Object { $_ -like "$wordToComplete*" } `
    | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
}

# Candidates use the same path base as each function: the current directory for ignored files, the root for untracked ones.
Register-ArgumentCompleter -CommandName Get-GitIgnoredFile, Get-GitUntrackedFile -ParameterName Filter -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete)
  if ((git rev-parse --is-inside-work-tree 2>$null) -ne 'true') { return }
  $word = $wordToComplete.Trim("'", '"')
  $paths = if ($commandName -eq 'Get-GitIgnoredFile') {
    # `--directory` keeps large ignored folders such as bin/ to one candidate.
    git -c core.quotepath=false ls-files -o -i --exclude-standard --directory 2>$null
  } else {
    git -C (git rev-parse --show-toplevel) -c core.quotepath=false ls-files -o --exclude-standard 2>$null
  }
  $paths `
    | Where-Object { Test-SmartFilter -Text $_ -Filter $word } `
    | Select-Object -First 100 `
    | ForEach-Object { [System.Management.Automation.CompletionResult]::new(($_ -match '[\s''"`$;,(){}@&|<>#]' ? "'$($_ -replace "'", "''")'" : $_), $_, 'ParameterValue', $_) }
}
# }
