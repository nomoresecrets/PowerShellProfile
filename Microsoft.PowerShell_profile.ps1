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

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function ll { Get-ChildItem -Force }
function tail { Get-Content -Wait }
function ws { Set-Location $Home\Documents\workspace }
