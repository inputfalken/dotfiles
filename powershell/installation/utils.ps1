####################################################################################################
#                                                                                                  #
#                                     Shared Utility Functions                                     #
#                                                                                                  #
####################################################################################################

  # Check if the command exists.
  function Command-Exists {
    param (
      [Parameter(Mandatory=1)][string]$cmd,
      [Parameter(Mandatory=0)][ScriptBlock] $onSuccess = {},
      [Parameter(Mandatory=0)][ScriptBlock] $onFailure = {}
    )

    $result = [bool](Get-Command -Name $cmd -ErrorAction SilentlyContinue)
    if ($result) {
      $onSuccess.Invoke()
    } else {
      $onFailure.Invoke()
    }
    $result
  }
