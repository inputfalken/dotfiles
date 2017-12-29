####################################################################################################
#                                                                                                  #
#                                     Shared Utility Functions                                     #
#                                                                                                  #
####################################################################################################

  # Check if the command exists.
  function Command-Exists {
    param (
      [Parameter(Mandatory=1)][string]$cmd,
      [Parameter(Mandatory=0)][ScriptBlock] $whenExisting = {},
      [Parameter(Mandatory=0)][ScriptBlock] $whenMissing = {}
    )

    $result = [bool](Get-Command -Name $cmd -ErrorAction SilentlyContinue)
    if ($result) {
      $whenExisting.Invoke()
    } else {
      $whenMissing.Invoke()
    }
    $result
  }
