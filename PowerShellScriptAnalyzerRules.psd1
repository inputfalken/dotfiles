@{
  IncludeRules = @(
    'PSPlaceOpenBrace',
    'PSPlaceCloseBrace',
    'PSUseConsistentWhitespace',
    'PSUseConsistentIndentation',
    'PSAlignAssignmentStatement'
  )

  Rules        = @{
    PSPlaceOpenBrace           = @{
      Enable             = $true
      OnSameLine         = $true
      NewLineAfter       = $true
      IgnoreOneLineBlock = $true
    }

    PSPlaceCloseBrace          = @{
      Enable             = $true
      NewLineAfter       = $false
      IgnoreOneLineBlock = $true
      NoEmptyLineBefore  = $false
    }

    PSUseConsistentIndentation = @{
      Enable          = $true
      Kind            = 'space'
      IndentationSize = 2
    }

    PSUseConsistentWhitespace  = @{
      Enable         = $true
      CheckOpenBrace = $true
      CheckOpenParen = $true
      CheckOperator  = $true
      CheckSeparator = $true
    }

    PSAlignAssignmentStatement = @{
      Enable         = $true
      CheckHashtable = $true
    }
  }
}

