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

Enum PathType {
  Directory = 0
  File = 1
}

function Secure-Copy ([string] $address, [string] $remotePath, [string] $localPath, [PathType] $pathType) {
  if ($pathType -eq [PathType]::File) {
    scp "$($address):$($remotePath)" $localPath
  } elseif ($pathType -eq [PathType]::Directory) {
    scp -r "$($address):$($remotePath)" $localPath
  } else {
    throw 'Enum not supported.'
  }
  if ($?) {
    Write-Host "Successfully copied '$remotePath' -> '$localPath'" -ForeGroundColor Green
  } else {
    throw "scp exit code: $lastexitcode"
  }
}

function Secure-Transfer ([string] $address, [string] $remotePath, [string] $localPath, [PathType] $pathType) {
  if ($pathType -eq [PathType]::File) {
    scp $localPath "$($address):$($remotePath)"
  } elseif ($pathType -eq [PathType]::Directory) {
    scp -r $localPath "$($address):$($remotePath)"
  } else {
    throw 'Enum not supported.'
  }
  if ($?) {
    Write-Host "Successfully copied '$remotePath' -> '$localPath'" -ForeGroundColor Green
  } else {
    throw "scp exit code: $lastexitcode"
  }
}

function Clear-Solution {
  [cmdletbinding(SupportsShouldProcess=$True)]
  Param()
  $solution = (Get-ChildItem *.sln)
  if ($solution) {
    $expectedType = 'FileInfo'
    $type = $solution.GetType()
    if ($type.Name -eq $expectedType) {
      $counter = 0
      Get-ChildItem -Recurse -Directory | where { $_.Name -eq 'bin' -or $_.Name -eq 'obj' } | % {
        $fullName = $_.FullName
        $counter++
        if ($PSCmdlet.ShouldProcess($fullName, 'Remove-Item')) {
          Write-Host "Removing $fullName"
          Remove-Item $fullName -Force -Recurse
        }
      }
      Write-Host $(if ($counter -eq 0) { "Found no directories." } else { "Found $counter directories."})
    } else {
      $invalidType = "Expected the type '$expectedType' but got '$($type.Name)'."
      throw $invalidType
    }
  } else {
    $noSolutionFilePresent = "Could not find a solution file in directory '$(Resolve-Path .\)'."
    throw $noSolutionFilePresent
  }
}


<#
.SYNOPSIS
Recompiles the vim plugin 'YouCompleteMe' this is useful when updating YouCompleteMe.
In order for this function to work; you need to have 7-Zip and CMake installed.
.EXAMPLE
Compile-YCM "$HOME\.vim\plugged\YouCompleteMe"
#>
function Compile-YCM {
  [CmdletBinding()]
  param(
      [Parameter(Position=0,Mandatory=0)][string]$directory =  "$HOME\.vim\plugged\YouCompleteMe"
  )
  $env:Path+= ";$($env:ProgramFiles)\7-Zip"
  $env:Path+= ";$($env:ProgramFiles)\CMake\bin"
  python "$directory\install.py"
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
