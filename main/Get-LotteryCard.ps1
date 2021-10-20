<#
.SYNOPSIS
Draws a new card from the remaining set

.DESCRIPTION
Uses the progress file to read the remaining set of cards and selects a random card
Selected card is removed from the available list and added to the history entry
Checks if there's a winner from the existing boards
Progress file is then updated

#>
function Get-LotteryCard {
  [CmdletBinding()]
  param()
  
  $ErrorActionPreference = 'Stop'
  $progressFile = $Script:config['LotteryFile']
  Print -Message "Progress File: $progressFile"
  $progress = @{}
  if (-not (Test-Path $progressFile)) {
      Print -Message "Progress file does not exists, starting from scratch..."
      $progress['AvailableCards'] = @(1..54)
      $progress['CardHistory'] = @()
      $progress['Winner'] = 'None'
      $progress['DrawnCards'] = @()
      $progress['Boards'] = @{}

  } else {
      $progress = Import-CliXml -Path $progressFile
  }

  if ('None' -ne $progress['Winner']) {
    Print -Message ("{0} already won this game" -f $progress['Winner']) -Success
    Print -Message "History:"
    $progress['CardHistory'] | Print
    return
  }
  
  if ($progress['AvailableCards'].Count -eq 0) {
      Print -Message "No more cards to draw, game finished!" -Success
      Print -Message "History:"
      $progress['CardHistory'] | Print
      return
  }
  
  Print -Message ("Remaining Cards: {0} -> [{1}]" -f $progress['AvailableCards'].Count, ($progress['AvailableCards'] -join ','))
  $card = $progress['AvailableCards'] | Get-Random
  $progress['DrawnCards'] += $card
  Print "Next is card $card"
  if ($progress['AvailableCards'].Count -eq 1) {
      $progress['AvailableCards'] = @()
  } else {
      $progress['AvailableCards'] = $progress['AvailableCards'] | Where-Object { $_ -ne $card }
  }
  
  $history = ("Card {0} showed up - {1} " -f $card, (Get-Date))
  Print -Message "Drawing history:"
  $progress['CardHistory'] += $history
  $progress['CardHistory'] | Print

  $skipCheckForWinner = $true
  if ($progress['CardHistory'].Count -ge 16) {
    $skipCheckForWinner = $false
  } else {
    Print -Message ("Need to draw at least 16 cards, currently: {0} cards" -f $progress['CardHistory'].Count) -Warn
  }

  if (-not $skipCheckForWinner -and $null -ne $progress['Boards'] -and $progress['Boards'].Keys.Count -gt 0) {
    Print -Message ("Checking for winner boards, number of boards: {0}" -f $progress['Boards'].Keys.Count)
  } else {
    Print -Message "Will not check for winner board"
    $skipCheckForWinner = $true
  }

  if (-not $skipCheckForWinner) {
    $keepCheckingBoards = $true
    $progress['Boards'].Keys | Where-Object { $keepCheckingBoards } | ForEach-Object {
      $boardName = $_
      $boardCards = $progress['Boards'][$boardName]['Sequence']
      $isBoardWinner = IsWinner -Cards $progress['DrawnCards'] -Board $boardCards

      if ($true -eq $isBoardWinner) {
        $keepCheckingBoards = $false
        $winnerBoard = $progress['Boards'][$boardName]
        Print -Message ("Winner board: {0} created on: {1}" -f $boardName, $winnerBoard['CreatedOn']) -Success
        Print -Message "Drawn Cards:"
        Print -Message ($progress['DrawnCards'] -join ', ')
        Print -Message "Drawn Cards in Order:"
        $dealtCards = $progress['DrawnCards'] | Sort-Object
        Print -Message ($dealtCards -join ', ')
        Print -Message "Board Cards:"
        Print -Message ($winnerBoard['Sequence'] -join ', ')
        Print -Message "Board Cards in Order:"
        $boardCards = $winnerBoard['Sequence'] | Sort-Object
        Print -Message ($boardCards -join ', ')
        $progress['Winner'] = $boardName
      }
    }
  }
  
  $progress | Export-CliXml -Path $progressFile
  Print -Message "Updated progress to Progress File"
}