####################################################################################################
#                                                                                                  #
#                                     Shared Utility Functions                                     #
#                                                                                                  #
####################################################################################################

# Check if the command exists.
function When-Command {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = 1)] [string]$cmd,
    [Parameter(Mandatory = 0)] [scriptblock]$found = { Write-Host "Command '$cmd' allready exists." },
    [Parameter(Mandatory = 0)] [scriptblock]$notFound = { Write-Host "Command '$cmd' was not found." }
  )

  $result = [bool](Get-Command -Name $cmd -ErrorAction SilentlyContinue)
  if ($result) {
    $found.Invoke()
  } else {
    $notFound.Invoke()
  }
}

# This makes paths who contain spaces work with git.
function Wrap-WithQuotes {
  $input `
    | Foreach-Object { "'$_'" } `
    | Write-Output
}

function Any-Match {
  param( $FilterScript = $null )
  process { if ($FilterScript| Invoke-Expression) { $true; break } }
  end { $false }
}

function Take-While () {
  param([scriptblock]$pred = $(throw "Need a predicate"))
  begin {
    $take = $true
  }
  process {
    if ($take) {
      $take = & $pred $_
      if ($take) {
        $_
      }
    } else { break }
  }
}

# TODO When an uppercased letter is found, do case sensitive filtering from the position of the uppercased letter.
# This could be achived by generating an regex pattern.
function Smart-Filter {
  param(
    [Parameter(Position = 0, Mandatory = 1)] [string]$Text,
    [Parameter(Position = 1, Mandatory = 1)] [string]$Filter
  )

  if ($Filter.ToCharArray() | Any-Match {[char]::IsUpper($_)}) {
    $text -clike "*$filter*"
  } else {
    $text -like "*$filter*"
  }
}

