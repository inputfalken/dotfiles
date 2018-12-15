. $PSScriptRoot\util-functions.ps1

$exportModuleMemberParams = @{
  Function = @(
    'Clear-DotnetProject',
    'Dotnet-AddProjectToSolution',
    'Dotnet-GetSolutionProjects',
    'Edit-Profile',
    'Exec',
    'gdiffFiles',
    'gdiffVim',
    'Get-ChocolateyPackages',
    'guntrackedFiles',
    'gbranches',
    'Build-GitPullRequest',
    'gignoredFiles',
    'Start-Nvim',
    'Reload-Path',
    'Tail-File',
    'Get-ClipboardText',
    'Set-ClipboardText',
    'glistFiles',
    'gadd',
    'gcheckout',
    'gdiffFilesCheckout',
    'Exclude-Object',
    'Include-Object',
    'Skip-Object'
  )
}
Export-ModuleMember @exportModuleMemberParams
