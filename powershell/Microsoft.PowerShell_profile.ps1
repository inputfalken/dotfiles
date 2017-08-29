Import-Module posh-git
Set-PSReadlineOption -EditMode vi
# Reload the system path variable.
function Reload-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Create-Link ($target, $link) {
  New-Item -Path $link -ItemType SymbolicLink -Value $target
}

Set-Alias vi vim

<#
.SYNOPSIS
This is a helper function that runs a scriptblock and checks the PS variable $lastexitcode
to see if an error occcured. If an error is detected then an exception is thrown.
This function allows you to run command-line programs without having to
explicitly check the $lastexitcode variable.

.EXAMPLE
exec { svn info $repository_trunk } "Error executing SVN. Please verify SVN command-line client is installed"
#>

function Exec {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][scriptblock]$cmd,
        [Parameter(Position=1,Mandatory=0)][string]$errorMessage = ($msgs.error_bad_command -f $cmd),
        [Parameter(Position=2,Mandatory=0)][int]$maxRetries = 0,
        [Parameter(Position=3,Mandatory=0)][string]$retryTriggerErrorPattern = $null
    )

    $tryCount = 1

    do {
        try {
            $global:lastexitcode = 0
            & $cmd
            if ($lastexitcode -ne 0) {
                throw ("Exec: " + $errorMessage)
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

            Write-Host "Try $tryCount failed, retrying again in 1 second..."

            $tryCount++

            [System.Threading.Thread]::Sleep([System.TimeSpan]::FromSeconds(1))
        }
    }
    while ($true)
}

function Invoke-Speech {
  param([Parameter(ValueFromPipeline=$true)][string] $say)
    $voice = New-Object -ComObject SAPI.SPVoice
    $voice.Rate = -3
    process {
      $voice.Speak($say) | out-null
    }
}
new-alias -name out-voice -value Invoke-Speech

function Clear-Solution {
  $solution = (Get-ChildItem *.sln)
  if ($solution) {
    $expectedType = 'FileInfo'
    $type = $solution.GetType()
    if ($type.Name -eq $expectedType) {
      $counter = 0
      Get-ChildItem -Recurse -Directory | where { $_.Name -eq 'bin' -or $_.Name -eq 'obj' } | % {
        $fullName = $_.FullName
        Write-Host "Removing directory $fullName"
        Remove-Item $fullName -Force -Recurse
        $counter++
      }
      Write-Host $(if ($counter -eq 0) { "Found no directories" } else { "Removed $counter directories"})
    } else {
      $invalidType = "Expected the type '$expectedType' but got '$($type.Name)'."
      throw $invalidType
    }
  } else {
    $noSolutionFilePresent = "Could not find a solution file in directory '$(Resolve-Path .\)'."
    throw $noSolutionFilePresent
  }
}