function Build-GitPullRequest {
    param(
        [Parameter(Position = 0, Mandatory = $true)] [ValidateNotNull()] [string] $Target,
        [Parameter(Position = 1, Mandatory = $true)] [ValidateNotNull()][string] $Title,
        [Parameter(Position = 2, Mandatory = $false)] [string] $Source,
        [Parameter(Position = 3, Mandatory = $false)] [string] $Description,
        [Parameter(Position = 4, Mandatory = $false)] [bool] $Force = $false,
        [Parameter(Position = 5, Mandatory = $false)] [bool] $DryRun = $false
    )

    function Confirm-Option ([ScriptBlock]$Block) {
        while ($true) {
            $Block.Invoke()
            switch ((Read-Host).ToLower()) {
                'y' { return $true }
                'yes' { return $true }
                'n' { return $false }
                'no' { return $false }
            }
        }
    }

    function Get-CommitCount {
        param (
            [Parameter(Position = 0, Mandatory = $true)] [ValidateNotNull()] [string] $Source,
            [Parameter(Position = 1, Mandatory = $true)] [ValidateNotNull()][string] $Target
        )

        git rev-list --left-only --count $Target...$Source 2>&1 `
          | Tee-Object -Variable output `
          | Out-Null
        $behind = $output
        if ($LASTEXITCODE -ne 0) { throw "Could not obtain git commit state:`n$output" }

        git rev-list --right-only --count $Target...$Source 2>&1 `
          | Tee-Object -Variable output `
          | Out-Null
        $ahead = $output
        if ($LASTEXITCODE -ne 0) { throw "Could not obtain git commit state:`n$output" }

        @{
            Behind = $behind
            Ahead  = $ahead
        }
    }

    git rev-parse --verify remotes/origin/$Target 2>&1 `
      | Tee-Object -Variable output `
      | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Could not check if branch '$Target' exists on remote:`n$output" }

    $sourceBranch = if ([string]::IsNullOrWhiteSpace($Source)) {
        git rev-parse --abbrev-ref HEAD 2>&1 `
          | Tee-Object -Variable output `
          | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Could not get current branch:`n$output" }
        $output
    } else { $Source }

    $sourceIsTarget = $sourceBranch -eq $Target
    if ($sourceIsTarget) {
        Write-Host 'Your are in the same branch as the target' -NoNewline -ForegroundColor White
        Write-Host ", you have to create a new branch in order to continue.`r`n" -NoNewline -ForegroundColor White

        Write-Host "Branch name: " -NoNewline -ForegroundColor Magenta
        # TODO check for existing branches
        $sourceBranch = (Read-Host).Trim()

        # If it's still the same branch, throw an exception.
        if ($sourceBranch -eq $Target) { throw "Source branch '$sourceBranch' cannot be the same as target branch '$Target';." }
    }

    git rev-parse --verify $sourceBranch 2>&1 `
      | Tee-Object -Variable output `
      | Out-Null

    $doesNotExistLocally = $LASTEXITCODE -eq 128
    # Currently not needed, consider removing...
    $existLocally = $LASTEXITCODE -eq 0
    if (!$existLocally -and !$doesNotExistLocally) { throw "Could not check if branch '$sourceBranch' exists on remote:`n$output"  }

    git rev-parse --verify remotes/origin/$sourceBranch 2>&1 `
      | Tee-Object -Variable output `
      | Out-Null

    $doesNotExistRemotely = $LASTEXITCODE -eq 128
    $existsRemotely = $LASTEXITCODE -eq 0
    if (!$existsRemotely -and !$doesNotExistRemotely) { throw "Could not check if branch '$sourceBranch' exists on remote:`n$output"  }

    if ($doesNotExistRemotely) {
        $pushConfirmationBlock = {
            Write-Host 'Git branch' -NoNewline -ForegroundColor White
            Write-Host " $sourceBranch " -NoNewline -ForegroundColor Yellow
            Write-Host 'does not exist, would you like to push' -NoNewline -ForegroundColor White
            Write-Host " $sourceBranch " -NoNewline -ForegroundColor Yellow
            Write-Host "to remote?" -NoNewline -ForegroundColor White
            Write-Host ' [y/n] ' -NoNewline -ForegroundColor Magenta
        }

        if ($sourceIsTarget -or (Confirm-Option $pushConfirmationBlock)) {
            if ($sourceIsTarget -or $doesNotExistLocally) {
                if ($DryRun) { Write-Host "Would execute '& git branch $sourceBranch'." }
                else {
                    & git branch $sourceBranch 2>&1 `
                      | Tee-Object -Variable output `
                      | Out-Null
                    if ($LASTEXITCODE -ne 0) { throw "Could not create branch:`n$output"}
                }
            }

            if ($DryRun) { Write-Host "Would execute '& git push origin $sourceBranch --set-upstream'." }
            else {
                Write-Host "Pushing '$sourceBranch'." -ForegroundColor Yellow
                & git push origin $sourceBranch --set-upstream 2>&1 `
                  | Tee-Object -Variable output `
                  | Out-Null
                if ($LASTEXITCODE -ne 0) { throw "Could not push branch '$sourceBranch':`n$output" }
                else {
                  Write-Host "Successfully pushed" -NoNewline -ForegroundColor Green
                  Write-Host " $sourceBranch " -NoNewline -ForegroundColor Yellow
                  Write-Host "to remote." -ForegroundColor Green
                }
            }
        } else { throw 'Could not create branch.' }
    }
    elseif ($existsRemotely) {
      Write-Host "Source branch" -NoNewline -ForegroundColor Green
      Write-Host " $sourceBranch " -NoNewline -ForegroundColor Yellow
      Write-Host "already exists on remote." -ForegroundColor Green
    }

    $pullRequestDescription = if ([string]::IsNullOrWhiteSpace($Description)) {
        git log -1 --pretty=%B 2>&1 `
          | Tee-Object -Variable output `
          | Where-Object { [string]::IsNullOrWhiteSpace($_) -eq $false }
        if ($LASTEXITCODE -ne 0) { throw "Could note resolve commit message:`n$output" }
    } else { $Description }

    @{
        PullRequest = @{
            Source      = $SourceBranch
            Target      = $Target
            Title       = $Title
            Description = $pullRequestDescription
        }
        Actions       = @{
            CreatedBranch = $sourceIsTarget
        }
    }
}

<#
.SYNOPSIS
  Helper function for executing command-line programs.
.DESCRIPTION
  This is a helper function that runs a scriptblock and checks the PS variable $lastexitcode to see if an error occcured.
  If an error is detected then an exception is thrown.
  This function allows you to run command-line programs without having to explicitly check the $lastexitcode variable.
.PARAMETER cmd
  The scriptblock to execute. This scriptblock will typically contain the command-line invocation.
.PARAMETER errorMessage
  The error message to display if the external command returned a non-zero exit code.
.PARAMETER maxRetries
  The maximum number of times to retry the command before failing.
.PARAMETER retryTriggerErrorPattern
  If the external command raises an exception, match the exception against this regex to determine if the command can be retried.
  If a match is found, the command will be retried provided [maxRetries] has not been reached.
.PARAMETER workingDirectory
  The working directory to set before running the external command.
.EXAMPLE
  exec { svn info $repository_trunk } "Error executing SVN. Please verify SVN command-line client is installed"
.LINK
  https://raw.githubusercontent.com/psake/psake/master/src/public/Exec.ps1
