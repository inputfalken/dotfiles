####################################################################################################
#                                                                                                  #
#                                     Shared Utility Functions                                     #
#                                                                                                  #
####################################################################################################

  # Check if the command exists.
function When-Command {
  param (
    [Parameter(Mandatory=1)][string]$cmd,
    [Parameter(Mandatory=0)][ScriptBlock] $found = { Write-Host "Command '$cmd' allready exists." },
    [Parameter(Mandatory=0)][ScriptBlock] $notFound = { Write-Host "Command '$cmd' was not found." }
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
        [Parameter(Mandatory = $true)][scriptblock]$cmd,
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
        catch [Exception] {
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
  function Take-While() {
    param ( [scriptblock]$pred = $(throw "Need a predicate") )
      begin {
        $take = $true
      }
    process {
      if ( $take ) {
        $take = & $pred $_
          if ( $take ) {
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
    $packages = $packages | Take-While { $args[0] -NotMatch '\d\spackages\sinstalled\.' }
    $packages | % {
      $split = $_.Split(' ')
      [PSCustomObject] @{ Package=$split[0] ; Version=$split[1] }
    } | Sort-Object Package
  } else {
    # Return empty array if $packages is null
    @()
  }
}

function Tail-File {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string]$path
    )
    Get-Content $path -Wait
}
