####################################################################################################
#                                                                                                  #
#                                     Install Various Linters                                      #
#                                                                                                  #
####################################################################################################

function Setup-Linters {
  [CmdletBinding()]
  param()

  function Install-XmlLint {
    [CmdletBinding()]
    param(
      [Parameter(Position = 0, Mandatory = 1)] [string]$installationDirectory
    )
    Push-Location $installationDirectory

    $downloads = @(
      [pscustomobject]@{ Uri = 'http://xmlsoft.org/sources/win32/iconv-1.9.2.win32.zip'; FileName = 'iconv.zip' },
      [pscustomobject]@{ Uri = 'http://xmlsoft.org/sources/win32/libxml2-2.7.8.win32.zip'; FileName = 'lbxml.zip' },
      [pscustomobject]@{ Uri = 'http://xmlsoft.org/sources/win32/libxmlsec-1.2.18.win32.zip'; FileName = 'libxmlsec.zip' },
      [pscustomobject]@{ Uri = 'http://xmlsoft.org/sources/win32/zlib-1.2.5.win32.zip'; FileName = 'zlib.zip' }
    ) `
      | ForEach-Object { Invoke-WebRequest -Uri $_.Uri -OutFile $_.FileName; $_ } `
      | Select-Object -ExpandProperty FileName | Get-Item `
      | ForEach-Object { 
      if (Get-Command -Name 'Start-MpScan' -ErrorAction SilentlyContinue) {
        Start-MpScan -ScanPath $_ -ScanType Custom
      }
      $_
    } `
      | ForEach-Object { Expand-Archive -Path $_.FullName -DestinationPath $_.BaseName; $_ } `
      | ForEach-Object { Remove-Item -Path $_.FullName; Get-Item $_.BaseName }

    $downloads `
      | ForEach-Object { Get-ChildItem -Filter 'bin' -Recurse } `
      | ForEach-Object { Get-ChildItem $_.FullName } `
      | Select-Object -ExpandProperty FullName `
      | ForEach-Object { Move-Item -Path $_ -Destination . }

    $downloads | Remove-Item -Force -Recurse

    $location = (Get-Location).Path
    if (($env:Path.split(';') | Where-Object { $_ -eq $location}).Count -eq 0) {
      [Environment]::SetEnvironmentVariable("Path", $env:Path + $location, [System.EnvironmentVariableTarget]::Machine)
    }

    Pop-Location
  }

  if (Get-Command -name 'xmllint' -Type 'Application' -ErrorAction SilentlyContinue) { Install-XmlLint -InstallationDirectory (Join-Path -Path $ToolsDirectory -ChildPath 'xml') -Verbose }
  if (Get-Command -name 'JsonLint' -Type 'Application' -ErrorAction SilentlyContinue) { Exec { npm install jsonlint -g } }
  if (Get-Command -name 'vint' -Type 'Application' -ErrorAction SilentlyContinue) { Exec { pip install vim-vint } }
  if (Get-Command -name 'gem' -Type 'Application' -ErrorAction SilentlyContinue) {
    if (Get-Command -name 'mdl' -Type 'Application' -ErrorAction SilentlyContinue) { Exec { gem install mdl } } else { Write-Host "Package manager 'Gem' does not exist" } 
  }
}
