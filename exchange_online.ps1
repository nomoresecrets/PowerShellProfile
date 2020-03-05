$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential (Get-Credential -UserName 'denny.gebel@foerch.de' -Message 'Exchange Online Credentials') -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

# Connect-ExchangeOnline -Credential (Get-Credential -UserName 'denny.gebel@foerch.de' -Message 'Exchange Online Credentials') -ShowProgress $true