function New-LotteryBoard {
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

  $boardName  = ("Board {0}" -f ($progress['Boards'].Keys.Count + 1))
  Print -Message ("Generating a new board named: {0}" -f $boardName)
  $board = @{}
  $sequence = 1..54 | Get-Random -Count 16
  $keepGenerating = $true
  if ($progress['Boards'].Keys.Count -eq 0) {
    $keepGenerating = $false
  }

  while ($keepGenerating) {
    # Check if sequence does not exist already
    Print -Message "Checking if this board is unique..."
    $keepTestingBoards = $true
    $progress['Boards'].Keys | Where-Object { $keepTestingBoards } | ForEach-Object {
      $testBoard = $_
      $testSequence = $progress['Boards'][$testBoard]['Sequence']
      $keepChecking = $true
      $sequence | Where-Object { $keepChecking } | ForEach-Object {
        $sequenceCard = $_
        if (-not $testSequence.Contains($sequenceCard)) {
          $keepChecking = $false
        }
      }
  
      if ($true -eq $keepChecking) {
        # Found a repeated board!
        Print -Message ("Generated sequence exists already on {0}!" -f $testBoard)
        $keepTestingBoards = $false
      }
    }

    if ($false -eq $keepTestingBoards) {
      # We have to generate a new sequence
      $sequence = 1..54 | Get-Random -Count 16
    } else {
      $keepGenerating = $false
    }
  }

  $board['Sequence'] = $sequence
  $board['CreatedOn'] = Get-Date
  Print -Message ("{0} created on {1} has the following cards:" -f $boardName, $board['CreatedOn'])
  Print -Message ("[{0}]" -f ($sequence -join ','))

  $progress['Boards'][$boardName] = $board

  # Check if the board is winner
  $skipCheckForWinner = $true
  if ($progress['CardHistory'].Count -ge 16) {
    $skipCheckForWinner = $false
  } else {
    Print -Message 'Not enough cards to call a winner'
  }

  if (-not $skipCheckForWinner) {
    Print -Message "Will check if $boardName is already a winner..."
    $isBoardWinner = IsWinner -Cards $progress['DrawnCards'] -Board $sequence

    if ($true -eq $isBoardWinner) {
      Print -Message ("Winner board: {0} created on: {1}" -f $boardName, $board['CreatedOn']) -Success
      Print -Message "Drawn Cards:"
      Print -Message ($progress['DrawnCards'] -join ', ')
      Print -Message "Drawn Cards in Order:"
      $dealtCards = $progress['DrawnCards'] | Sort-Object
      Print -Message ($dealtCards -join ', ')
      Print -Message "Board Cards:"
      Print -Message ($sequence -join ', ')
      Print -Message "Board Cards in Order:"
      $boardCards = $sequence | Sort-Object
      Print -Message ($boardCards -join ', ')
      $progress['Winner'] = $boardName
    } else {
      Print -Message "$boardName is not currently a winner"
    }
  }

  $progress | Export-CliXml -Path $progressFile
  Print -Message "Updated progress to Progress File"
}
