# Loteria #
PWSH module for managing Mexican Lottery game `v1.0`

#### Requirements ####
A recent version of PowerShell. It depends on xUtility module which can be installed by running: `Install-Module xUtility`

### New-LotteryBoard ###
Creates a new board with 16 random cards and updates the game file. If there are cards it checks if the newly created board is a winner

### Get-LotteryCard ###
Draws a new card randomly, check if the existing game boards can win with the updated set of cards. 
If there's a winner the game is finalized. Updates the game file to keep track of progress. If there's no game file it creates a new one to mark the beginning of the game

### Reset-LotteryGame ###
Deletes the game file including drawn cards and boards, creating a new board or drawing a card will start a new game

### Set-LotteryFilePath ###
Updates the game file used to track the game, useful if running multiple games simultaneously

### Start-LotterySimulation ###
Allows to run a simulation of a lottery game from beginning to end. Number of boards (players) can be passed (default is 4 boards). 
A temporary game file can be used to avoid overriding existing game files. Be careful


`Start-LotterySimulation -TempGameFile <path/to/your/file.xml>` uses a custom file

`Start-LotterySimulation -BoardCount 6` generates 6 boards (players) for the simulation
