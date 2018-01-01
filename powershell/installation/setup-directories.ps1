function Setup-Directories {
  $path = 'C:\tools'
  if (!(Test-Path $path)) { New-Item -Type Directory -Path $path -Force -ErrorAction Stop }
  Get-Item $path
}
