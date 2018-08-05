. $PSScriptRoot\util-functions.ps1

$exportModuleMemberParams = @{
  Function = @(
    'Clear-DotnetProject',
    'Dotnet-AddProjectToSolution',
    'Dotnet-GetSolutionProjects',
    'Compile-YCM',
    'Edit-Profile',
    'Exec',
    'gdiffFiles',
    'gdiffVim',
    'Get-ChocolateyPackages',
    'guntrackedFiles',
    'gbranches',
    'gignoredFiles',
    'nvim',
    'Reload-Path',
    'Tail-File',
    'Get-ClipboardText',
    'Set-ClipboardText',
    'glistFiles',
    'gadd',
    'gcheckout',
    'gdiffFilesCheckout',
    'Exclude-Item',
    'Include-Item'
    'Skip-Object'
  )
}
Export-ModuleMember @exportModuleMemberParams
