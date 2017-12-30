####################################################################################################
#                                                                                                  #
#                                     Install Various Linters                                      #
#                                                                                                  #
####################################################################################################

function Setup-Linters {
  . $PSScriptRoot\utils.ps1

  function Install-Linter {
    [CmdletBinding()]
    param (
      [Parameter(Mandatory=1)][string]$cmd,
      [Parameter(Mandatory=1)][ScriptBlock] $linterMissing
    )
    $linterExits = {
      Write-Host "Linter '$cmd' allready exists, skipping installation."
    }
    Command-Exists $cmd $linterExits $linterMissing
  }

  function Install-JsonLint {
    [CmdletBinding()]
    param ()
      Exec { npm install jsonlint -g }
  }

  function Install-MardownLintTool {
    Exec { gem install mdl } 
  }

  function Install-XmlLint {
    [CmdletBinding()]
    param (
      [Parameter(Position=0,Mandatory=1)][string]$installationDirectory
    )
    Push-Location $installationDirectory

    $downloads = @(
      [PSCustomObject]@{ Uri='http://xmlsoft.org/sources/win32/iconv-1.9.2.win32.zip' ; FileName='iconv.zip' },
      [PSCustomObject]@{ Uri='http://xmlsoft.org/sources/win32/libxml2-2.7.8.win32.zip' ; FileName='lbxml.zip' },
      [PSCustomObject]@{ Uri='http://xmlsoft.org/sources/win32/libxmlsec-1.2.18.win32.zip' ; FileName='libxmlsec.zip' },
      [PSCustomObject]@{ Uri='http://xmlsoft.org/sources/win32/zlib-1.2.5.win32.zip' ; FileName='zlib.zip' }
    ) |
      ForEach-Object { Invoke-WebRequest -Uri $_.Uri -OutFile $_.FileName ; $_ } |
      Select-Object -ExpandProperty FileName | Get-Item |
      ForEach-Object { Start-MpScan -ScanPath $_ -ScanType Custom -Verbose ; $_  } |
      ForEach-Object { Expand-Archive -Path $_.FullName -DestinationPath $_.BaseName ; $_  } |
      ForEach-Object { Remove-Item -Path $_.FullName ; Get-Item $_.BaseName }

    $downloads |
      ForEach-Object { Get-ChildItem -Filter 'bin' -Recurse } |
      ForEach-Object { Get-ChildItem $_.FullName } |
      Select-Object -ExpandProperty FullName |
      ForEach-Object { Move-Item -Path $_ -Destination . -Verbose }

    $downloads | Remove-Item -Force -Recurse -Verbose

    $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
    $location = (Get-Location).Path
    $newpath = "$($oldpath)$($location);"
    Set-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’ -Name PATH -Value $newPath

    Pop-Location
  }

  Install-Linter -Cmd xmllint -LinterMissing {
    Install-XmlLint C:\tools\xml
  }

  Install-Linter -Cmd JsonLint -LinterMissing {
    Install-JsonLint
  }

  Command-Exists -Cmd gem -WhenExisting {
    Install-Linter -Cmd mdl -LinterMissing { Install-MardownLintTool }
  } -WhenMissing {
    Write-Host "Package manager 'Gem' does not exist"
  }
}
