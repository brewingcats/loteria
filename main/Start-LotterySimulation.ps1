function Start-LotterySimulation {
  [CmdletBinding()]
  param(
    [Parameter()]
    [ValidateScript({ $_ -gt 0 })]
    [int] $BoardCount = 4,

    [Parameter()]
    [ValidateScript({ ([System.IO.FileInfo] $_).Extension -eq '.xml' })]
    [string] $TempGameFile = $Script:config['LotteryFile']
  )

  $ErrorActionPreference = 'Stop'
  $originalFile = $Script:config['LotteryFile']
  if ($TempGameFile -ne $originalFile) {
    $file = [System.IO.FileInfo] $TempGameFile
    if (-not (Test-Path $file.DirectoryName)) {
      New-Item -Path $file.DirectoryName -ItemType Directory
    }

    $Script:config['LotteryFile'] = $TempGameFile
  }

  Print -Message "Will reset any existing game data!" -Warn
  Print -Message "Game data: $TempGameFile"
  Reset-LotteryGame
  Print -Message "Generating $BoardCount boards"
  1..$BoardCount | ForEach-Object { New-LotteryBoard }
  $drawAnotherCard = $true
  while($drawAnotherCard) {
    Get-LotteryCard
    $gameFile = Import-Clixml -Path $Script:config['LotteryFile']
    if ('None' -ne $gameFile['Winner']) {
      Print -Message ("{0} won this game" -f $gameFile['Winner']) -Success
      Print -Message ("This simulation required to draw {0} cards" -f $gameFile['DrawnCards'].Count)
      $drawAnotherCard = $false
    }
  }

  if ($TempGameFile -ne $originalFile) {
    $Script:config['LotteryFile'] = $originalFile
  }
}