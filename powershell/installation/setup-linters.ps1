####################################################################################################
#                                                                                                  #
#                                     Install Various Linters                                      #
#                                                                                                  #
####################################################################################################

function Setup-Linters {
  [CmdletBinding()]
  param()

  function Install-VimVint {
    Exec { pip3 install vim-vint }
  }

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

  When-Command -cmd xmllint -NotFound {
    Install-XmlLint -InstallationDirectory (Join-Path -Path $ToolsDirectory -ChildPath 'xml') -Verbose
  }

  When-Command -cmd JsonLint -NotFound {
    Install-JsonLint -Verbose
  }

  When-Command -cmd vint -NotFound {
    exec { pip install vim-vint }
  }

  When-Command -cmd gem -Found {
    When-Command -cmd mdl -NotFound { Install-MardownLintTool }
  } -NotFound {
    Write-Host "Package manager 'Gem' does not exist"
  }
}
