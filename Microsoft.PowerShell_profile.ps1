# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Agnoster
Import-Module PSConsoleTheme
Set-ConsoleTheme 'Solarized Dark'

function ll { Get-ChildItem -Force }
