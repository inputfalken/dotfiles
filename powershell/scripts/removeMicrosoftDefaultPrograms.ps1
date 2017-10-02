function Remove-WindowsApps {
  [CmdletBinding(SupportsShouldProcess=$True)]
  param([string[]] $whiteList)
   @('messaging', 'windowsalarms', 'windowscommunicationsapps', 'windowscamera', 'sway', 'commsphone', 'windowsphone', 'phone', 'communicationsapps', 'people', 'zunemusic', 'zunevideo', 'zune', 'bingfinance', 'bingnews', 'bingsports', 'soundrecorder', 'bingweather', 'bing', 'onenote', 'windowsmaps', 'solitairecollection', 'solitaire', 'officehub', 'skypeapp', 'getstarted', '3dbuilder', 'drawboardpdf', 'freshpaint', 'nytcrossword', 'xboxapp', 'SurfaceHub', 'flipboard')  | % {
    $app = Get-AppxPackage -AllUsers "*$_*"
    if ($app) {
      if ($app -is [array]) {
        $app | % {
          Remove-AppxPackage $_
        }
      } else  {
        Remove-AppxPackage $app
      }
    }
  }
}

Remove-WindowsApps -WhatIf

function Restore-WindowsApps {
  [CmdletBinding(SupportsShouldProcess=$True)]
  param()
    Get-AppxPackage -AllUsers | % {
        Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
    }
}


Restore-WindowsApps -WhatIf
