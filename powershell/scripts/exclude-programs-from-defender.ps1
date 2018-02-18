param(
  [Parameter(Position = 0,Mandatory = 0)] [switch]$ClearExclusions = $false
)

function Create-ProgramFilesPath {
  param(
    [string]$path
  )
  "$($env:ProgramFiles)\$path"
}

function Create-Program86FilesPath {
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

  $ExclusionPaths = $ExclusionPaths
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

if (!$ClearExclusions) {
  $paths = @(
    "$HOME\source",
    (Create-Program86FilesPath 'Epic Games'),
    (Create-Program86FilesPath 'Google'),
    (Create-Program86FilesPath 'IIS Express'),
    (Create-Program86FilesPath 'IIS'),
    (Create-Program86FilesPath 'Internet Explorer'),
    (Create-Program86FilesPath 'Java'),
    (Create-Program86FilesPath 'JetBrains'),
    (Create-Program86FilesPath 'MSBuild'),
    (Create-Program86FilesPath 'Microsoft SDKs'),
    (Create-Program86FilesPath 'Microsoft Silverlight'),
    (Create-Program86FilesPath 'Microsoft Visual Studio 10.0'),
    (Create-Program86FilesPath 'Microsoft Visual Studio 14.0'),
    (Create-Program86FilesPath 'Microsoft Visual Studio'),
    (Create-Program86FilesPath 'Microsoft.NET'),
    (Create-Program86FilesPath 'NVIDIA Corporation'),
    (Create-Program86FilesPath 'NuGet'),
    (Create-Program86FilesPath 'Overwatch'),
    (Create-Program86FilesPath 'Steam'),
    (Create-Program86FilesPath 'vim'),
    (Create-ProgramFilesPath '7-Zip'),
    (Create-ProgramFilesPath 'Amazon'),
    (Create-ProgramFilesPath 'CMake'),
    (Create-ProgramFilesPath 'ConEmu'),
    (Create-ProgramFilesPath 'Docker Toolbox'),
    (Create-ProgramFilesPath 'Docker'),
    (Create-ProgramFilesPath 'Git'),
    (Create-ProgramFilesPath 'IIS Express'),
    (Create-ProgramFilesPath 'IIS'),
    (Create-ProgramFilesPath 'Java'),
    (Create-ProgramFilesPath 'MSBuild'),
    (Create-ProgramFilesPath 'Microsoft SDKs'),
    (Create-ProgramFilesPath 'Microsoft ASP.NET Core Runtime Package Store'),
    (Create-ProgramFilesPath 'Microsoft Analysis Services'),
    (Create-ProgramFilesPath 'Microsoft MPI'),
    (Create-ProgramFilesPath 'Microsoft SQL Server'),
    (Create-ProgramFilesPath 'Microsoft Silverlight'),
    (Create-ProgramFilesPath 'Microsoft VS Code'),
    (Create-ProgramFilesPath 'Microsoft'),
    (Create-ProgramFilesPath 'Mozilla Firefox'),
    (Create-ProgramFilesPath 'NVIDIA Corporation'),
    (Create-ProgramFilesPath 'Oracle'),
    (Create-ProgramFilesPath 'PowerShell'),
    (Create-ProgramFilesPath 'Realtek'),
    (Create-ProgramFilesPath 'dotnet'),
    (Create-ProgramFilesPath 'intel'),
    (Create-ProgramFilesPath 'internet explorer'),
    (Create-ProgramFilesPath 'nodejs')
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
