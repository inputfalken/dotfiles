. $PSScriptRoot\util-functions.ps1

$exportModuleMemberParams = @{
  Function = @(
    'Clear-DotnetProject',
    'Compile-YCM',
    'Edit-Profile',
    'Exec',
    'gdiffFiles',
    'gdiffVim',
    'Get-ChocolateyPackages',
    'guntrackedFiles',
    'nvim',
    'Reload-Path',
    'Tail-File',
    'Get-ClipboardText',
    'Set-ClipboardText',
    'glistFiles',
    'gadd',
    'gcheckout',
    'gdiffFilesCheckout'
  )
}
Export-ModuleMember @exportModuleMemberParams
