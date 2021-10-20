function Print {
  [CmdletBinding(DefaultParameterSetName = 'Standard')]
  param(
    [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
    [Parameter(ParameterSetName = 'Success')]
    [Parameter(ParameterSetName = 'Fail')]
    [Parameter(ParameterSetName = 'Warn')]
    [Parameter(ParameterSetName = 'NoNewLine')]
    [Parameter(ParameterSetName = 'Standard')]
    $Message,

    [Parameter(ParameterSetName = 'Success')]
    [ValidateNotNullOrEmpty()]
    [switch] $Success = $false,

    [Parameter(ParameterSetName = 'Fail')]
    [ValidateNotNullOrEmpty()]
    [switch] $Fail = $false,

    [Parameter(ParameterSetName = 'Warn')]
    [ValidateNotNullOrEmpty()]
    [switch] $Warn = $false,

    [Parameter(ParameterSetName = 'NoNewLine')]
    [switch] $NoNewLine = $false
  )

  begin {
    $ErrorActionPreference = 'Stop'
  }

  process {
    # [yyyymmdd.HHmmssmmm] Message
    $tickers = (Get-Date -Format yyyyMMdd.HHmmss).Split('.')
    Write-Host '[' -NoNewline -ForegroundColor Cyan
    Write-Host $tickers[0] -NoNewline
    Write-Host '.' -NoNewline -ForegroundColor Green
    Write-Host $tickers[1] -NoNewline
    Write-Host '] ' -NoNewline -ForegroundColor Cyan
    switch ($PsCmdlet.ParameterSetName) {
      'Success' {
        Write-Host $Message -NoNewline
        Write-Host " SUCCESS" -ForegroundColor Green
        break
      }
      'Fail' {
        Write-Host $Message -NoNewline
        Write-Host " FAIL" -ForegroundColor Red
        break
      }
      'Warn' {
        Write-Host $Message -NoNewline
        Write-Host " WARNING" -ForegroundColor Yellow
        break
      }
      'NoNewLine' {
        Write-Host $Message -NoNewline
        break
      }
      'Standard' {
        Write-Host $Message
        break
      }
    }
  }
}

function IsWinner {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [int[]] $Cards,

    [Parameter(Mandatory)]
    [int[]] $Board
  )

  $ErrorActionPreference = 'Stop'
  $isWinner = $true
  $Board | ForEach-Object {
    $boardCard = $_
    if (-not $Cards.Contains($boardCard)) {
      $isWinner = $false
    }
  }

  Write-Output $isWinner
}