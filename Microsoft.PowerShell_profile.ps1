# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Import-Module oh-my-posh
# Import-Module posh-git
# Import-Module PSConsoleTheme

Set-ConsoleTheme 'Solarized Dark'
Set-Theme Agnoster

function ll { Get-ChildItem -Force }
function .. { cd .. }
function ... { cd ..\.. }
