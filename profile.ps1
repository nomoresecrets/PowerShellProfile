# # Chocolatey profile
# $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
# if (Test-Path($ChocolateyProfile)) {
# Import-Module "$ChocolateyProfile"
# }

# set up persistent history
$HistoryFilePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) .ps_history
Register-EngineEvent PowerShell.Exiting -Action { Get-History | Export-Clixml $HistoryFilePath } | Out-Null
if (Test-Path $HistoryFilePath) { Import-Clixml $HistoryFilePath | Add-History }

Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionSource History

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord
Set-PSReadLineKeyHandler -Key Alt+B -Function SelectShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+F -Function SelectShellForwardWord
Set-PSReadLineKeyHandler -Key ctrl+d -Function ViExit
Set-PSReadLineKeyHandler -Key ctrl+s -Function ClearScreen

Remove-PSReadLineKeyHandler 'Ctrl+r'


Import-Module PSFzf -ArgumentList 'Ctrl+t', 'Ctrl+r'
Import-Module oh-my-posh
Import-Module posh-git
# Import-Module PSConsoleTheme

# Set-ConsoleTheme 'Solarized Dark'
Set-Theme Agnoster

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'


function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function ll { Get-ChildItem -Force }
function tailf { Get-Content -Wait }
function ws { Set-Location c:\workspace }
function grep { $input | Out-String -Stream | Select-String $args }
