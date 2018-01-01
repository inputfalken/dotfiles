function Update-PythonPackages ($PackageManager) {
  if (Get-Command -Name $PackageManager -CommandType Application -ErrorAction SilentlyContinue) {
    Exec {
      $path = Join-Path -Path (Get-Location) -ChildPath "$PackageManager-requirements.txt"
      "$PackageManager freeze" `
        | Invoke-Expression `
        | Out-File -FilePath $path

      "$PackageManager install -r $path --upgrade" `
        | Invoke-Expression

      Remove-Item $path
    }
  }
}

function Update-RubyGems {
  if (Get-Command -Name 'gem' -CommandType Application -ErrorAction SilentlyContinue) {
    if (Get-Command -Name 'update_rubygems' -CommandType Application -ErrorAction SilentlyContinue) {
      Exec { update_rubygems }
      Exec { gem update --system }
    }
  }
}

function Update-NodePackages {
  if (Get-Command -Name 'npm' -CommandType Application -ErrorAction SilentlyContinue) {
    Exec { npm update -g }
  }
}

function Update-ChocolateyPackages {
  if (Get-Command -Name 'choco' -CommandType Application -ErrorAction SilentlyContinue) {
    Exec { cup all -y }
  }
}

function Update-VimPackages {
  if (Get-Command -Name 'nvim' -ErrorAction SilentlyContinue) {
    Exec { nvim '+ PlugUpdate | qa!' }
  }
}


Update-PythonPackages -PackageManager 'pip2'
Update-PythonPackages -PackageManager 'pip3'
Update-NodePackages
Update-ChocolateyPackages
Update-RubyGems
Update-VimPackages
