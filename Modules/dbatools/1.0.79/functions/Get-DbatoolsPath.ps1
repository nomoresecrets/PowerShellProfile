function Get-DbatoolsPath {
    <#
    .SYNOPSIS
        Access a configured path.

    .DESCRIPTION
        Access a configured path.
        Paths can be configured using Set-DbatoolsPath or using the configuration system.
        To register a path using the configuration system create a setting key named like this:
        "Path.Managed.<PathName>"
        For example the following setting points at the temp path:
        "Path.Managed.Temp"

    .PARAMETER Name
        Name of the path to retrieve.

    .EXAMPLE
        PS C:\> Get-DbatoolsPath -Name 'temp'

        Returns the temp path.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    process {
        Get-DbatoolsConfigValue -FullName "Path.Managed.$Name"
    }
}