#
# Script module for module 'Az.Sql' that is executed when 'Az.Sql' is imported in a PowerShell session.
#
# Generated by: Microsoft Corporation
#
# Generated on: 03/05/2020 09:00:55
#

$PSDefaultParameterValues.Clear()
Set-StrictMode -Version Latest

function Test-DotNet
{
    try
    {
        if ((Get-PSDrive 'HKLM' -ErrorAction Ignore) -and (-not (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' -ErrorAction Stop | Get-ItemPropertyValue -ErrorAction Stop -Name Release | Where-Object { $_ -ge 461808 })))
        {
            throw ".NET Framework versions lower than 4.7.2 are not supported in Az.  Please upgrade to .NET Framework 4.7.2 or higher."
        }
    }
    catch [System.Management.Automation.DriveNotFoundException]
    {
        Write-Verbose ".NET Framework version check failed."
    }
}

if ($true -and ($PSEdition -eq 'Desktop'))
{
    if ($PSVersionTable.PSVersion -lt [Version]'5.1')
    {
        throw "PowerShell versions lower than 5.1 are not supported in Az. Please upgrade to PowerShell 5.1 or higher."
    }

    Test-DotNet
}

if (Test-Path -Path "$PSScriptRoot\StartupScripts" -ErrorAction Ignore)
{
    Get-ChildItem "$PSScriptRoot\StartupScripts" -ErrorAction Stop | ForEach-Object {
        . $_.FullName
    }
}

if (Get-Module AzureRM.profile -ErrorAction Ignore)
{
    Write-Warning ("AzureRM.Profile already loaded. Az and AzureRM modules cannot be imported in the same session or used in the same script or runbook. If you are running PowerShell in an environment you control you can use the 'Uninstall-AzureRm' cmdlet to remove all AzureRm modules from your machine. " +
        "If you are running in Azure Automation, take care that none of your runbooks import both Az and AzureRM modules. More information can be found here: https://aka.ms/azps-migration-guide.")
    throw ("AzureRM.Profile already loaded. Az and AzureRM modules cannot be imported in the same session or used in the same script or runbook. If you are running PowerShell in an environment you control you can use the 'Uninstall-AzureRm' cmdlet to remove all AzureRm modules from your machine. " +
        "If you are running in Azure Automation, take care that none of your runbooks import both Az and AzureRM modules. More information can be found here: https://aka.ms/azps-migration-guide.")
}

$preloadPath = (Join-Path $PSScriptRoot -ChildPath "PreloadAssemblies")
if($PSEdition -eq 'Desktop' -and (Test-Path $preloadPath -ErrorAction Ignore))
{
    try
    {
        Get-ChildItem -ErrorAction Stop -Path $preloadPath -Filter "*.dll" | ForEach-Object {
            Add-Type -Path $_.FullName -ErrorAction Ignore | Out-Null
        }
    }
    catch {}
}

$netCorePath = (Join-Path $PSScriptRoot -ChildPath "NetCoreAssemblies")
if($PSEdition -eq 'Core' -and (Test-Path $netCorePath -ErrorAction Ignore))
{
    try
    {
        $loadedAssemblies = ([System.AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {New-Object -TypeName System.Reflection.AssemblyName -ArgumentList $_.FullName} )
        Get-ChildItem -ErrorAction Stop -Path $netCorePath -Filter "*.dll" | ForEach-Object {
            $assemblyName = ([System.Reflection.AssemblyName]::GetAssemblyName($_.FullName))
            $matches = ($loadedAssemblies | Where-Object {$_.Name -eq $assemblyName.Name})
            if (-not $matches)
            {
                Add-Type -Path $_.FullName -ErrorAction Ignore | Out-Null
            }
        }
    }
    catch {}
}


$module = Get-Module Az.Accounts 
if ($module -ne $null -and $module.Version.ToString().CompareTo("1.7.3") -lt 0) 
{ 
    Write-Error "This module requires Az.Accounts version 1.7.3. An earlier version of Az.Accounts is imported in the current PowerShell session. Please open a new session before importing this module. This error could indicate that multiple incompatible versions of the Azure PowerShell cmdlets are installed on your system. Please see https://aka.ms/azps-version-error for troubleshooting information." -ErrorAction Stop 
} 
elseif ($module -eq $null) 
{ 
    Import-Module Az.Accounts -MinimumVersion 1.7.3 -Scope Global 
}
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath Microsoft.Azure.PowerShell.Cmdlets.Sql.dll)


if (Test-Path -Path "$PSScriptRoot\PostImportScripts" -ErrorAction Ignore)
{
    Get-ChildItem "$PSScriptRoot\PostImportScripts" -ErrorAction Stop | ForEach-Object {
        . $_.FullName
    }
}

$FilteredCommands = @('Clear-AzSqlDatabaseVulnerabilityAssessmentSetting:ResourceGroupName','Get-AzSqlDatabaseVulnerabilityAssessmentSetting:ResourceGroupName','Update-AzSqlDatabaseVulnerabilityAssessmentSetting:ResourceGroupName','Clear-AzSqlInstanceDatabaseVulnerabilityAssessmentSetting:ResourceGroupName','Get-AzSqlInstanceDatabaseVulnerabilityAssessmentSetting:ResourceGroupName','Update-AzSqlInstanceDatabaseVulnerabilityAssessmentSetting:ResourceGroupName','Convert-AzSqlDatabaseVulnerabilityAssessmentScan:ResourceGroupName','Get-AzSqlDatabaseVulnerabilityAssessmentScanRecord:ResourceGroupName','Start-AzSqlDatabaseVulnerabilityAssessmentScan:ResourceGroupName','Convert-AzSqlInstanceDatabaseVulnerabilityAssessmentScan:ResourceGroupName','Get-AzSqlInstanceDatabaseVulnerabilityAssessmentScanRecord:ResourceGroupName','Start-AzSqlInstanceDatabaseVulnerabilityAssessmentScan:ResourceGroupName','Clear-AzSqlDatabaseVulnerabilityAssessmentRuleBaseline:ResourceGroupName','Get-AzSqlDatabaseVulnerabilityAssessmentRuleBaseline:ResourceGroupName','Set-AzSqlDatabaseVulnerabilityAssessmentRuleBaseline:ResourceGroupName','Clear-AzSqlInstanceDatabaseVulnerabilityAssessmentRuleBaseline:ResourceGroupName','Get-AzSqlInstanceDatabaseVulnerabilityAssessmentRuleBaseline:ResourceGroupName','Set-AzSqlInstanceDatabaseVulnerabilityAssessmentRuleBaseline:ResourceGroupName','Get-AzSqlServerVirtualNetworkRule:ResourceGroupName','New-AzSqlServerVirtualNetworkRule:ResourceGroupName','Remove-AzSqlServerVirtualNetworkRule:ResourceGroupName','Set-AzSqlServerVirtualNetworkRule:ResourceGroupName','Get-AzSqlDatabaseTransparentDataEncryption:ResourceGroupName','Get-AzSqlDatabaseTransparentDataEncryptionActivity:ResourceGroupName','Get-AzSqlServerTransparentDataEncryptionProtector:ResourceGroupName','Set-AzSqlDatabaseTransparentDataEncryption:ResourceGroupName','Set-AzSqlServerTransparentDataEncryptionProtector:ResourceGroupName','Get-AzSqlDatabaseAdvancedThreatProtectionSetting:ResourceGroupName','Get-AzSqlServerAdvancedThreatProtectionSetting:ResourceGroupName','Clear-AzSqlDatabaseAdvancedThreatProtectionSetting:ResourceGroupName','Clear-AzSqlServerAdvancedThreatProtectionSetting:ResourceGroupName','Update-AzSqlDatabaseAdvancedThreatProtectionSetting:ResourceGroupName','Update-AzSqlServerAdvancedThreatProtectionSetting:ResourceGroupName','Get-AzSqlDatabaseUpgradeHint:ResourceGroupName','Get-AzSqlServerUpgradeHint:ResourceGroupName','New-AzSqlServer:ResourceGroupName','Remove-AzSqlServer:ResourceGroupName','Set-AzSqlServer:ResourceGroupName','Add-AzSqlServerKeyVaultKey:ResourceGroupName','Get-AzSqlServerKeyVaultKey:ResourceGroupName','Remove-AzSqlServerKeyVaultKey:ResourceGroupName','Get-AzSqlServerDnsAlias:ResourceGroupName','New-AzSqlServerDnsAlias:ResourceGroupName','Set-AzSqlServerDnsAlias:ResourceGroupName','Get-AzSqlServerDisasterRecoveryConfiguration:ResourceGroupName','Get-AzSqlServerDisasterRecoveryConfigurationActivity:ResourceGroupName','New-AzSqlServerDisasterRecoveryConfiguration:ResourceGroupName','Remove-AzSqlServerDisasterRecoveryConfiguration:ResourceGroupName','Set-AzSqlServerDisasterRecoveryConfiguration:ResourceGroupName','Get-AzSqlServerCommunicationLink:ResourceGroupName','New-AzSqlServerCommunicationLink:ResourceGroupName','Remove-AzSqlServerCommunicationLink:ResourceGroupName','Get-AzSqlServerActiveDirectoryAdministrator:ResourceGroupName','Remove-AzSqlServerActiveDirectoryAdministrator:ResourceGroupName','Set-AzSqlServerActiveDirectoryAdministrator:ResourceGroupName','Get-AzSqlDatabaseReplicationLink:ResourceGroupName','New-AzSqlDatabaseCopy:ResourceGroupName','New-AzSqlDatabaseSecondary:ResourceGroupName','Remove-AzSqlDatabaseSecondary:ResourceGroupName','Set-AzSqlDatabaseSecondary:ResourceGroupName','Get-AzSqlElasticPoolRecommendation:ResourceGroupName','Get-AzSqlDatabaseRecommendedAction:ResourceGroupName','Get-AzSqlElasticPoolRecommendedAction:ResourceGroupName','Get-AzSqlServerRecommendedAction:ResourceGroupName','Set-AzSqlDatabaseRecommendedActionState:ResourceGroupName','Set-AzSqlElasticPoolRecommendedActionState:ResourceGroupName','Set-AzSqlServerRecommendedActionState:ResourceGroupName','Get-AzSqlDeletedInstanceDatabaseBackup:ResourceGroupName','Get-AzSqlInstanceDatabaseBackupLongTermRetentionPolicy:ResourceGroupName','Set-AzSqlInstanceDatabaseBackupLongTermRetentionPolicy:ResourceGroupName','New-AzSqlInstancePool:ResourceGroupName','Get-AzSqlDatabaseInstanceFailoverGroup:ResourceGroupName','New-AzSqlDatabaseInstanceFailoverGroup:ResourceGroupName','Get-AzSqlDatabaseIndexRecommendation:ResourceGroupName','Start-AzSqlDatabaseExecuteIndexRecommendation:ResourceGroupName','Stop-AzSqlDatabaseExecuteIndexRecommendation:ResourceGroupName','New-AzSqlDatabaseExport:ResourceGroupName','New-AzSqlDatabaseImport:ResourceGroupName','Get-AzSqlServerFirewallRule:ResourceGroupName','New-AzSqlServerFirewallRule:ResourceGroupName','Remove-AzSqlServerFirewallRule:ResourceGroupName','Set-AzSqlServerFirewallRule:ResourceGroupName','Add-AzSqlDatabaseToFailoverGroup:ResourceGroupName','Get-AzSqlDatabaseFailoverGroup:ResourceGroupName','New-AzSqlDatabaseFailoverGroup:ResourceGroupName','Remove-AzSqlDatabaseFromFailoverGroup:ResourceGroupName','Remove-AzSqlDatabaseFailoverGroup:ResourceGroupName','Set-AzSqlDatabaseFailoverGroup:ResourceGroupName','Switch-AzSqlDatabaseFailoverGroup:ResourceGroupName','Get-AzSqlElasticPool:ResourceGroupName','Get-AzSqlElasticPoolActivity:ResourceGroupName','Get-AzSqlElasticPoolDatabase:ResourceGroupName','Invoke-AzSqlElasticPoolFailover:ResourceGroupName','New-AzSqlElasticPool:ResourceGroupName','Remove-AzSqlElasticPool:ResourceGroupName','Set-AzSqlElasticPool:ResourceGroupName','Stop-AzSqlElasticPoolActivity:ResourceGroupName','Get-AzSqlDatabase:ResourceGroupName','Get-AzSqlDatabaseActivity:ResourceGroupName','Get-AzSqlDatabaseExpanded:ResourceGroupName','Invoke-AzSqlDatabaseFailover:ResourceGroupName','New-AzSqlDatabase:ResourceGroupName','Remove-AzSqlDatabase:ResourceGroupName','Set-AzSqlDatabase:ResourceGroupName','Stop-AzSqlDatabaseActivity:ResourceGroupName','Get-AzSqlDatabaseGeoBackup:ResourceGroupName','Get-AzSqlDeletedDatabaseBackup:ResourceGroupName','Get-AzSqlDatabaseBackupLongTermRetentionPolicy:ResourceGroupName','Get-AzSqlDatabaseGeoBackupPolicy:ResourceGroupName','Get-AzSqlDatabaseRestorePoint:ResourceGroupName','New-AzSqlDatabaseRestorePoint:ResourceGroupName','Remove-AzSqlDatabaseRestorePoint:ResourceGroupName','Restore-AzSqlDatabase:ResourceGroupName','Set-AzSqlDatabaseBackupLongTermRetentionPolicy:ResourceGroupName','Set-AzSqlDatabaseGeoBackupPolicy:ResourceGroupName','Resume-AzSqlDatabase:ResourceGroupName','Suspend-AzSqlDatabase:ResourceGroupName','Get-AzSqlSyncAgent:ResourceGroupName','Get-AzSqlSyncAgentLinkedDatabase:ResourceGroupName','Get-AzSqlSyncGroup:ResourceGroupName','Get-AzSqlSyncGroupLog:ResourceGroupName','Get-AzSqlSyncMember:ResourceGroupName','Get-AzSqlSyncSchema:ResourceGroupName','New-AzSqlSyncAgent:ResourceGroupName','New-AzSqlSyncAgentKey:ResourceGroupName','New-AzSqlSyncGroup:ResourceGroupName','New-AzSqlSyncMember:ResourceGroupName','Remove-AzSqlSyncAgent:ResourceGroupName','Remove-AzSqlSyncGroup:ResourceGroupName','Remove-AzSqlSyncMember:ResourceGroupName','Start-AzSqlSyncGroupSync:ResourceGroupName','Stop-AzSqlSyncGroupSync:ResourceGroupName','Update-AzSqlSyncGroup:ResourceGroupName','Update-AzSqlSyncMember:ResourceGroupName','Update-AzSqlSyncSchema:ResourceGroupName','Get-AzSqlDatabaseDataMaskingPolicy:ResourceGroupName','Get-AzSqlDatabaseDataMaskingRule:ResourceGroupName','New-AzSqlDatabaseDataMaskingRule:ResourceGroupName','Remove-AzSqlDatabaseDataMaskingRule:ResourceGroupName','Set-AzSqlDatabaseDataMaskingPolicy:ResourceGroupName','Set-AzSqlDatabaseDataMaskingRule:ResourceGroupName','Get-AzSqlDatabaseAdvisor:ResourceGroupName','Get-AzSqlElasticPoolAdvisor:ResourceGroupName','Get-AzSqlServerAdvisor:ResourceGroupName','Set-AzSqlDatabaseAdvisorAutoExecuteStatus:ResourceGroupName','Set-AzSqlElasticPoolAdvisorAutoExecuteStatus:ResourceGroupName','Set-AzSqlServerAdvisorAutoExecuteStatus:ResourceGroupName','Disable-AzSqlInstanceAdvancedDataSecurity:ResourceGroupName','Disable-AzSqlServerAdvancedDataSecurity:ResourceGroupName','Enable-AzSqlInstanceAdvancedDataSecurity:ResourceGroupName','Enable-AzSqlServerAdvancedDataSecurity:ResourceGroupName','Get-AzSqlInstanceAdvancedDataSecurityPolicy:ResourceGroupName','Get-AzSqlServerAdvancedDataSecurityPolicy:ResourceGroupName')

if ($Env:ACC_CLOUD -eq $null)
{
    $FilteredCommands | ForEach-Object {

        $existingDefault = $false
        foreach ($key in $global:PSDefaultParameterValues.Keys)
        {
    	    if ($_ -like "$key")
    	        {
        	    $existingDefault = $true
    	        }
	    }

        if (!$existingDefault)
        {
            $global:PSDefaultParameterValues.Add($_,
                {
                    if ((Get-Command Get-AzContext -ErrorAction Ignore) -eq $null)
                    {
                        $context = Get-AzureRmContext
                    }
                    else
                    {
                        $context = Get-AzContext
                    }
                    if (($context -ne $null) -and $context.ExtendedProperties.ContainsKey("Default Resource Group")) {
                        $context.ExtendedProperties["Default Resource Group"]
                    }
                })
        }
    }
}

# SIG # Begin signature block
# MIIjhgYJKoZIhvcNAQcCoIIjdzCCI3MCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDFlKUhYh4NAZv1
# 6zRMPBzKAi8SgKz38UUl7vmprjLEnqCCDYEwggX/MIID56ADAgECAhMzAAABUZ6N
# j0Bxow5BAAAAAAFRMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMTkwNTAyMjEzNzQ2WhcNMjAwNTAyMjEzNzQ2WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCVWsaGaUcdNB7xVcNmdfZiVBhYFGcn8KMqxgNIvOZWNH9JYQLuhHhmJ5RWISy1
# oey3zTuxqLbkHAdmbeU8NFMo49Pv71MgIS9IG/EtqwOH7upan+lIq6NOcw5fO6Os
# +12R0Q28MzGn+3y7F2mKDnopVu0sEufy453gxz16M8bAw4+QXuv7+fR9WzRJ2CpU
# 62wQKYiFQMfew6Vh5fuPoXloN3k6+Qlz7zgcT4YRmxzx7jMVpP/uvK6sZcBxQ3Wg
# B/WkyXHgxaY19IAzLq2QiPiX2YryiR5EsYBq35BP7U15DlZtpSs2wIYTkkDBxhPJ
# IDJgowZu5GyhHdqrst3OjkSRAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUV4Iarkq57esagu6FUBb270Zijc8w
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDU0MTM1MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAWg+A
# rS4Anq7KrogslIQnoMHSXUPr/RqOIhJX+32ObuY3MFvdlRElbSsSJxrRy/OCCZdS
# se+f2AqQ+F/2aYwBDmUQbeMB8n0pYLZnOPifqe78RBH2fVZsvXxyfizbHubWWoUf
# NW/FJlZlLXwJmF3BoL8E2p09K3hagwz/otcKtQ1+Q4+DaOYXWleqJrJUsnHs9UiL
# crVF0leL/Q1V5bshob2OTlZq0qzSdrMDLWdhyrUOxnZ+ojZ7UdTY4VnCuogbZ9Zs
# 9syJbg7ZUS9SVgYkowRsWv5jV4lbqTD+tG4FzhOwcRQwdb6A8zp2Nnd+s7VdCuYF
# sGgI41ucD8oxVfcAMjF9YX5N2s4mltkqnUe3/htVrnxKKDAwSYliaux2L7gKw+bD
# 1kEZ/5ozLRnJ3jjDkomTrPctokY/KaZ1qub0NUnmOKH+3xUK/plWJK8BOQYuU7gK
# YH7Yy9WSKNlP7pKj6i417+3Na/frInjnBkKRCJ/eYTvBH+s5guezpfQWtU4bNo/j
# 8Qw2vpTQ9w7flhH78Rmwd319+YTmhv7TcxDbWlyteaj4RK2wk3pY1oSz2JPE5PNu
# Nmd9Gmf6oePZgy7Ii9JLLq8SnULV7b+IP0UXRY9q+GdRjM2AEX6msZvvPCIoG0aY
# HQu9wZsKEK2jqvWi8/xdeeeSI9FN6K1w4oVQM4Mwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIVWzCCFVcCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAVGejY9AcaMOQQAAAAABUTAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg1uMyIqe2
# id+rtCUW1N7DWAhwrH6VTo+ZN+Ugw/TqdE0wQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQA1mDCgmteC5tnZwQOJOZ2WtXlEnmFiahhA137v8v3+
# BKhhEnZqalGa4du6FoGclp4t16DUTQ0dzsrYEproirIG8rxptEtsoA0qc6aiAxjh
# crsLK0NVPKKS/pwA7s90d9HdYtzu6xcEC88JaHjyrFX2a9ENEzZNeJSJF3U3QI/g
# +7wl+rO8bOYuu+uDgyfKXXrEfPhhJvT8nmKauFy4nPqhCsD4ss31tUkGAlASr4IB
# FDvHKLCNMYSk1+2FHsgQSzMXDxFI5XlQ948+BimWwHvMZEES0AnrrC2YbYafmFDO
# pykg2uV71rBu/gWSYEQ7B8iPii/wJeaZBqBILB1HdLKcoYIS5TCCEuEGCisGAQQB
# gjcDAwExghLRMIISzQYJKoZIhvcNAQcCoIISvjCCEroCAQMxDzANBglghkgBZQME
# AgEFADCCAVEGCyqGSIb3DQEJEAEEoIIBQASCATwwggE4AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEILO7UBKV+6vyJMNrtI0w72xZfM/tTSt2H85yaAH6
# hsjDAgZeTHuWih4YEzIwMjAwMzA1MDkxMjUwLjUyMVowBIACAfSggdCkgc0wgcox
# CzAJBgNVBAYTAlVTMQswCQYDVQQIEwJXQTEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQg
# SXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOjg2REYtNEJCQy05MzM1MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNloIIOPDCCBPEwggPZoAMCAQICEzMAAAEPgHL2OocIiK0AAAAAAQ8w
# DQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcN
# MTkxMDIzMjMxOTE4WhcNMjEwMTIxMjMxOTE4WjCByjELMAkGA1UEBhMCVVMxCzAJ
# BgNVBAgTAldBMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlv
# bnMgTGltaXRlZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046ODZERi00QkJDLTkz
# MzUxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDfTTlAqt7zsZXhYoIINcxBZgfl5YjR
# GxMb7ZlQjUCdrc6k+8zabHfZx0zltIbHzS7JPC88SgrCAs/MmK9FBxXDrnJ050gK
# BZinoEQI3CSJEZw4WufCT8O6FCAmbn5MaretSdqgOK4l+Vz+BOVD0LioTRavX2Ce
# g4iJYGTdOylXieYrpDTd9RmTiUCYi4Vu4EFZWJoZ2YapTFTYV7wIcuAIZKDosv+E
# Z/wVJL3xSa1foAYCf/w8qERb8NVialjOH2fE3Lf5oQeg/j/4zVrmJ7xipPyNN3ml
# txJ7Z1XyGQ7H9kLtmsWvGsAwl0QWVa5ZWP7UvXR+iM89DD/fVVTuncMzAgMBAAGj
# ggEbMIIBFzAdBgNVHQ4EFgQU55UhgBltUsagF5bsdqrKlu8Y5XswHwYDVR0jBBgw
# FoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDov
# L2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljVGltU3RhUENB
# XzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNUaW1TdGFQQ0FfMjAx
# MC0wNy0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDCDAN
# BgkqhkiG9w0BAQsFAAOCAQEAUIKxNncVWmmhpMsoVq3EeX2fhYTLEeDJ6HiDd3zc
# bvEsogFfpt7xq8iBr4YphPqhgs6yZayK5NEM6yOXEx7DYaPH32JELKHa3kWz3VsX
# lIAUrJk5FvUXYEZS2o3Og2F3RBvGtUQHze4ZR+rpSCNivRvjZYt7HQN/z4ucWiVD
# CJZeq+yNCggFTcrWKW2Fij5NreYcOvBox69xHyNa7fup2gSqO2h7H5toIN5LQ95s
# hRt8HcRGALaym4WOsjQ5O9s/4ypLJs84zKY2nMQJjZe64wEDuF5UkAZQBkr1yx1G
# 0HSP8QsLGbXEBVP9bi5mu25quoDVuB4o832eKwczNk3ZfjCCBnEwggRZoAMCAQIC
# CmEJgSoAAAAAAAIwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRp
# ZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTEwMDcwMTIxMzY1NVoXDTI1MDcwMTIx
# NDY1NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
# A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCpHQ28dxGKOiDs/BOX9fp/aZRrdFQQ1aUKAIKF
# ++18aEssX8XD5WHCdrc+Zitb8BVTJwQxH0EbGpUdzgkTjnxhMFmxMEQP8WCIhFRD
# DNdNuDgIs0Ldk6zWczBXJoKjRQ3Q6vVHgc2/JGAyWGBG8lhHhjKEHnRhZ5FfgVSx
# z5NMksHEpl3RYRNuKMYa+YaAu99h/EbBJx0kZxJyGiGKr0tkiVBisV39dx898Fd1
# rL2KQk1AUdEPnAY+Z3/1ZsADlkR+79BL/W7lmsqxqPJ6Kgox8NpOBpG2iAg16Hgc
# sOmZzTznL0S6p/TcZL2kAcEgCZN4zfy8wMlEXV4WnAEFTyJNAgMBAAGjggHmMIIB
# 4jAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU1WM6XIoxkPNDe3xGG8UzaFqF
# bVUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1Ud
# EwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYD
# VR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwv
# cHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEB
# BE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9j
# ZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwgaAGA1UdIAEB/wSBlTCB
# kjCBjwYJKwYBBAGCNy4DMIGBMD0GCCsGAQUFBwIBFjFodHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vUEtJL2RvY3MvQ1BTL2RlZmF1bHQuaHRtMEAGCCsGAQUFBwICMDQe
# MiAdAEwAZQBnAGEAbABfAFAAbwBsAGkAYwB5AF8AUwB0AGEAdABlAG0AZQBuAHQA
# LiAdMA0GCSqGSIb3DQEBCwUAA4ICAQAH5ohRDeLG4Jg/gXEDPZ2joSFvs+umzPUx
# vs8F4qn++ldtGTCzwsVmyWrf9efweL3HqJ4l4/m87WtUVwgrUYJEEvu5U4zM9GAS
# inbMQEBBm9xcF/9c+V4XNZgkVkt070IQyK+/f8Z/8jd9Wj8c8pl5SpFSAK84Dxf1
# L3mBZdmptWvkx872ynoAb0swRCQiPM/tA6WWj1kpvLb9BOFwnzJKJ/1Vry/+tuWO
# M7tiX5rbV0Dp8c6ZZpCM/2pif93FSguRJuI57BlKcWOdeyFtw5yjojz6f32WapB4
# pm3S4Zz5Hfw42JT0xqUKloakvZ4argRCg7i1gJsiOCC1JeVk7Pf0v35jWSUPei45
# V3aicaoGig+JFrphpxHLmtgOR5qAxdDNp9DvfYPw4TtxCd9ddJgiCGHasFAeb73x
# 4QDf5zEHpJM692VHeOj4qEir995yfmFrb3epgcunCaw5u+zGy9iCtHLNHfS4hQEe
# gPsbiSpUObJb2sgNVZl6h3M7COaYLeqN4DMuEin1wC9UJyH3yKxO2ii4sanblrKn
# QqLJzxlBTeCG+SqaoxFmMNO7dDJL32N79ZmKLxvHIa9Zta7cRDyXUHHXodLFVeNp
# 3lfB0d4wwP3M5k37Db9dT+mdHhk4L7zPWAUu7w2gUDXa7wknHNWzfjUeCLraNtvT
# X4/edIhJEqGCAs4wggI3AgEBMIH4oYHQpIHNMIHKMQswCQYDVQQGEwJVUzELMAkG
# A1UECBMCV0ExEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9u
# cyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjo4NkRGLTRCQkMtOTMz
# NTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcG
# BSsOAwIaAxUAJEG7Qp9TlB0Wedu0oJJBeqFkt2mggYMwgYCkfjB8MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
# VGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIFAOIKwD8wIhgPMjAy
# MDAzMDUwODAzMTFaGA8yMDIwMDMwNjA4MDMxMVowdzA9BgorBgEEAYRZCgQBMS8w
# LTAKAgUA4grAPwIBADAKAgEAAgIWUAIB/zAHAgEAAgIRujAKAgUA4gwRvwIBADA2
# BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIB
# AAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBAItoCF2vmmt+oK6WsMHRfzm0qmj0cUcc
# 3lFYJ6ryv4F3R2N144fK7oBb1dQgDINCwhuhZSpq1uvOXmEt8VkNIpTXnxtNJp6/
# gcZhG8IsI2bwB4tJ2tg1Ypw1KZs47TsrTXo0Cb9AcxQ+AW/yvS4a0tJhiaBtUJge
# TsRWQv7HcC3WMYIDDTCCAwkCAQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAEPgHL2OocIiK0AAAAAAQ8wDQYJYIZIAWUDBAIBBQCgggFKMBoG
# CSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQgWUEwrhF0
# +pAAaUkdMhAA0cYGM1NzTOyaKnWUT7g4sNQwgfoGCyqGSIb3DQEJEAIvMYHqMIHn
# MIHkMIG9BCA/mr0OeWgtFGzyp0EMW9VrRBbgtkv30N6zFN7wdHQ+jjCBmDCBgKR+
# MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
# HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABD4By9jqHCIitAAAA
# AAEPMCIEIGhTndRTQEmUU7fmai3H2TIId8Uenu94l7Nl6LUAKGT3MA0GCSqGSIb3
# DQEBCwUABIIBAE5t34MKyVaDADkgKPadHWtRVMn4a/JgXAIPNu7VWdZjAHC7e1Ie
# oRw1xslTbHm7ZNStiyI1Jf8tdxrQjCJtxJNd589RFEt6oMKXXe46Ug2ptNoW5ygb
# 8FT7bLkvQ8zsmuG7AQZKuCSW+h7G5STdeRpykKERd+Pq7xqyHhYmy6uPj7K2x4XP
# XXH8At/A+5+cMEMUowUuSoQ9pjpmplWeo9Bv1uRHsxZkLklgqRqfNM9rkzUcE0c7
# wVc8ygUtkMByctsEe64HZFwYwgGtV4UC/I502WlfOV5JVOeCZSJfLC3iMROaiDd3
# X9LpfOnavBEcCs1HQrMDpij04m3EfrJ39Vw=
# SIG # End signature block
