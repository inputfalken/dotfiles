Import-Module posh-git
# Source: https://github.com/neilpa/cmd-colors-solarized#update-your-powershell-profile
. (Join-Path -Path (Split-Path -Parent -Path $PROFILE) -ChildPath $(switch($HOST.UI.RawUI.BackgroundColor.ToString()){"White"{"Set-SolarizedLightColorDefaults.ps1"}"Black"{"Set-SolarizedDarkColorDefaults.ps1"}default{return}}))

# Reload the system path variable.
function Reload-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")       
}

function Create-Link ($target, $link) {
  New-Item -Path $link -ItemType SymbolicLink -Value $target
}
