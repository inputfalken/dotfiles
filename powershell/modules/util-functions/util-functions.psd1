@{
  RootModule = 'util-functions.psm1'
  ModuleVersion = '1.0.0'
  GUID = '0676815e-ec47-45de-81ee-ba6a8f81fc4e'
  FunctionsToExport = @(
    'Clear-DotnetProject',
    'Get-GitBranch',
    'Get-GitDiffFile',
    'Get-GitFile',
    'Get-GitIgnoredFile',
    'Get-GitUntrackedFile',
    'Set-GitRootLocation',
    'Start-Nvim',
    'Update-Path'
  )
  CmdletsToExport = @()
  # Short names from before the functions followed PowerShell's Verb-Noun naming.
  AliasesToExport = @('gbranches', 'gdiffFiles', 'gignoredFiles', 'glistFiles', 'gRootDirectory', 'guntrackedFiles')
  VariablesToExport = @()
}
