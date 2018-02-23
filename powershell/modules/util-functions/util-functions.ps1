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

# Taken from https://raw.githubusercontent.com/psake/psake/master/src/public/Exec.ps1
function Exec {
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
    #>
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
    }
    catch [exception]{
      if ($tryCount -gt $maxRetries) {
        throw $_
      }

      if ($retryTriggerErrorPattern -ne $null) {
        $isMatch = [regex]::IsMatch($_.Exception.Message,$retryTriggerErrorPattern)

        if ($isMatch -eq $false) {
          throw $_
        }
      }

      "Try $tryCount failed, retrying again in 1 second..."

      $tryCount++

      [System.Threading.Thread]::Sleep([System.TimeSpan]::FromSeconds(1))
    }
    finally {
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
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

<#
.SYNOPSIS
  Lists choco packages name and version.
  Returns an array of PSCustomObject with properties:
  * Package
  * Version
#>
function Get-ChocolateyPackages {
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
      }
    }
  }
  Write-Host 'Getting installed packages' -ForegroundColor Yellow
  # Gets the packages names
  $packages = choco list --local-only
  # if packages is not null.
  if ($packages) {
    # Get rid of redundant info,
    $packages = $packages | Take-While { $args[0] -notmatch '\d\spackages\sinstalled\.' }
    $packages | ForEach-Object {
      $split = $_.Split(' ')
      [pscustomobject]@{ Package = $split[0]; Version = $split[1] }
    } | Sort-Object Package
  } else {
    # Return empty array if $packages is null
    @()
  }
}

function Tail-File {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0,Mandatory = 1)] [string]$path
  )
  Get-Content $path -Wait
}

<#
.SYNOPSIS
  Deletes 'bin' and 'obj' directories by recursively searching for them
  from the '-Path' argument whose default value is the current directory.
#>
function Clear-DotnetProject {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0,Mandatory = 0)] [string]$Path = '.\',
    [Parameter(Position = 1,Mandatory = 0)] [switch]$Force = $false,
    [Parameter(Position = 2,Mandatory = 0)] [int]$Depth = 5,
    [Parameter(Position = 3,Mandatory = 0)] [switch]$UsePersistedPaths = $false,
    [Parameter(Position = 4,Mandatory = 0)] [switch]$PersistPaths = $false
  )

  $resolvedPath = (Resolve-Path $Path -ErrorAction Stop)

  # For the moment the '.sln' file ending cannot be here since the result is `bin` and `obj` maps that exist in folders with the following extensions.
  $acceptedFileExtensions = @( '.csproj','.fsproj')
  $persistFilePath = ("$($env:TEMP)\$($resolvedPath -replace '\w:\\' -replace '\\', '-').json").ToLower()

  function Create-CommaSeperatedString ([string[]]$Strings) {
    [func[string, string, string]]$delegate = { param($resultSoFar,$next); "$resultSoFar" + ", $next" }
    [Linq.Enumerable]::Aggregate([string[]]$Strings,$delegate)
  }

  $includes = @( 'bin','obj')
  $excludes = @( '*node_modules*','*jspm_packages*','*packages*')

  function Test-All {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory = $true)] $Condition,
      [Parameter(Mandatory = $true,ValueFromPipeline = $true)] $InputObject
    )

    begin { $result = $true }
    process {
      if (-not (& $Condition $InputObject)) { $result = $false }
    }
    end { $result }
  }

  $projectPaths = if ($UsePersistedPaths) {
    if (Test-Path -LiteralPath $persistFilePath) {
      (Get-Content -Raw -LiteralPath $persistFilePath | ConvertFrom-Json).FullName |
      Where-Object { Test-Path -LiteralPath $_ } |
      Get-Item
    } else {
      Write-Host 'You need to call this cmdlet with -PersistPaths before you can use this flag.' -ForegroundColor Red
      return
    }
  } else {
    foreach ($projectFilePath in Get-ChildItem -Recurse -File -Path $resolvedPath -Depth $Depth) {
      if ($acceptedFileExtensions -notcontains $projectFilePath.Extension) {
        continue
      }
      $projectFilePath
    }
  }

  $directories = $projectPaths |
  Get-Item |
  Select-Object -ExpandProperty Directory |
  Get-ChildItem -Directory |
  Where-Object { $includes -contains $_.BaseName }

  if ($directories.length -gt 0) {

    if ($PersistPaths) {
      $projectPaths |
      Select-Object -Property FullName |
      ConvertTo-Json -Compress |
      Out-File -LiteralPath $persistFilePath -ErrorAction Stop
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
      $summary = $directories |
      Group-Object -Property Parent |
      Format-Table -Autosize -Property @{ L = 'Count'; E = { $_.Count } },@{ L = 'Project'; E = { $_.Name } },@{ L = 'Items'; E = { $_.Group } }

      $summary | Out-String | Write-Host -ForegroundColor White

      Write-Host 'Found' -NoNewline -ForegroundColor White
      Write-Host " $($directories.Length) " -NoNewline -ForegroundColor Yellow
      Write-Host 'items ' -NoNewline -ForegroundColor White
      Write-Host 'in' -NoNewline -ForegroundColor White
      Write-Host " $($summary.Length) " -NoNewline -ForegroundColor Yellow
      Write-Host 'projects. Would you like to remove them?' -NoNewline -ForegroundColor White
      Write-Host ' [y/n]' -NoNewline -ForegroundColor Magenta
    }
    if ($Force -or (Confirm-Option $deleteConfirmationBlock)) {
      $count = 0
      $directories | ForEach-Object {
        try {
          Remove-Item -LiteralPath $_.FullName -Force -Recurse -ErrorAction Stop
          $count++
        }
        catch {
          Write-Host $_ -ForegroundColor Red
        }
      }
      if ($count -gt 0) {
        $statusColor = if ($count -eq $directories.length) { 'Green' } elseif ($count -lt ($directories.length / 2)) { 'Red' } else { 'Yellow' }
        Write-Host -NoNewline 'Removed' -ForegroundColor White
        Write-Host -NoNewline " [$count/$($directories.Length)] " -ForegroundColor $statusColor
        Write-Host -NoNewline "directories." -ForegroundColor White
      }
    }
  } else {
    Write-Host "No directory found matching any name of: ($(Create-CommaSeperatedString $includes))." -ForegroundColor White
  }
}