#>
function Exec {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)] [scriptblock]$cmd,
    [string]$errorMessage = ($msgs.error_bad_command -f $cmd),
    [int]$maxRetries = 0,
    [string]$retryTriggerErrorPattern = $null,
    [string]$workingDirectory = $null
  )

  if ($workingDirectory) {
    Push-Location -Path $workingDirectory
  }

  $tryCount = 1

  do {
    try {
      $global:lastexitcode = 0
      & $cmd
      if ($lastexitcode -ne 0) {
        throw "Exec: $errorMessage"
      }
      break
    } catch [exception] {
      if ($tryCount -gt $maxRetries) {
        throw $_
      }

      if ($retryTriggerErrorPattern -ne $null) {
        $isMatch = [regex]::IsMatch($_.Exception.Message, $retryTriggerErrorPattern)

        if ($isMatch -eq $false) {
          throw $_
        }
      }

      "Try $tryCount failed, retrying again in 1 second..."

      $tryCount++

      [System.Threading.Thread]::Sleep([System.TimeSpan]::FromSeconds(1))
    } finally {
      if ($workingDirectory) {
        Pop-Location
      }
    }
  }
  while ($true)
}

<#
.SYNOPSIS
  Reloads the System Envrionmental variable PATH
#>
function Reload-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

<#
.SYNOPSIS
  Lists choco packages name and version.
  Returns an array of PSCustomObject with properties:
  * Package
  * Version
#>
function Get-ChocolateyPackages {
  Write-Host 'Getting installed packages' -ForegroundColor Yellow
  # Gets the packages names
  $packages = choco list --local-only
  if ($packages) {
    # Get rid of redundant info,
    $Packages `
      | Take-While { $args[0] -notmatch '\d\spackages\sinstalled\.' } `
      | ForEach-Object `
      -Process {
      $split = $_.split(' ')
      [pscustomobject]@{ Package = $split[0]; Version = $split[1] }
    } `
      | Sort-Object Package
  } else {
    # Return empty array if $packages is null
    @()
  }
}

function Find-SolutionFile {
  param(
    [Parameter(Position = 1, Mandatory = 1)] [string]$Path,
    [Parameter(Position = 1, Mandatory = 1)] [scriptblock]$OnSuccess
  )

  function Is-SolutionFile {
    param([Parameter(Position = 1, Mandatory = 1)] [System.IO.FileSystemInfo]$File )
    $File.Extension -eq '.sln'
  }

  $SolutionPath = Get-Item $Path -ErrorAction Stop

  if (Test-Path $SolutionPath -Type Leaf) {
    if (Is-SolutionFile $SolutionPath) { Invoke-Command -ScriptBlock $OnSuccess -ArgumentList $SolutionPath }
    else { throw "File '$SolutionPath' is not not a solution file." }
  } else {
    $SolutionFiles = $SolutionPath `
      | Get-ChildItem `
      | Where-Object { Is-SolutionFile $_ }
    if (($SolutionFiles.Count -eq 1) -and ($SolutionPath.FullName -eq (Get-Location).Path)) { Invoke-Command -ScriptBlock $OnSuccess -ArgumentList $SolutionFiles[0] }
    elseif ($SolutionFiles.Count -gt 1) { throw "You need to specify one of the following: $($SolutionFiles -join ', ')." }
    else { throw "No solution file found with path '$SolutionPath'." }
  }
}

