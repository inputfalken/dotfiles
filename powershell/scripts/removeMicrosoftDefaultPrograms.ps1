[CmdletBinding(SupportsShouldProcess=$True)]
param()
function Remove-WindowsApps {
  $appNames = @('Microsoft.Messaging', 'Microsoft.WindowsAlarms', 'Microsoft.windowscommunicationsapps', 'Microsoft.WindowsCamera', 'Microsoft.CommsPhone', 'Microsoft.windowscommunicationsapps', 'Microsoft.People', 'Microsoft.ZuneMusic', 'Microsoft.ZuneVideo', 'Microsoft.Office.OneNote', 'Microsoft.WindowsMaps', 'Microsoft.MicrosoftSolitaire', 'Microsoft.MicrosoftOfficeHub', 'Microsoft.SkypeApp', 'Microsoft.Getstarted', 'Microsoft.3DBuilder', 'Microsoft.XboxApp', 'Microsoft.XboxSpeech', 'Microsoft.XboxIdentityProvider', 'Microsoft.XboxGameOverlay', 'marchofempires', 'Microsoft.MinecraftUWP', 'sketchbook', 'Microsoft.Microsoft3DViewer', 'Microsoft.MicrosoftStickyNotes', 'Microsoft.BingWeather', 'Microsoft.Wallet', 'Microsoft.HoloShell', 'Microsoft.HoloCamera', 'Microsoft.WindowsFeedbackHub', 'Microsoft.WindowsSoundRecorder', 'Microsoft.MSPaint', 'KeeperSecurityInc.Keeper', 'Paid', 'Microsoft.OneConnect', 'king.com.CandyCrushSodaSaga', 'A278AB0D.MarchofEmpires', 'CAF9E577.Plex')
  $appNames | % { Get-AppxPackage -AllUsers "$_*" } | Remove-AppxPackage
}

Remove-WindowsApps

