# Prompts user for y/n input.
function Confirm-Option ([string]$message) {
  while (1) {
    Write-Host $message -NoNewline -ForegroundColor yellow
    Write-Host ' [y/n] ' -NoNewline -ForegroundColor magenta
    switch (Read-Host) {
      'y' { return $true }
      'n' { return $false }
    }
  }
}

# Prompts user to choose an item from the array $options.
# Then returns the selected item
function Select-Item ([string[]]$options,[string]$property = 'Item') {
  # Check if argument is a number
  function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
  }
  $table = $options | ForEach-Object { $index = 1 } { [pscustomobject]@{ Option = $index; $property = $_ }; $index++ } | Format-Table -AutoSize | Out-String
  while (1) {
    Write-Host $table
    Write-Host 'Select one of the options.'
    $option = Read-Host
    if (Is-Numeric $option) {
      $index = (Invoke-Expression $option) - 1
      if (($index -gt -1) -and ($index -lt $options.length)) {
        return [string]$options[$index]
      }
    }
    Write-Host "Error: Please select a number between 1 and $($options.length)" -ForegroundColor red
  }
}