function Dotnet-GetSolutionProjects {
  [OutputType('System.IO.FileSystemInfo')]
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = 0)] [string]$SolutionPath = '.\'
  )
  Find-SolutionFile -Path $SolutionPath -OnSuccess {
    param(
      $SolutionFile
    )
    dotnet sln $SolutionFile list `
      | Where-Object { Test-Path $_ -Type Leaf } `
      | Get-Item `
      | Write-Output
    Write-Host "`r`n`r`nListed projects found in '$($SolutionFile.FullName)'."
  }
}

<#
.SYNOPSIS
  Deletes bin and obj folders in .NET projects.
#>
function Clear-DotnetProject {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = 0)] [string]$Path = '.\',
    [Parameter(Position = 1, Mandatory = 0)] [switch]$Force = $false,
    [Parameter(Position = 2, Mandatory = 0)] [int]$Depth = 5,
    [Parameter(Position = 3, Mandatory = 0)] [switch]$UsePersistedPaths = $false,
    [Parameter(Position = 4, Mandatory = 0)] [switch]$PersistPaths = $false,
    [Parameter(Position = 5, Mandatory = 0)] [string[]]$ProjectExtensions = @( '.csproj', '.fsproj', 'vbproj'),
    [Parameter(Position = 6, Mandatory = 0)] [string[]]$RemovalDirectories = @( 'bin', 'obj')
  )

  function Get-Projects ([string[]]$Extensions, [string]$PersistPath, [bool]$UsePersistedPaths, [int]$Depth, [string]$Path) {
    # If persisted paths is true load json file.
    # Otherwise, check if the directory is a git repo and use git's api for obtaining files.
    if ($UsePersistedPaths) {
      if (Test-Path -LiteralPath $PersistPath) { Get-Content -Raw -LiteralPath $PersistPath | ConvertFrom-Json | Where-Object { Test-Path $_ } }
      else { throw 'You need to persist paths once, before you can use this argument.' }
    } elseif ((git rev-parse --is-inside-work-tree) 2>$null) {
      $Extensions `
        | ForEach-Object `
        -Begin { $wildCardPrefixedExtensions = @() } `
        -Process { $wildCardPrefixedExtensions += "*$_" } `
        -End { "git ls-files $($wildCardPrefixedExtensions -join ' ')" } `
        | Invoke-Expression
    } else {
      foreach ($projectFile in Get-ChildItem -Recurse -File -Path $Path -Depth $Depth) {
        if ($Extensions -notcontains $projectFile.Extension) { continue }
        else { $projectFile }
      }
    }
  }

  $Path = (Resolve-Path $Path -ErrorAction Stop)
  $persistPath = (Join-Path -Path $env:TEMP -ChildPath "$($Path -replace '\w:\\' -replace '\\', '-')").ToLower()

  $projects = Get-Projects `
    -Extensions $ProjectExtensions `
    -PersistPath $persistPath `
    -UsePersistedPaths $UsePersistedPaths `
    -Depth $Depth `
    -Path $Path `
    | Get-Item `
    | ForEach-Object `
    -Begin { $absolutePaths = @(); $directories = @() } `
    -Process {
    $absolutePaths += $_.FullName
    $directories += $_ `
      | Select-Object -ExpandProperty Directory `
      | Get-ChildItem `
      | Where-Object { $RemovalDirectories -contains $_.BaseName }
  } `
    -End { @{ Paths = $AbsolutePaths; Directories = $directories } }
  if ($projects.Paths.Count -eq 0) { throw "No files found whose extension macthes: $($ProjectExtensions -join ', ')." }
  if ($projects.Directories.Count -eq 0) { throw "No paths found whose name matches: $($RemovalDirectories -join ', ')." }

  if ($PersistPaths) {
    $projects.Paths `
      | ConvertTo-Json -Compress `
      | Out-File -LiteralPath $persistPath -ErrorAction Stop
  }

  function Confirm-Option ([scriptblock]$Block) {
    while ($true) {
      $Block.Invoke()
      switch ((Read-Host).ToLower()) {
        'y' { return $true }
        'yes' { return $true }
        'n' { return $false }
        'no' { return $false }
      }
    }
  }

  $deleteConfirmationBlock = {
    # If the search is recursive, we don't where the directories are.
    $projects.Directories `
      | Group-Object -Property Parent `
      | Select-Object -Property `
    @{ Name = 'Project'; Expression = { $_.Name } }, `
    @{ Name = 'Directories'; Expression = { $_.Group -join ', ' } } `
      | Sort-Object -Property Project `
      | Format-Table -AutoSize `
      | Out-String `
      | Write-Host -NoNewline

    Write-Host 'Found' -NoNewline -ForegroundColor White
    Write-Host " $($projects.Directories.Count) " -NoNewline -ForegroundColor Yellow
    Write-Host 'items ' -NoNewline -ForegroundColor White
    Write-Host 'in' -NoNewline -ForegroundColor White
    Write-Host " $($Projects.Paths.Count) " -NoNewline -ForegroundColor Yellow
    Write-Host 'projects. Would you like to remove them?' -NoNewline -ForegroundColor White
    Write-Host ' [y/n] ' -NoNewline -ForegroundColor Magenta
  }
  if ($Force -or (Confirm-Option $deleteConfirmationBlock)) {
    $result = $projects.Directories `
      | ForEach-Object `
      -Begin { $list = @() } `
      -Process {
      try { $item = $_; Remove-Item -LiteralPath $_.FullName -Force -Recurse -ErrorAction Stop; $list += @{ Item = $item; Error = $null }
      } catch { $list += @{ Item = $item; Error = $_ }
      }
    } `
      -End { $list }
    if ($result.Count -gt 0) {
      $result `
        | Select-Object -Property `
      @{ Name = 'Project'; Expression = { $_.Item.Parent } }, `
      @{ Name = 'Target'; Expression = { $_.Item } }, `
      @{ Name = 'Status'; Expression = { if ($_.Error) { "Failure: $($_.Error.Exception.GetType())" } else { 'Success' } } } `
        | Group-Object -Property Status `
        | Select-Object -Property `
      @{ Name = 'Count'; Expression = { $_.Group.Count } }, `
      @{ Name = 'Status'; Expression = { $_.Name } }, `
      @{ Name = 'Group'; Expression = { $_.Group | Select-Object -ExcludeProperty Status } } `
        | ForEach-Object { $parent = $_ ;  $_.group  | Select-Object -Property *,  @{ Name = 'Result' ; Expression = { $parent.Status } } } `
        | Write-Output
    }
  }
}

<#
.SYNOPSIS
  Neovim with piping functionality.
