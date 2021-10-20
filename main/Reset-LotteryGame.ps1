<#
.SYNOPSIS
Removes the configured file for the lottery game

#>
function Reset-LotteryGame {
  [CmdletBinding()]
  param()

  $ErrorActionPreference = 'Stop'

  $lotteryFile = $Script:config['LotteryFile']
  Print -Message "Current Lottery File: $lotteryFile"
  if (-not (Test-Path $lotteryFile)) {
    Print -Message "Lottery File does not exist currently" -Warn
  } else {
    Remove-Item $lotteryFile -Force
    Print -Message "Removed Lottery File: $lotteryFile"
  }
}