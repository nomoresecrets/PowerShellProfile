@{
RootModule = 'ExchangeOnlineManagement.psm1'
FunctionsToExport = 'Connect-ExchangeOnline'
ModuleVersion = '0.3582.0'
GUID = 'B5ECED50-AFA4-455B-847A-D8FB64140A22'
Author = 'Exchange Manageability Team'
CompanyName = 'Microsoft'
Copyright = '(c) 2019 Microsoft. All rights reserved.'
Description = 'This is a public preview release of Exchange Online PowerShell V2 module. Below are the steps to install the module:
    1. Install-Module PowerShellGet -Force
    2. Set-ExecutionPolicy Unrestricted <After this step, please reopen the window.>
    3. Install-Module -Name ExchangeOnlineManagement
Send your feedback/suggestions to exocmdletpreview.microsoft.com'
PowerShellVersion = '3.0'
ProcessorArchitecture = 'AMD64'
CmdletsToExport = @('Get-EXOCasMailbox','Get-EXOMailbox','Get-EXOMailboxFolderPermission','Get-EXOMailboxFolderStatistics','Get-EXOMailboxPermission','Get-EXOMailboxStatistics','Get-EXOMobileDeviceStatistics','Get-EXORecipient','Get-EXORecipientPermission')
FileList = @('.\Microsoft.Exchange.Management.AdminApiProvider.dll',
        '.\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll',
        '.\Microsoft.Exchange.Management.RestApiClient.dll',
        '.\Microsoft.IdentityModel.Clients.ActiveDirectory.dll',
        '.\Microsoft.OData.Client.dll',
        '.\Microsoft.OData.Core.dll',
        '.\Microsoft.OData.Edm.dll',
        '.\Microsoft.Online.CSE.RestApiPowerShellModule.Instrumentation.dll',
        '.\Microsoft.Spatial.dll',
        '.\Newtonsoft.Json.dll',
        '.\System.IO.Abstractions.dll',
        '.\System.Management.Automation.dll',
        '.\license.txt')

PrivateData = @{
    PSData = @{
    # Tags applied to this module. These help with module discovery in online galleries.
    Tags = 'Exchange', 'ExchangeOnline', 'EXO', 'EXOV2', 'Mailbox', 'Management'
    ReleaseNotes = '
---------------------------------------------------------------------------------------------
Whats new in this release:
 
v0.3582.0 :
    1. Support for prefix during session creation
        i. You can create only 1 session at a time which can have prefixed cmdlets. 
       ii. Note that the EXO V2 cmdlets will not be prefixed as they already have a prefix ''EXO'' and hence please refrain from using ''EXO'' as a prefix during session creation.
    2. Use EXO V2 cmdlets even if WinRM Basic Auth is disabled on client machine
    3. Identity parameter for V2 cmdlets now supports name and alias as well
        i. Please note that using alias or name slows down the performance of V2 cmdlets and hence it is not recommended to use this option 
    4. Fixed issue where data-type of attributes returned by V2 cmdlet was different from Remote PowerShell cmdlets
    5. Fixed bug - Frequent sessions reconnects issue when Connect-ExchangeOnline was invoked with Credentials or UserPrincipalName

---------------------------------------------------------------------------------------------
Previous Releases:
 
v0.3555.1 :
    1. Bug fixes and enhancements.

v0.3527.4 :
    1. Updated Get-Help.

v0.3527.3 :
    1. Added support for managing Exchange for a different tenant using delegation flow.
        Read more here: https://docs.microsoft.com/en-in/powershell/module/exchange/powershell-v2-module/connect-exchangeonline?view=exchange-ps#parameters
    2. Works in tandem with other PowerShell modules in a single PS window
    3. Added support for positional parameters
    4. Date Time field now supports client locale
    5. Fixed Bug : PSCredential getting empty when passed during Connect-ExchangeOnline
    6. Fixed Bug : Client module used to throw error when filter contained $null
    7. Sessions created internal to EXO V2 Module will now have names (Naming pattern : ExchangeOnlineInternalSession_%SomeNumber% )
    8. Fixed Bug : Remote PowerShell cmdlets resulting into intermittent failure due to difference of time between token expiry and PSSession getting Idle.
    9. Major security update
    10. Bug fixes and enhancements
---------------------------------------------------------------------------------------------
'
    LicenseUri="http://aka.ms/azps-license"
    }
}
}