.DESCRIPTION
  Both $input (piped) and $args (arguments supplied after function name) will be reduced to a string seperated with spaces.
  For this function to work, nvim.exe needs to be inside 'C:\tools\neovim\Neovim\bin\'.
.PARAMETER args
  Any argument that neovim can handle. See examples for more info.
.INPUTS
  You can pipe any argument that neovim can handle. paths (directories & files)
  is mainly where this functionality shines.
.EXAMPLE
  Get-ChildItem -Recurse -File *.csproj | Start-Nvim # Recursivly search for all csproj and open them in neovim as seperate buffers.
.EXAMPLE
  Get-ChildItem -Recurse -File *.fsproj | Start-Nvim -p # Recursivly search for all fsproj files and open them in neovim as tabs.
.EXAMPLE
  Get-ChildItem -Recurse -File *.xml | Start-Nvim -p --noplugin # Recursivly search for all xml files and open them in neovim as tabs with plugins disabled.
.EXAMPLE
  Write-Output 'hello' | Start-Nvim - # Opens vim with a buffer containing the output.
.LINK
  https://neovim.io/doc/user/starting.html
#>
function Start-Nvim {
  $terminalSession = [bool]$env:NVIM_LISTEN_ADDRESS
  # If a terminal is used within neovim, send the files to the neovim hosting the terminal rather than creating a nested neovim process.
  $neovim = if ($terminalSession) { 'C:\Python36\Scripts\nvr.exe' } else { 'C:\tools\neovim\Neovim\bin\nvim.exe' }
  $expression = if ($args[0] -eq '-') {
    $path = Join-Path -Path $env:TEMP 'piped-nvim-argument.txt'
    $input `
      | ForEach-Object `
      -Begin { $any = $false ; $pipedStdinArgs = @() } `
      -Process { $any = $true ; $pipedStdinArgs += $_ } `
      -End { if ($any) { $pipedStdinArgs } else { throw 'Stdin requires pipeline input.' } } `
      | Out-File -FilePath $path -Force

    # The dash arguments needs to be sliced...
    $nvimArgs = $args[1..$args.Count] `
      | Wrap-WithQuotes
    -End {
      if ($nvimArgs.Count -gt 0) {
        $joinedArguments = $nvimArgs -join ' '
        if ($terminalSession) { "$neovim '-c new | read! type $path' $joinedArguments" }
        else { "$neovim '-c read! type $path' $joinedArguments" }
      } else {
        if ($terminalSession) { "$neovim '-c new | read! type $path'" }
        else { "$neovim '-c read! type $path'" }
      }
    }
  } else {
    $arguments = $input + $args
    if ($arguments.Count -eq 0) { $neovim + "$(if ($terminalSession) { ' -c enew' } else { [string]::Empty })" }
    else { "$neovim $(($arguments | Wrap-WithQuotes) -join ' ')" }
  }
  $expression | Invoke-Expression
}

function Test-GitRepository {
  if (Get-Command -CommandType Application -Name 'git' -ErrorAction SilentlyContinue) {
    if (git rev-parse --is-inside-work-tree 2>$null) { return } { throw "'$(Get-Location)' is not a git repository." }
  } else { throw 'Git needs to be available globally.' }
}

<#
.SYNOPSIS
  Accepts `git diff` arguments but returns file paths.
#>
function gdiffFiles {
  [OutputType('System.IO.FileSystemInfo')]
  param([string] $Filter = '*')
  Test-GitRepository
  $joinedArguments = (($input + $args) | Wrap-WithQuotes) -join ' '
  (Invoke-Expression "git diff $joinedArguments --name-only --diff-filter=AM") `
    | ForEach-Object `
    -Begin { $emptySequence = $true ; $rootDirectory = git rev-parse --show-toplevel } `
    -Process {
    if ($emptySequence) { $emptySequence = $false }
    Join-Path -Path $rootDirectory -ChildPath $_ `
      | Where-Object { Test-Path $_ } `
      | Where-Object { Smart-Filter -Filter $Filter -Text $_ } `
      | Get-Item
  } `
    -End { if ($emptySequence) { 'No files found.' } } `
    | Write-Output
}

function gignoredFiles {
  [OutputType('System.IO.FileSystemInfo')]
  param([string] $Filter = '*')
  Test-GitRepository
    git ls-files -o -i --exclude-standard `
      | Where-Object { Smart-Filter -Filter $Filter -Text $_ } `
      | Get-Item
}

<#
.SYNOPSIS
  List files which are neither ignored by `.gitignore` or tracked.
#>
function guntrackedFiles {
  [OutputType('System.IO.FileSystemInfo')]
  param([string] $Filter = '*')
  Test-GitRepository
  git rev-parse --show-toplevel `
    | Get-Item `
    | Push-Location

  git ls-files -o --exclude-standard `
    | Foreach-Object `
    -Begin { $emptySequence = $true } `
    -Process {
    if ($emptySequence) { $emptySequence = $false }
    $_ `
      | Where-Object { Smart-Filter -Filter $Filter -Text $_ } `
      | Get-Item `

  } `
    -End { if ($emptySequence) { 'No files found.' } } `
    | Write-Output

  Pop-Location
}

