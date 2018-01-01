[CmdletBinding(SupportsShouldProcess = $True)]
param()
function Remove-WindowsApps {
  $appNames = @(
    '89006A2E.AutodeskSketchBook',
    '89006A2E.AutodeskSketchBook',
    'A278AB0D.MarchofEmpires',
    'CAF9E577.Plex',
    'KeeperSecurityInc.Keeper',
    'king.com.CandyCrushSodaSaga',
    'marchofempires',
    'Microsoft.3DBuilder',
    'Microsoft.Advertising.Xaml',
    'Microsoft.BingWeather',
    'Microsoft.CommsPhone',
    'Microsoft.GetHelp',
    'Microsoft.Getstarted',
    'Microsoft.HEVCVideoExtension',
    'Microsoft.HoloCamera',
    'Microsoft.HoloShell',
    'Microsoft.Messaging',
    'Microsoft.MicrosoftOfficeHub',
    'Microsoft.MicrosoftSolitaire',
    'Microsoft.MicrosoftStickyNotes',
    'Microsoft.MinecraftUWP',
    'Microsoft.MSPaint',
    'Microsoft.Office.OneNote',
    'Microsoft.OneConnect',
    'Microsoft.People',
    'Microsoft.Print3D',
    'Microsoft.SkypeApp',
    'Microsoft.StorePurchaseAPp',
    'Microsoft.Wallet',
    'Microsoft.WindowsAlarms',
    'Microsoft.WindowsCamera',
    'Microsoft.windowscommunicationsapps',
    'Microsoft.windowscommunicationsapps',
    'Microsoft.WindowsFeedbackHub',
    'Microsoft.WindowsMaps',
    'Microsoft.WindowsSoundRecorder',
    'Microsoft.Xbox.TCUI',
    'Microsoft.XboxApp',
    'Microsoft.XboxGameOverlay',
    'Microsoft.XboxIdentityProvider',
    'Microsoft.XboxSpeech',
    'Microsoft.ZuneMusic',
    'Microsoft.ZuneVideo',
    'Microsoft3DViewer',
    'Paid'
  )
  $appNames | ForEach-Object { Get-AppxPackage -AllUsers "$_*" } | Remove-AppxPackage
}

Remove-WindowsApps
