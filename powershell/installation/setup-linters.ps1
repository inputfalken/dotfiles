####################################################################################################
#                                                                                                  #
#                                     Install Various Linters                                      #
#                                                                                                  #
####################################################################################################

function Setup-Linters {
  [CmdletBinding()]
  param()

  function Install-JsonLint {
    [CmdletBinding()]
    param()
    Exec { npm install jsonlint -g }
  }

  function Install-MardownLintTool {
    Exec { gem install mdl }
  }

  function Install-XmlLint {
    [CmdletBinding()]
    param(
      [Parameter(Position = 0,Mandatory = 1)] [string]$installationDirectory
    )
    Push-Location $installationDirectory

    $downloads = @(
      [pscustomobject]@{ Uri = 'http://xmlsoft.org/sources/win32/iconv-1.9.2.win32.zip'; FileName = 'iconv.zip' },
      [pscustomobject]@{ Uri = 'http://xmlsoft.org/sources/win32/libxml2-2.7.8.win32.zip'; FileName = 'lbxml.zip' },
      [pscustomobject]@{ Uri = 'http://xmlsoft.org/sources/win32/libxmlsec-1.2.18.win32.zip'; FileName = 'libxmlsec.zip' },
      [pscustomobject]@{ Uri = 'http://xmlsoft.org/sources/win32/zlib-1.2.5.win32.zip'; FileName = 'zlib.zip' }
    ) |
    ForEach-Object { Invoke-WebRequest -Uri $_.Uri -OutFile $_.FileName; $_ } |
    Select-Object -ExpandProperty FileName | Get-Item |
    ForEach-Object { Start-MpScan -ScanPath $_ -ScanType Custom; $_ } |
    ForEach-Object { Expand-Archive -Path $_.FullName -DestinationPath $_.BaseName; $_ } |
    ForEach-Object { Remove-Item -Path $_.FullName; Get-Item $_.BaseName }

    $downloads |
    ForEach-Object { Get-ChildItem -Filter 'bin' -Recurse } |
    ForEach-Object { Get-ChildItem $_.FullName } |
    Select-Object -ExpandProperty FullName |
    ForEach-Object { Move-Item -Path $_ -Destination . }

    $downloads | Remove-Item -Force -Recurse

    $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
    $location = (Get-Location).path
    $newpath = "$($oldpath)$($location);"
    Set-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’ -Name PATH -Value $newPath

    Pop-Location
  }

  When-Command -cmd xmllint -NotFound {
    Install-XmlLint -InstallationDirectory C:\tools\xml -Verbose
  }

  When-Command -cmd JsonLint -NotFound {
    Install-JsonLint -Verbose
  }

  When-Command -cmd gem -Found {
    When-Command -cmd mdl -NotFound { Install-MardownLintTool }
  } -NotFound {
    Write-Host "Package manager 'Gem' does not exist"
  }
}