<#
.SYNOPSIS
  Lists local git branches
#>
function gbranches {
  [OutputType('System.String')]
  param()
  Test-GitRepository
  git for-each-ref refs/heads --format "%(refname:short)"
}

<#
.SYNOPSIS
  Excludes an item from the pipeline.
#>
function Exclude-Object {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNull()] $InputObject,
    [Parameter(Position = 0, Mandatory)][ValidateNotNull()] [object[]] $items
  )
  if ($Input) { $InputObject = $Input }
  if ($items.Length -lt 0) { throw 'You must suply an argument.' }
  $InputObject `
    | Where-Object { $items -notcontains $_ } `
    | Write-Output
}

<#
.SYNOPSIS
  Includes an item from the pipeline.
#>
function Include-Object {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNull()] $InputObject,
    [Parameter(Position = 0, Mandatory)][ValidateNotNull()] [object[]] $items
  )
  if ($Input) { $InputObject = $Input }
  if ($items.Length -lt 0) { throw 'You must suply an argument.' }
  $InputObject `
    | Where-Object { $items -contains $_ } `
    | Write-Output
}

<#
.SYNOPSIS
  Skips a number of items from the pipeline.
#>
function Skip-Object {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNull()] $InputObject,
    [Parameter(Position = 0, Mandatory)][int] $Amount,
    [Parameter(Position = 1)][switch] $Last = $false
  )
  if ($Input) { $InputObject = $Input }
  if ($Last) {
    $InputObject `
      | Select-Object -SkipLast $Amount
  } else {
    $InputObject `
      | Select-Object -Skip $Amount
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

function gadd {
  param([string] $Filter = '*')
  Test-GitRepository
  $arguments = $input + $args `
    | Where-Object { Smart-Filter -Filter $Filter -Text $_ } `
    | Wrap-WithQuotes
  if ($arguments.Count -gt 0) { "git add $($arguments -join ' ')" | Invoke-Expression }
  else { Write-Output 'No arguments supplied.' }
}

function gcheckout {
  param(
      [Parameter(ValueFromPipeline, Mandatory = 0)][ValidateNotNull()] $InputObject,
      [Parameter(Position = 0, Mandatory = 0)][ValidateNotNull()][string[]] $ArgumentObject = @()
  )
  Test-GitRepository
  if ($Input) { $InputObject = $Input }
  $arguments = $InputObject + $ArgumentObject | Wrap-WithQuotes
  if ($arguments.Count -gt 0) { "git checkout $($arguments -join ' ')" | Invoke-Expression }
  else { Write-Output 'No arguments supplied.' }
}

function gdiffFilesCheckout {
  Test-GitRepository
  $revisionFiles = git ls-tree $args -r | ForEach-Object { ($_ -split '\t') | Select-Object -Last 1 }
  $currentFiles = git ls-files *

  $commonFiles = Compare-Object -ReferenceObject $revisionFiles -IncludeEqual $currentFiles `
    | Where-Object { $_.SideIndicator -eq '==' } `
    | Select-Object -ExpandProperty InputObject `
    | Get-Item

  Compare-Object -ReferenceObject (gdiffFiles $args) -IncludeEqual $commonFiles `
    | Where-Object { $_.SideIndicator -eq '==' } `
    | Select-Object -ExpandProperty InputObject `
    | Get-Item `
    | gcheckout $args
}

<#
.SYNOPSIS
  List files tracked by version control system git.
.DESCRIPTION
  This function wraps the functionality of `git ls-files` by adding default behaviour and piping support.
.PARAMETER args
  Any argument that `git ls-files` would handle.
  NOTE when you pipe elements through this function. these arguments will be appended to all piped elements.
.INPUTS
  Each pipe element will call `git ls-files` if you want unique arguments for one pipe element, make sure to add within the same string
.EXAMPLE
  glisFiles # List all files that's in directories below the current directory.
.EXAMPLE
  glistFiles ./src/ # List all files that's below the `./src/` directory.
.EXAMPLE
  @('./src/', './test/') | glistFiles # List all files that's below the piped directories.
.EXAMPLE
  @('./src/', './test/') | glistFiles * -m # List all files that have been modified below each piped directory.
.EXAMPLE
  @('.\src\ -m', '.\test\') | glistFiles # Lists all modified files in `./src/` and every file in `./test/`.
.LINK
  https://git-scm.com/docs/git-ls-files
#>
function glistFiles {
  [OutputType('System.IO.FileSystemInfo')]
  param(
      [Parameter(ValueFromPipeline, Mandatory = 0)][ValidateNotNull()] $InputObject,
      [Parameter(Position = 0, Mandatory = 0)][ValidateNotNull()][string[]] $Arguments = @(),
      [Parameter(Position = 1, Mandatory = 0)][ValidateNotNull()][switch] $Strict = $false
  )
  Test-GitRepository
  if ($Input) { $InputObject = $Input }
    $concatenatedArguments = ($Arguments += $InputObject) | Where-Object { [string]::IsNullOrWhiteSpace($_) -eq $false }
    $joinedArgs = if ($Arguments.Count -gt 0) { if ($Strict) { $concatenatedArguments | Wrap-WithQuotes } else { $concatenatedArguments | ForEach-Object { "*$_*" } | Wrap-WithQuotes } } else { [string]::Empty }

    $expression = if ([string]::IsNullOrWhiteSpace($joinedArgs)) { "git ls-files *" } else { "git ls-files " + $joinedArgs }
    $expression  `
      | Invoke-Expression `
      | Get-Item
}

<#
.SYNOPSIS
  Accepts `git diff` arguments, but creates a vimdiff session with the help of the plugin fugitive.
#>
function gdiffVim {
  param([string] $Filter = '*')
  Test-GitRepository
  function Confirm-Option ([scriptblock]$Block) {
    while ($true) {
      $Block.Invoke()
      switch ((Read-Host).ToLower()) {
        'y' { return $true }
        'yes' { return $true }
        'n' { return $false }
        'no' { return $false }
      }
    }
  }

  Test-GitRepository
  $diffingFiles = $args | gdiffFiles -Filter $Filter
  $confirmationBlock = {
    Write-Host 'Found' -NoNewline -ForegroundColor White
    Write-Host " $($diffingFiles.Count) " -NoNewline -ForegroundColor Yellow
    Write-Host 'files ' -NoNewline -ForegroundColor White
    Write-Host 'to diff against. Would you like open all of them as tabs?' -NoNewline -ForegroundColor White
    Write-Host ' [y/n] ' -NoNewline -ForegroundColor Magenta
  }
  if ($diffingFiles.Count -gt 0) {
    # If there's more than 10 files, ask for confirmation.
    if ($diffingFiles.Count -le 10 -or (Confirm-Option $confirmationBlock)) {
      $gitArguments = if ($args.Count -gt 0 ) { " $($args -join ' ')" } else { [string]::Empty }
      $diffingFiles `
        | ForEach-Object `
        -Begin { $useTab = $false ; $vimArgs = @() } `
        -Process {
        # The initial file needs to be opened by the `edit` command while the rest needs to be in tabs.
        $vimArgs += "$(if ($useTab) { 'tabnew' } else { $useTab = $true; 'edit' }) $_"
        $vimArgs += 'Gdiff' + $gitArguments
      } `
        -End { "-c $($vimArgs -Join ' | ')" } `
        | Start-Nvim "-c set shada='NONE'"
      # The shada argument is importnant since the files that are being opened differs.
      # And could cause the shada file to be corrupted.
    }
  } else { Write-Output 'No files found.' }
}

