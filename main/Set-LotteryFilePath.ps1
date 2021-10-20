function Set-LotteryFilePath {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [ValidateScript({ ([System.IO.FileInfo] $_).Extension -eq '.xml' })]
    [string] $Path
  )

  $ErrorActionPreference = 'Stop'
  $fileInfo = [System.IO.FileInfo] $Path
  $haveDir = $fileInfo.Directory | Test-Path
  if (-not $haveDir) {
    New-Item -Path $fileInfo.DirectoryName -ItemType Directory
  }

  $Script:config['LotteryFile'] = $Path
  $configFile = Join-Path -Path $Script:AppData -ChildPath 'config.xml'
  $Script:config | Export-Clixml -Path $configFile
  Print -Message "Lottery File Updated to: $Path" -Success
}