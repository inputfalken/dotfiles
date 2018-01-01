. $PSScriptRoot\util-functions.ps1

$exportModuleMemberParams = @{
  Function = @(
    'Clear-DotnetProject',
    'Compile-YCM',
    'Edit-Profile',
    'Exec',
    'gdiff',
    'gdiffVim',
    'Get-ChocolateyPackages',
    'guntrackedFiles',
    'nvim',
    'Reload-Path',
    'Tail-File',
    'Get-ClipboardText',
    'Set-ClipboardText',
    'glistFiles'
  )
}
Export-ModuleMember @exportModuleMemberParams
