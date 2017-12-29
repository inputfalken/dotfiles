####################################################################################################
#                                                                                                  #
#                                     Install Various Linters                                      #
#                                                                                                  #
####################################################################################################

function Setup-Linters {
  . $PSScriptRoot\utils.ps1

  function Install-Linter {
    param (
      [Parameter(Mandatory=1)][string]$cmd,
      [Parameter(Mandatory=1)][ScriptBlock] $linterMissing,
    )
    $linterExits = {
      Write-Host "Linter '$cmdname' allready exists, skipping installation."
    }
    Command-Exists $cmdname $linterExits $linterMissing
  }

  function Install-JsonLint {
    Install-Linter -CmdName JsonLint -LinterMissing {
      Exec { npm install jsonlint -g }
    }
  }

  # TODO Add Markdown linter installation through gem

  function Install-XmlLint {
    [CmdletBinding()]
    param (
      [Parameter(Position=0,Mandatory=1)][string]$installationDirectory
    )

    Install-Linter -CmdName xmllint -LinterMissing {
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
  }
  Install-XmlLint C:\tools\xml
  Install-JsonLint
}