function Edit-Profile {
  @( $PROFILE, '-c lcd %:h') | Start-Nvim
}

function Get-ClipboardText {

  [CmdletBinding()] # to support -OutVariable and -Verbose
  param()

  if ($PSVersionTable.PSEdition -eq 'Desktop') {
    # *Windows* PowerShell
    if ($PSVersionTable.PSVersion -ge [version] '5.1.0') {
      # Ps*Win* v5.1+ now has Get-Clipboard / Set-Clipboard cmdlets.
      Get-Clipboard -Format Text
    } else {
      Add-Type -AssemblyName System.Windows.Forms
      if ([threading.thread]::CurrentThread.ApartmentState.ToString() -eq 'STA') {
        # -- STA mode:
        Write-Verbose "STA mode: Using [Windows.Forms.Clipboard] directly."
        # To be safe, we explicitly specify that Unicode (UTF-16) be used - older platforms may default to ANSI.
        [System.Windows.Forms.Clipboard]::GetText([System.Windows.Forms.TextDataFormat]::UnicodeText)
      } else {
        # -- MTA mode: Since the clipboard must be accessed in STA mode, we use a [System.Windows.Forms.TextBox] instance to mediate.
        Write-Verbose "MTA mode: Using a [System.Windows.Forms.TextBox] instance for clipboard access."
        $tb = New-Object System.Windows.Forms.TextBox
        $tb.Multiline = $tru
        $tb.Paste()
        $tb.Text
      }
    }
  } else {
    # PowerShell Core
    if ($env:OS -eq 'Windows_NT') {
      # Gratefully adapted from http://stackoverflow.com/a/15747067/45375
      # Note that trying the following directly from PowerShell Core does NOT work,
      #   (New-Object -ComObject htmlfile).parentWindow.clipboardData.getData('text')
      # because .parentWindow is always $null
      $tempFile = [io.path]::GetTempFileName()
      "WSH.Echo(WSH.CreateObject('htmlfile').parentWindow.clipboardData.getData('text'));" | set-content $tempFile
      cscript /nologo /e:JScript $tempFile
      Remove-Item $tempFile
    } elseif ((uname) -eq 'Darwin') {
      pbpaste
    } else {
      # Note: May work on Ubuntu only, and there only if xclip was
      # installed with: sudo apt install xclip
      xclip -sel clipboard -o
    }
  }
}

