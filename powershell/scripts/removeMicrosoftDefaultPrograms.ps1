[CmdletBinding(SupportsShouldProcess=$True)]
param()
function Remove-WindowsApps {
  $appNames = @('messaging', 'windowsalarms', 'windowscommunicationsapps', 'windowscamera', 'sway', 'phone', 'communicationsapps', 'people', 'zune', 'soundrecorder', 'bing', 'onenote', 'windowsmaps', 'solitaire', 'officehub', 'skypeapp', 'getstarted', '3dbuilder', 'drawboardpdf', 'freshpaint', 'nytcrossword', 'xboxapp', 'SurfaceHub', 'flipboard')
  $appNames | % { Get-AppxPackage -AllUsers "*$_*" } | Remove-AppxPackage
}

Remove-WindowsApps

