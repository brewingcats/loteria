# Load files
$Script:modulePath = Join-Path -Path $PSScriptRoot -ChildPath 'main'
Get-ChildItem -Path $Script:modulePath -Filter '*.ps1' -Recurse | ForEach-Object {
  . $_.FullName
}

$manifest = Join-Path -Path $PSScriptRoot -ChildPath 'loteria.psd1'
$tmpFile = Get-TempPath
$tmpFile = Join-Path -Path $tmpFile -ChildPath 'manifest.ps1'
Copy-Item $manifest $tmpFile -Force
$manifestData = . $tmpFile
$modVersion = [System.Version] $manifestData['ModuleVersion']
Print -Message "Reading Module Version..." -Success

$Script:AppData = Join-Path -Path (Get-AppDataPath) -ChildPath 'Loteria'
if (-not (Test-Path $Script:AppData)) {
  New-Item -Path $Script:AppData -ItemType Directory | Write-Verbose
}

$Script:config = @{}
$configFile = Join-Path -Path $Script:AppData -ChildPath 'config.xml'
if ((Test-Path $configFile)) {
  $Script:config = Import-Clixml -Path $configFile
}

if ($null -eq $Script:config['LotteryFile']) {
  $Script:config['LotteryFile'] = Join-Path -Path $Script:AppData -ChildPath "LotteryProgress.xml"
  $Script:config | Export-Clixml -Path $configFile
}

Print -Message ("Lottery File: {0}" -f $Script:config['LotteryFile'])

Print -Message "*" -NoNewLine
Write-Host "[" -NoNewline
Write-Host "Lottery" -NoNewLine -ForegroundColor Cyan
Write-Host "]* v" -NoNewLine
Write-Host $modVersion.Major -NoNewLine -ForegroundColor Green
Write-Host "." -NoNewLine
Write-Host $modVersion.Minor -NoNewLine -ForegroundColor Green
Write-Host "." -NoNewLine
Write-Host $modVersion.Build -NoNewLine -ForegroundColor Green
Write-Host ""