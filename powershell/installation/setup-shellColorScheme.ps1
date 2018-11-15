####################################################################################################
#                                                                                                  #
#                                  Install Colorscheme for shell                                   #
#                                                                                                  #
####################################################################################################


function Setup-ColorScheme {
  [CmdletBinding()]
  param()
  function gRootDirectory {
    [CmdletBinding()]
    Param(
      [Parameter(Position = 0, Mandatory = 0)][switch] $Push = $false
    )
    if (Get-Command -CommandType Application -Name 'git'  -ErrorAction SilentlyContinue) {
      if (git rev-parse --is-inside-work-tree 2> $null) {
        $location = git rev-parse --show-toplevel `
          | Resolve-Path `
          | Get-Item
        if ((Get-Location).Path -eq $location) { return } else { 
          if ($Push) { Push-Location $location }
          else { Set-Location $location }
        }
      } else { throw "'$(Get-Location)' is not a git directory/repository." }
    } else { throw "Function 'gRootDirectory' requires 'git' to be globally available." }
  }
  $zipFile = '.\colortool.zip'
  Invoke-WebRequest -Uri 'https://github.com/Microsoft/console/releases/download/1810.02002/ColorTool.zip' -OutFile $zipFile -ErrorAction Stop
  $outPath = '.\colortool'
  Expand-Archive $zipFile -DestinationPath $outPath -ErrorAction Stop
  gRootDirectory -Push
  $ColorschemePaths = Get-ChildItem '.\shell\colorschemes' -ErrorAction Stop | Select-Object -ExpandProperty FullName -ErrorAction Stop
  Pop-Location
  Push-Location $outPath
  $ColorschemePaths | Copy-Item -Destination '.\schemes'
  & .\ColorTool.Exe -b gruvbox
  Pop-Location

  # Clean up
  Remove-Item $zipFile -Force
  Remove-Item $outPath -Recurse -Force
}
