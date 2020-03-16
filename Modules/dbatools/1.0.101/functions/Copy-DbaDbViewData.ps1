function Copy-DbaDbViewData {
    <#
    .SYNOPSIS
        Copies data from a SQL Server view to a table.

    .DESCRIPTION
        Copies data from a SQL Server view to a table using SQL Bulk Copy.
        With this function, a streaming copy will be done in the most speedy and least resource-intensive way.

    .PARAMETER SqlInstance
        Source SQL Server.You must have sysadmin access and server version must be SQL Server version 2000 or greater.

    .PARAMETER SqlCredential
        Login to the target instance using alternative credentials. Accepts PowerShell credentials (Get-Credential).

        Windows Authentication, SQL Server Authentication, Active Directory - Password, and Active Directory - Integrated are all supported.

        For MFA support, please use Connect-DbaInstance.

    .PARAMETER Destination
        Destination Sql Server. You must have sysadmin access and server version must be SQL Server version 2000 or greater.

    .PARAMETER DestinationSqlCredential
        Login to the target instance using alternative credentials. Accepts PowerShell credentials (Get-Credential).

        Windows Authentication, SQL Server Authentication, Active Directory - Password, and Active Directory - Integrated are all supported.

        For MFA support, please use Connect-DbaInstance.

    .PARAMETER Database
        The database to copy the table from.

    .PARAMETER DestinationDatabase
        The database to copy the table to. If not specified, it is assumed to be the same of Database

    .PARAMETER View
        Define a specific view you would like to use as source. You can specify a three-part name like db.sch.vw.
        If the object has special characters please wrap them in square brackets [ ].
        This dbo.First.View will try to find view named 'View' on schema 'First' and database 'dbo'.
        The correct way to find view named 'First.View' on schema 'dbo' is passing dbo.[First.View]

    .PARAMETER DestinationTable
        The table you want to use as destination. If not specified, it is assumed to be the same of View

    .PARAMETER Query
        If you want to copy only a portion of a view or selected views, specify the query.
        Ensure to select all required columns. Calculated Columns or columns with default values may be excluded.
        The tablename should be a full three-part name in form [Database].[Schema].[Table]

    .PARAMETER AutoCreateTable
        Creates the destination table if it does not already exist, based off of the "Export..." script of the source table.

    .PARAMETER BatchSize
        The BatchSize for the import defaults to 5000.

    .PARAMETER NotifyAfter
        Sets the option to show the notification after so many rows of import

    .PARAMETER NoTableLock
        If this switch is enabled, a table lock (TABLOCK) will not be placed on the destination table. By default, this operation will lock the destination table while running.

    .PARAMETER CheckConstraints
        If this switch is enabled, the SqlBulkCopy option to process check constraints will be enabled.

        Per Microsoft "Check constraints while data is being inserted. By default, constraints are not checked."

    .PARAMETER FireTriggers
        If this switch is enabled, the SqlBulkCopy option to fire insert triggers will be enabled.

        Per Microsoft "When specified, cause the server to fire the insert triggers for the rows being inserted into the Database."

    .PARAMETER KeepIdentity
        If this switch is enabled, the SqlBulkCopy option to preserve source identity values will be enabled.

        Per Microsoft "Preserve source identity values. When not specified, identity values are assigned by the destination."

    .PARAMETER KeepNulls
        If this switch is enabled, the SqlBulkCopy option to preserve NULL values will be enabled.

        Per Microsoft "Preserve null values in the destination table regardless of the settings for default values. When not specified, null values are replaced by default values where applicable."

    .PARAMETER Truncate
        If this switch is enabled, the destination table will be truncated after prompting for confirmation.

    .PARAMETER BulkCopyTimeOut
        Value in seconds for the BulkCopy operations timeout. The default is 30 seconds.

    .PARAMETER InputObject
        Enables piping of View objects from Get-DbaDbView

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
        Tags: Migration
        Author: Stephen Swan (@jaxnoth)

        Website: https://dbatools.io
        Copyright: (c) 2018 by dbatools, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://dbatools.io/Copy-DbaDbViewData

    .EXAMPLE
        PS C:\> Copy-DbaDbViewData -SqlInstance sql1 -Destination sql2 -Database dbatools_from -View dbo.test_view

        Copies all the data from view dbo.test_view in database dbatools_from on sql1 to view test_view in database dbatools_from on sql2.

    .EXAMPLE
        PS C:\> Copy-DbaDbViewData -SqlInstance sql1 -Destination sql2 -Database dbatools_from -DestinationDatabase dbatools_dest -Table [Schema].[test table]

        Copies all the data from view [Schema].[test view] in database dbatools_from on sql1 to table [Schema].[test table] in database dbatools_dest on sql2

    .EXAMPLE
        PS C:\> Get-DbaDbView -SqlInstance sql1 -Database tempdb -View vw1, vw2 | Copy-DbaDbViewData -DestinationTable tb3

        Copies all data from Views vw1 and vw2 in tempdb on sql1 to tb3 in tempdb on sql1

    .EXAMPLE
        PS C:\> Get-DbaDbView -SqlInstance sql1 -Database tempdb -View vw1, vw2 | Copy-DbaDbViewData -Destination sql2

        Copies data from tbl1 in tempdb on sql1 to tbl1 in tempdb on sql2
        then
        Copies data from tbl2 in tempdb on sql1 to tbl2 in tempdb on sql2

    .EXAMPLE
        PS C:\> Copy-DbaDbViewData -SqlInstance sql1 -Destination sql2 -Database dbatools_from -View test_view -KeepIdentity -Truncate

        Copies all the data in view test_view from sql1 to sql2, using the database dbatools_from, keeping identity columns and truncating the destination

    .EXAMPLE
        PS C:\> $params = @{
        >> SqlInstance = 'sql1'
        >> Destination = 'sql2'
        >> Database = 'dbatools_from'
        >> DestinationDatabase = 'dbatools_dest'
        >> View = '[Schema].[View]'
        >> DestinationTable = '[dbo].[View.Copy]'
        >> KeepIdentity = $true
        >> KeepNulls = $true
        >> Truncate = $true
        >> BatchSize = 10000
        >> }
        >>
        PS C:\> Copy-DbaDbViewData @params

        Copies all the data from view [Schema].[View] in database dbatools_from on sql1 to table [dbo].[Table.Copy] in database dbatools_dest on sql2
        Keeps identity columns and Nulls, truncates the destination and processes in BatchSize of 10000.

    .EXAMPLE
        PS C:\> $params = @{
        >> SqlInstance = 'server1'
        >> Destination = 'server1'
        >> Database = 'AdventureWorks2017'
        >> DestinationDatabase = 'AdventureWorks2017'
        >> View = '[Person].[EmailPromotion]'
        >> BatchSize = 10000
        >> Query = "SELECT * FROM [Person].[Person] where EmailPromotion = 1"
        >> }
        >>
        PS C:\> Copy-DbaDbViewData @params

        Copies data returned from the query on server1 into the AdventureWorks2017 on server1.
        Copy is processed in BatchSize of 10000 rows. Presuming the Person.EmailPromotion exists already.

    #>
    [CmdletBinding(DefaultParameterSetName = "Default", SupportsShouldProcess)]
    param (
        [DbaInstanceParameter]$SqlInstance,
        [PSCredential]$SqlCredential,
        [DbaInstanceParameter[]]$Destination,
        [PSCredential]$DestinationSqlCredential,
        [string]$Database,
        [string]$DestinationDatabase,
        [string[]]$View,
        [string]$Query,
        [switch]$AutoCreateTable,
        [int]$BatchSize = 50000,
        [int]$NotifyAfter = 5000,
        [string]$DestinationTable,
        [switch]$NoTableLock,
        [switch]$CheckConstraints,
        [switch]$FireTriggers,
        [switch]$KeepIdentity,
        [switch]$KeepNulls,
        [switch]$Truncate,
        [int]$bulkCopyTimeOut = 5000,
        [Parameter(ValueFromPipeline)]
        [Microsoft.SqlServer.Management.Smo.View[]]$InputObject,
        [switch]$EnableException
    )

    begin {
        # Getting the total rows copied is a challenge. Use SqlBulkCopyExtension.
        # http://stackoverflow.com/questions/1188384/sqlbulkcopy-row-count-when-complete

        $sourcecode = 'namespace System.Data.SqlClient {
            using Reflection;

            public static class SqlBulkCopyExtension
            {
                const String _rowsCopiedFieldName = "_rowsCopied";
                static FieldInfo _rowsCopiedField = null;

                public static int RowsCopiedCount(this SqlBulkCopy bulkCopy)
                {
                    if (_rowsCopiedField == null) _rowsCopiedField = typeof(SqlBulkCopy).GetField(_rowsCopiedFieldName, BindingFlags.NonPublic | BindingFlags.GetField | BindingFlags.Instance);
                    return (int)_rowsCopiedField.GetValue(bulkCopy);
                }
            }
        }'

        try {
            if ($script:core) {
                #.NET Core has moved most of the System.Data.SqlClient namespace to a separate assembly
                $SqlClientPath = "$script:PSModuleRoot\bin\smo\coreclr\System.Data.SqlClient.dll"
                if (Test-Path $SqlClientPath) {
                    #Powershell 6 appears to include a version of System.Data.SqlClient.dll
                    #that often precedes the following statement, but this enures that a version of
                    #the assemble gets loaded before loading our custom class.
                    Add-Type -Path $SqlClientPath
                }
                Add-Type -ReferencedAssemblies System.Data.SqlClient.dll -TypeDefinition $sourcecode -ErrorAction Stop
            } else {
                Add-Type -ReferencedAssemblies System.Data.dll -TypeDefinition $sourcecode -ErrorAction Stop
            }
            Write-Message -Level Verbose -Message "SqlBulkCopyExtension loaded."
        } catch {
            Stop-Function -Message 'Could not load a usable version of SqlBulkCopy.' -ErrorRecord $_
            return
        }

        $bulkCopyOptions = 0
        $options = "TableLock", "CheckConstraints", "FireTriggers", "KeepIdentity", "KeepNulls", "Default"

        foreach ($option in $options) {
            $optionValue = Get-Variable $option -ValueOnly -ErrorAction SilentlyContinue
            if ($option -eq "TableLock" -and (!$NoTableLock)) {
                $optionValue = $true
            }
            if ($optionValue -eq $true) {
                $bulkCopyOptions += $([Data.SqlClient.SqlBulkCopyOptions]::$option).value__
            }
        }
    }

    process {
        if ((Test-Bound -Not -ParameterName View, SqlInstance) -and (Test-Bound -Not -ParameterName InputObject)) {
            Stop-Function -Message "You must pipe in a view or specify SqlInstance, Database and View."
            return
        }

        if ($SqlInstance) {
            if ((Test-Bound -Not -ParameterName Database)) {
                Stop-Function -Message "Database is required when passing a SqlInstance" -Target $View
                return
            }

            if ((Test-Bound -Not -ParameterName Destination, DestinationDatabase, DestinationTable)) {
                Stop-Function -Message "Cannot copy $View into itself. One of destination Server, Database or View must be specified " -Target $View
                return
            }

            try {
                $server = Connect-SqlInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential
            } catch {
                Stop-Function -Message "Error occurred while establishing connection to $SqlInstance" -Category ConnectionError -ErrorRecord $_ -Target $SqlInstance
                return
            }

            if ($Database -notin $server.Databases.Name) {
                Stop-Function -Message "Database $Database doesn't exist on $server"
                return
            }

            try {
                foreach ($vw in $View) {
                    $dbView = Get-DbaDbView -SqlInstance $server -View $vw -Database $Database -EnableException -Verbose:$false
                    if ($dbView.Count -eq 1) {
                        $InputObject += $dbView
                    } else {
                        Stop-Function -Message "The view $vw matches $($dbView.Count) objects. Unable to determine which object to copy" -Continue
                    }
                }
            } catch {
                Stop-Function -Message "Unable to determine source view : $View"
                $ex = $_.Exception
                Write-Message -Level warning $ex.Message
                return
            }
        }

        foreach ($sqlview in $InputObject) {
            $Database = $sqlview.Parent.Name
            $server = $sqlview.Parent.Parent

            if ((Test-Bound -Not -ParameterName DestinationTable)) {
                $DestinationTable = '[' + $sqlview.Schema + '].[' + $sqlview.Name + ']'
            }

            $newTableParts = Get-ObjectNameParts -ObjectName $DestinationTable
            #using FQTN to determine database name
            if ($newTableParts.Database) {
                $DestinationDatabase = $newTableParts.Database
            } elseif ((Test-Bound -Not -ParameterName DestinationDatabase)) {
                $DestinationDatabase = $Database
            }

            if (-not $Destination) {
                $Destination = $server
            }

            foreach ($destinationserver in $Destination) {
                try {
                    $destServer = Connect-SqlInstance -SqlInstance $destinationserver -SqlCredential $DestinationSqlCredential
                } catch {
                    Stop-Function -Message "Error occurred while establishing connection to $instance" -Category ConnectionError -ErrorRecord $_ -Target $destinationserver
                    return
                }

                if ($DestinationDatabase -notin $destServer.Databases.Name) {
                    Stop-Function -Message "Database $DestinationDatabase doesn't exist on $destServer"
                    return
                }

                $desttable = Get-DbaDbTable -SqlInstance $destServer -Table $DestinationTable -Database $DestinationDatabase -Verbose:$false | Select-Object -First 1
                if (-not $desttable -and $AutoCreateTable) {
                    try {
                        #select view into tempdb to generate script
                        $tempTableName = "$($sqlview.Name)_table"
                        $createquery = "SELECT * INTO tempdb..$tempTableName FROM [$($sqlview.Schema)].[$($sqlview.Name)] WHERE 1=2"
                        Invoke-DbaQuery -SqlInstance $server -Database $Database -Query $createquery -EnableException
                        $tempTable = Get-DbaDbTable -SqlInstance $server -Database tempdb -Table $tempTableName
                        $tablescript = $tempTable | Export-DbaScript -Passthru | Out-String
                        Invoke-DbaQuery -SqlInstance $server -Database $Database -Query "DROP TABLE tempdb..$tempTableName" -EnableException
                        #replacing table name
                        if ($newTableParts.Name) {
                            $rX = "(CREATE TABLE \[$([regex]::Escape($tempTable.Schema))\]\.\[)$([regex]::Escape($tempTable.Name))(\]\()"
                            $tablescript = $tablescript -replace $rX, "`$1$($newTableParts.Name)`$2"
                        }
                        #replacing table schema
                        if ($newTableParts.Schema) {
                            $rX = "(CREATE TABLE \[)$([regex]::Escape($tempTable.Schema))(\]\.\[$([regex]::Escape($newTableParts.Name))\]\()"
                            $tablescript = $tablescript -replace $rX, "`$1$($newTableParts.Schema)`$2"
                        }

                        if ($PSCmdlet.ShouldProcess($destServer, "Creating new table: $DestinationTable")) {
                            Write-Message -Message "New table script: $tablescript" -Level VeryVerbose
                            Invoke-DbaQuery -SqlInstance $destServer -Database $DestinationDatabase -Query "$tablescript" -EnableException # add some string assurance there
                            #table list was updated, let's grab a fresh one
                            $destServer.Databases[$DestinationDatabase].Tables.Refresh()
                            $desttable = Get-DbaDbTable -SqlInstance $destServer -Table $DestinationTable -Database $DestinationDatabase -Verbose:$false
                            Write-Message -Message "New table created: $desttable" -Level Verbose
                        }
                    } catch {
                        Stop-Function -Message "Unable to determine destination table: $DestinationTable" -ErrorRecord $_
                        return
                    }
                }
                if (-not $desttable) {
                    Stop-Function -Message "Table $DestinationTable cannot be found in $DestinationDatabase. Use -AutoCreateTable to automatically create the table on the destination." -Continue
                }

                $connstring = $destServer.ConnectionContext.ConnectionString

                if ($server.DatabaseEngineType -eq "SqlAzureDatabase") {
                    $fqtnfrom = "$sqlview"
                } else {
                    $fqtnfrom = "$($server.Databases[$Database]).$sqlview"
                }

                if ($destServer.DatabaseEngineType -eq "SqlAzureDatabase") {
                    $fqtndest = "$desttable"
                } else {
                    $fqtndest = "$($destServer.Databases[$DestinationDatabase]).$desttable"
                }

                if ($fqtndest -eq $fqtnfrom -and $server.Name -eq $destServer.Name -and (Test-Bound -ParameterName Query -Not)) {
                    Stop-Function -Message "Cannot copy $fqtnfrom on $($server.Name) into $fqtndest on ($destServer.Name). Source and Destination must be different " -Target $View
                    return
                }


                if (Test-Bound -ParameterName Query -Not) {
                    $Query = "SELECT * FROM $fqtnfrom"
                    $sourceLabel = $fqtnfrom
                } else {
                    $sourceLabel = "Query"
                }
                try {
                    if ($Truncate -eq $true) {
                        if ($Pscmdlet.ShouldProcess($destServer, "Truncating table $fqtndest")) {
                            Invoke-DbaQuery -SqlInstance $destServer -Database $DestinationDatabase -Query "TRUNCATE TABLE $fqtndest" -EnableException
                        }
                    }
                    if ($Pscmdlet.ShouldProcess($server, "Copy data from $sourceLabel")) {
                        $cmd = $server.ConnectionContext.SqlConnectionObject.CreateCommand()
                        $cmd.CommandTimeout = 0
                        $cmd.CommandText = $Query
                        if ($server.ConnectionContext.IsOpen -eq $false) {
                            $server.ConnectionContext.SqlConnectionObject.Open()
                        }
                        $bulkCopy = New-Object Data.SqlClient.SqlBulkCopy("$connstring;Database=$DestinationDatabase", $bulkCopyOptions)
                        $bulkCopy.DestinationTableName = $fqtndest
                        $bulkCopy.EnableStreaming = $true
                        $bulkCopy.BatchSize = $BatchSize
                        $bulkCopy.NotifyAfter = $NotifyAfter
                        $bulkCopy.BulkCopyTimeOut = $BulkCopyTimeOut

                        $elapsed = [System.Diagnostics.Stopwatch]::StartNew()
                        # Add RowCount output
                        $bulkCopy.Add_SqlRowsCopied( {
                                $RowsPerSec = [math]::Round($args[1].RowsCopied / $elapsed.ElapsedMilliseconds * 1000.0, 1)
                                Write-Progress -id 1 -activity "Inserting rows" -Status ([System.String]::Format("{0} rows ({1} rows/sec)", $args[1].RowsCopied, $RowsPerSec))
                            })
                    }

                    if ($Pscmdlet.ShouldProcess($destServer, "Writing rows to $fqtndest")) {
                        $reader = $cmd.ExecuteReader()
                        $bulkCopy.WriteToServer($reader)
                        $RowsTotal = [System.Data.SqlClient.SqlBulkCopyExtension]::RowsCopiedCount($bulkCopy)
                        $TotalTime = [math]::Round($elapsed.Elapsed.TotalSeconds, 1)
                        Write-Message -Level Verbose -Message "$RowsTotal rows inserted in $TotalTime sec"
                        if ($rowCount -is [int]) {
                            Write-Progress -id 1 -activity "Inserting rows" -status "Complete" -Completed
                        }

                        $server.ConnectionContext.SqlConnectionObject.Close()
                        $bulkCopy.Close()
                        $bulkCopy.Dispose()
                        $reader.Close()

                        [pscustomobject]@{
                            SourceInstance      = $server.Name
                            SourceDatabase      = $Database
                            SourceSchema        = $sqlview.Schema
                            SourceView          = $sqlview.Name
                            DestinationInstance = $destServer.Name
                            DestinationDatabase = $DestinationDatabase
                            DestinationSchema   = $desttable.Schema
                            DestinationTable    = $desttable.Name
                            RowsCopied          = $rowstotal
                            Elapsed             = [prettytimespan]$elapsed.Elapsed
                        }
                    }
                } catch {
                    Stop-Function -Message "Something went wrong" -ErrorRecord $_ -Target $server -continue
                }
            }
        }
    }
}