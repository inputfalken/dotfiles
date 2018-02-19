param(
  [Parameter(Position = 0,Mandatory = 0)] [switch]$ClearExclusions = $false
)

function Create-ProgramPath {
  param(
    [string]$path
  )
  "$($env:ProgramFiles)\$path"
}

function Create-Program86Path {
  param(
    [string]$path
  )
  "$(${env:ProgramFiles(x86)})\$path"
}


function Add-Exclusions {
  param(
    [string[]]$ExclusionPaths,
    [string[]]$ExclusionExtensions
  )

  $ExclusionPaths = $ExclusionPaths |
  Where-Object { $_ | Test-Path } |
  Resolve-Path -ErrorAction Stop

  $processExclusionSet = New-Object System.Collections.Generic.HashSet[string]
  $pathExclusionSet = New-Object System.Collections.Generic.HashSet[string]
  $extensionExclusionSet = New-Object System.Collections.Generic.HashSet[string]

  Get-MpPreference |
  Select-Object -Property ExclusionProcess,ExclusionPath,ExclusionExtension |
  ForEach-Object {
    if ($_.ExclusionProcess) { $processExclusionSet.UnionWith($_.ExclusionProcess) }
    if ($_.ExclusionPath) { $pathExclusionSet.UnionWith($_.ExclusionPath) }
    if ($_.ExclusionExtension) { $extensionExclusionSet.UnionWith($_.ExclusionExtension) }
  }

  $addedExclusions = [System.Collections.ArrayList]@()

  $ExclusionPaths |
  ForEach-Object {
    if (!$processExclusionSet.Contains("$_\*")) {
      $addedExclusions.Add($_) > $null
      # This will exclude all proccesses from the directory
      # Source: https://www.reddit.com/r/Windows10/comments/5gf38v/when_excluding_a_process_in_windows_defender_do_i/day7lz6/
      Add-MpPreference -ExclusionProcess "$_\*" -ErrorAction Stop
    }

    if (!$pathExclusionSet.Contains($_)) {
      # Excludes all files under the directory.
      Add-MpPreference -ExclusionPath $_ -ErrorAction Stop
    }
  }

  $addedExtensions = [System.Collections.ArrayList]@()

  $ExclusionExtensions |
  ForEach-Object {
    if (!$extensionExclusionSet.Contains($_)) {
      Add-MpPreference -ExclusionExtension $_ -ErrorAction Stop
      $addedExtensions.Add($_) > $null
    }
  }

  if ($addedExclusions.Length -gt 0) {
    $addedExclusions |
    Get-Item |
    Select-Object -Property @{ L = 'Added exclusion paths & processes'; E = { $_.FullName } } |
    Format-Table |
    Out-String |
    Write-Host -ForegroundColor White
  } else {
    Write-Host "`n`n`nNo new exclusions for paths and processed added." -ForegroundColor Yellow
  }

  if ($addedExtensions.Length -gt 0) {
    $addedExtensions |
    Select-Object -Property @{ L = 'Added exclusion extensions'; E = { $_ } } |
    Format-Table |
    Out-String |
    Write-Host -ForegroundColor White
  } else {
    Write-Host "`n`n`nNo new exclusions for extensions added.`n`n`n" -ForegroundColor Yellow
  }
}

$oldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop";
if (!$ClearExclusions) {
  $paths = @(
    "$HOME\source",
    (Create-Program86Path 'Epic Games'),
    (Create-Program86Path 'IIS Express'),
    (Create-Program86Path 'IIS'),
    (Create-Program86Path 'Java'),
    (Create-Program86Path 'JetBrains'),
    (Create-Program86Path 'MSBuild'),
    (Create-Program86Path 'Microsoft SDKs'),
    (Create-Program86Path 'Microsoft Silverlight'),
    (Create-Program86Path 'Microsoft Visual Studio 10.0'),
    (Create-Program86Path 'Microsoft Visual Studio 14.0'),
    (Create-Program86Path 'Microsoft Visual Studio'),
    (Create-Program86Path 'Microsoft.NET'),
    (Create-Program86Path 'NVIDIA Corporation'),
    (Create-Program86Path 'NuGet'),
    (Create-Program86Path 'Overwatch'),
    (Create-Program86Path 'Steam'),
    (Create-Program86Path 'vim'),
    (Create-ProgramPath '7-Zip'),
    (Create-ProgramPath 'Amazon'),
    (Create-ProgramPath 'CMake'),
    (Create-ProgramPath 'ConEmu'),
    (Create-ProgramPath 'Docker Toolbox'),
    (Create-ProgramPath 'Docker'),
    (Create-ProgramPath 'Git'),
    (Create-ProgramPath 'IIS Express'),
    (Create-ProgramPath 'IIS'),
    (Create-ProgramPath 'Java'),
    (Create-ProgramPath 'MSBuild'),
    (Create-ProgramPath 'Microsoft SDKs'),
    (Create-ProgramPath 'Microsoft ASP.NET Core Runtime Package Store'),
    (Create-ProgramPath 'Microsoft Analysis Services'),
    (Create-ProgramPath 'Microsoft MPI'),
    (Create-ProgramPath 'Microsoft SQL Server'),
    (Create-ProgramPath 'Microsoft Silverlight'),
    (Create-ProgramPath 'Microsoft VS Code'),
    (Create-ProgramPath 'Microsoft'),
    (Create-ProgramPath 'Mozilla Firefox'),
    (Create-ProgramPath 'NVIDIA Corporation'),
    (Create-ProgramPath 'Oracle'),
    (Create-ProgramPath 'PowerShell'),
    (Create-ProgramPath 'Realtek'),
    (Create-ProgramPath 'dotnet'),
    (Create-ProgramPath 'intel'),
    (Create-ProgramPath 'nodejs')
  )
  $extensions = @( 'json','xml','cs','js','fs','csproj','txt','fsproj','log','md','html','cshtml','resx','ps1','py')
  Add-Exclusions -ExclusionPaths $paths -ExclusionExtensions $extensions
} else {
  Set-MpPreference -ExclusionPath 'tmp' -ErrorAction Stop
  Set-MpPreference -ExclusionProcess 'tmp' -ErrorAction Stop
  Set-MpPreference -ExclusionExtension 'tmp' -ErrorAction Stop

  Remove-MpPreference -ExclusionPath 'tmp' -ErrorAction Stop
  Remove-MpPreference -ExclusionProcess 'tmp' -ErrorAction Stop
  Remove-MpPreference -ExclusionExtension 'tmp' -ErrorAction Stop
  Write-Host 'Successfully cleared exclusions' -ForegroundColor Green
}
$ErrorActionPreference =  $oldErrorActionPreference
