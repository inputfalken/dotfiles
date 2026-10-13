return {
  -- Editor Services treats unsent whitespace rules as disabled, unlike the VS Code extension which enables them.
  settings = {
    powershell = {
      codeFormatting = {
        Preset = 'OTBS',
        whitespaceBeforeOpenBrace = true,
        whitespaceBeforeOpenParen = true,
        whitespaceAroundOperator = true,
        whitespaceAfterSeparator = true,
        whitespaceInsideBrace = true,
        whitespaceBetweenParameters = true,
        addWhitespaceAroundPipe = true,
        alignPropertyValuePairs = true,
        autoCorrectAliases = true,
        useCorrectCasing = true,
      },
    },
  },
}
