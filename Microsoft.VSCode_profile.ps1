# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# set up persistent history
$HistoryFilePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) .ps_history
Register-EngineEvent PowerShell.Exiting -Action { Get-History | Export-Clixml $HistoryFilePath } | out-null
if (Test-path $HistoryFilePath) { Import-Clixml $HistoryFilePath | Add-History }


Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit
Set-PSReadlineKeyHandler -Key ctrl+s -Function ClearScreen
Remove-PSReadlineKeyHandler 'Ctrl+r'


Import-Module PSFzf -ArgumentList 'Ctrl+t','Ctrl+r'
Import-Module oh-my-posh
Import-Module posh-git
Import-Module PSConsoleTheme

Set-ConsoleTheme 'Solarized Dark'
Set-Theme Agnoster



function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function ll { Get-ChildItem -Force }
function tailf { Get-Content -Wait }
function ws { Set-Location $Home\Documents\workspace }