function Set-ClipboardText() {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [ValidateNotNull()]
    $InputObject
  )

  # Each input object is converted to a string representation with Out-String,
  # unless it already is a string; the representations of multiple input objects
  # are separated - but not terminated - with a platform-native newline.
  $allText = $sep = ''
  # $Input having a value means that pipeline input was provided.
  #     Note: Since we want to access all pipeline input *at once*,
  #           we do NOT use a process {} block.
  if ($Input) { $InputObject = $Input }
  foreach ($o in $InputObject) {
    $text = if ($o -is [string]) { $o } else { $o | Out-String }
    $allText += $sep + $text
    if (-not $sep) { $sep = [Environment]::NewLine }
  }

  if ($PSVersionTable.PSEdition -eq 'Desktop') {
    # *Windows* PowerShell

    if ($PSVersionTable.PSVersion -ge [version] '5.1.0') {
      # Ps*Win* v5.1+ now has Get-Clipboard / Set-Clipboard cmdlets.
      Set-Clipboard -Value $allText
    } else {
      Add-Type -AssemblyName System.Windows.Forms
      if ([threading.thread]::CurrentThread.ApartmentState.ToString() -eq 'STA') {
        # -- STA mode: we can use [Windows.Forms.Clipboard] directly.
        Write-Verbose "STA mode: Using [Windows.Forms.Clipboard] directly."
        if ($allText.Length -eq 0) { $AllText = "`0" } # Strangely, SetText() breaks with an empty string, claiming $null was passed -> use a null char.
        # To be safe, we explicitly specify that Unicode (UTF-16) be used - older platforms may default to ANSI.
        [System.Windows.Forms.Clipboard]::SetText($allText, [System.Windows.Forms.TextDataFormat]::UnicodeText)

      } else {
        # -- MTA mode: Since the clipboard must be accessed in STA mode, we use a [System.Windows.Forms.TextBox] instance to mediate.
        Write-Verbose "MTA mode: Using a [System.Windows.Forms.TextBox] instance for clipboard access."
        if ($allText.Length -eq 0) {
          # !! This approach cannot set the clipboard to an empty string: the text box must
          # !! must be *non-empty* in order to copy something. A null character doesn't work.
          # !! We use the least obtrusive alternative - a newline - and issue a warning.
          $allText = "`r`n"
          Write-Warning "Setting clipboard to empty string not supported in MTA mode; using newline instead."
        }
        $tb = New-Object System.Windows.Forms.TextBox
        $tb.Multiline = $true
        $tb.Text = $allText
        $tb.SelectAll()
        $tb.Copy()
      }
    }
  } else {
    # PowerShell *Core*

    # No native PS support for writing to the clipboard ->
    # external utilities must be used.

    # To prevent adding a trailing \n, which PS inevitably adds when sending
    # a string through the pipeline to an external command, use a temp. file,
    # whose content can be provided via native input redirection (<)
    $tmpFile = [io.path]::GetTempFileName()

    # Determine the encoding: Unix platforms need UTF8, whereas
    # Windows's clip.exe needs UTF-16LE - both in *BOM-less* form.
    if ($env:OS -eq 'Windows_NT') {
      # clip.exe on Windows only works as expected with non-ASCII characters
      # with UTF-16LE encoding.
      # Unfortunately, it invariably treats the BOM as *data* too, so
      # we cannot use 'Set-Content -Enocding Unicode' and must use a
      # BOM-less encoding via the .NET Framework.
      [io.file]::WriteAllText($tmpFile, $allText, [System.Text.UnicodeEncoding]::new($false, $false))
    } else {
      # PowerShell's UTF8 encoding invariably creates a file WITH BOM
      # so we use the .NET Framework, whose default is BOM-*less* UTF8.
      [IO.File]::WriteAllText($tmpFile, $allText)
    }

    if ($env:OS -eq 'Windows_NT') {
      Write-Verbose "Windows: using clip.exe"
      cmd /c clip.exe '<' $tmpFile
    } elseif ((uname) -eq 'Darwin') {
      Write-Verbose "macOS: Using pbcopy."
      bash -c "pbcopy < '$tmpFile'"
    } else {
      Write-Verbose "Linux: trying xclip -sel clip"
      bash -c "xclip -sel clip < '$tmpFile'"
    }
    Remove-Item $tmpFile
  }
}
