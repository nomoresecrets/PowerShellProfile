if ($PSVersionTable.PSVersion.Major -lt 5) {


    <#
Copied from the Microsoft Module: Microsoft.PowerShell.Archive
Which ships with PowerShell Version 5 but will run under v3.
    #>



    function Expand-Archive {
        <#
            .SYNOPSIS
                Extracts files from a specified archive (zipped) file.

            .DESCRIPTION
                The Expand-Archive cmdlet extracts files from a specified zipped archive file to a specified destination folder. An archive file allows multiple files to be packaged, and optionally compressed, into a single zipped file for easier distribution and storage.

            .PARAMETER Path
                Specifies the path to the archive file.

            .PARAMETER LiteralPath
                Specifies the path to an archive file. Unlike the Path parameter, the value of LiteralPath is used exactly as it is typed. Wildcard characters are not supported. If the path includes escape characters, enclose each escape character in single quotation marks, to instruct Windows PowerShell not to interpret any characters as escape sequences.

            .PARAMETER DestinationPath
                Specifies the path to the folder in which you want the command to save extracted files. Enter the path to a folder, but do not specify a file name or file name extension. This parameter is required.

            .PARAMETER Force
                Forces the command to run without asking for user confirmation.

            .PARAMETER Confirm
                Prompts you for confirmation before running the cmdlet.

            .PARAMETER WhatIf
                Shows what would happen if the cmdlet runs. The cmdlet is not run.

            .EXAMPLE
                Example 1: Extract the contents of an archive

                PS C:\>Expand-Archive -LiteralPath C:\Archives\Draft.Zip -DestinationPath C:\Reference

                This command extracts the contents of an existing archive file, Draft.zip, into the folder specified by the DestinationPath parameter, C:\Reference.

            .EXAMPLE
                Example 2: Extract the contents of an archive in the current folder

                PS C:\>Expand-Archive -Path Draft.Zip -DestinationPath C:\Reference

                This command extracts the contents of an existing archive file in the current folder, Draft.zip, into the folder specified by the DestinationPath parameter, C:\Reference.
        #>
        [CmdletBinding(
            DefaultParameterSetName = "Path",
            SupportsShouldProcess,
            HelpUri = "http://go.microsoft.com/fwlink/?LinkID=393253")]
        param
        (
            [parameter (
                Mandatory,
                Position = 0,
                ParameterSetName = "Path",
                ValueFromPipeline,
                ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [string]
            $Path,

            [parameter (
                Mandatory,
                ParameterSetName = "LiteralPath",
                ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias("PSPath")]
            [string]
            $LiteralPath,

            [parameter (
                Position = 1,
                ValueFromPipeline = $false,
                ValueFromPipelineByPropertyName = $false)]
            [ValidateNotNullOrEmpty()]
            [string]
            $DestinationPath,

            [parameter (
                ValueFromPipeline = $false,
                ValueFromPipelineByPropertyName = $false)]
            [switch]
            $Force
        )

        BEGIN {
            Add-Type -AssemblyName System.IO.Compression -ErrorAction Ignore
            Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Ignore

            $zipFileExtension = ".zip"

            $LocalizedData = ConvertFrom-StringData @'
    PathNotFoundError=The path '{0}' either does not exist or is not a valid file system path.
    ExpandArchiveInValidDestinationPath=The path '{0}' is not a valid file system directory path.
    InvalidZipFileExtensionError={0} is not a supported archive file format. {1} is the only supported archive file format.
    ArchiveFileIsReadOnly=The attributes of the archive file {0} is set to 'ReadOnly' hence it cannot be updated. If you intend to update the existing archive file, remove the 'ReadOnly' attribute on the archive file else use -Force parameter to override and create a new archive file.
    ZipFileExistError=The archive file {0} already exists. Use the -Update parameter to update the existing archive file or use the -Force parameter to overwrite the existing archive file.
    DuplicatePathFoundError=The input to {0} parameter contains a duplicate path '{1}'. Provide a unique set of paths as input to {2} parameter.
    ArchiveFileIsEmpty=The archive file {0} is empty.
    CompressProgressBarText=The archive file '{0}' creation is in progress...
    ExpandProgressBarText=The archive file '{0}' expansion is in progress...
    AppendArchiveFileExtensionMessage=The archive file path '{0}' supplied to the DestinationPath patameter does not include .zip extension. Hence .zip is appended to the supplied DestinationPath path and the archive file would be created at '{1}'.
    AddItemtoArchiveFile=Adding '{0}'.
    CreateFileAtExpandedPath=Created '{0}'.
    InvalidArchiveFilePathError=The archive file path '{0}' specified as input to the {1} parameter is resolving to multiple file system paths. Provide a unique path to the {2} parameter where the archive file has to be created.
    InvalidExpandedDirPathError=The directory path '{0}' specified as input to the DestinationPath parameter is resolving to multiple file system paths. Provide a unique path to the Destination parameter where the archive file contents have to be expanded.
    FileExistsError=Failed to create file '{0}' while expanding the archive file '{1}' contents as the file '{2}' already exists. Use the -Force parameter if you want to overwrite the existing directory '{3}' contents when expanding the archive file.
    DeleteArchiveFile=The partially created archive file '{0}' is deleted as it is not usable.
    InvalidDestinationPath=The destination path '{0}' does not contain a valid archive file name.
    PreparingToCompressVerboseMessage=Preparing to compress...
    PreparingToExpandVerboseMessage=Preparing to expand...
'@

            #region Utility Functions
            function GetResolvedPathHelper {
                param
                (
                    [string[]]
                    $path,

                    [boolean]
                    $isLiteralPath,

                    [System.Management.Automation.PSCmdlet]
                    $callerPSCmdlet
                )

                $resolvedPaths = @()

                # null and empty check are are already done on Path parameter at the cmdlet layer.
                foreach ($currentPath in $path) {
                    try {
                        if ($isLiteralPath) {
                            $currentResolvedPaths = Resolve-Path -LiteralPath $currentPath -ErrorAction Stop
                        } else {
                            $currentResolvedPaths = Resolve-Path -Path $currentPath -ErrorAction Stop
                        }
                    } catch {
                        $errorMessage = ($LocalizedData.PathNotFoundError -f $currentPath)
                        $exception = New-Object System.InvalidOperationException $errorMessage, $_.Exception
                        $errorRecord = CreateErrorRecordHelper "ArchiveCmdletPathNotFound" $null ([System.Management.Automation.ErrorCategory]::InvalidArgument) $exception $currentPath
                        $callerPSCmdlet.ThrowTerminatingError($errorRecord)
                    }

                    foreach ($currentResolvedPath in $currentResolvedPaths) {
                        $resolvedPaths += $currentResolvedPath.ProviderPath
                    }
                }

                $resolvedPaths
            }

            function Add-CompressionAssemblies {

                if ($PSEdition -eq "Desktop") {
                    Add-Type -AssemblyName System.IO.Compression
                    Add-Type -AssemblyName System.IO.Compression.FileSystem
                }
            }

            function IsValidFileSystemPath {
                param
                (
                    [string[]]
                    $path
                )

                $result = $true;

                # null and empty check are are already done on Path parameter at the cmdlet layer.
                foreach ($currentPath in $path) {
                    if (!([System.IO.File]::Exists($currentPath) -or [System.IO.Directory]::Exists($currentPath))) {
                        $errorMessage = ($LocalizedData.PathNotFoundError -f $currentPath)
                        ThrowTerminatingErrorHelper "PathNotFound" $errorMessage ([System.Management.Automation.ErrorCategory]::InvalidArgument) $currentPath
                    }
                }

                return $result;
            }


            function ValidateDuplicateFileSystemPath {
                param
                (
                    [string]
                    $inputParameter,

                    [string[]]
                    $path
                )

                $uniqueInputPaths = @()

                # null and empty check are are already done on Path parameter at the cmdlet layer.
                foreach ($currentPath in $path) {
                    $currentInputPath = $currentPath.ToUpper()
                    if ($uniqueInputPaths.Contains($currentInputPath)) {
                        $errorMessage = ($LocalizedData.DuplicatePathFoundError -f $inputParameter, $currentPath, $inputParameter)
                        ThrowTerminatingErrorHelper "DuplicatePathFound" $errorMessage ([System.Management.Automation.ErrorCategory]::InvalidArgument) $currentPath
                    } else {
                        $uniqueInputPaths += $currentInputPath
                    }
                }
            }

            function CompressionLevelMapper {
                param
                (
                    [string]
                    $compressionLevel
                )

                $compressionLevelFormat = [System.IO.Compression.CompressionLevel]::Optimal

                # CompressionLevel format is already validated at the cmdlet layer.
                switch ($compressionLevel.ToString()) {
                    "Fastest" {
                        $compressionLevelFormat = [System.IO.Compression.CompressionLevel]::Fastest
                    }
                    "NoCompression" {
                        $compressionLevelFormat = [System.IO.Compression.CompressionLevel]::NoCompression
                    }
                }

                return $compressionLevelFormat
            }

            function CompressArchiveHelper {
                param
                (
                    [string[]]
                    $sourcePath,

                    [string]
                    $destinationPath,

                    [string]
                    $compressionLevel,

                    [bool]
                    $isUpdateMode
                )

                $numberOfItemsArchived = 0
                $sourceFilePaths = @()
                $sourceDirPaths = @()

                foreach ($currentPath in $sourcePath) {
                    $result = Test-Path -LiteralPath $currentPath -PathType Leaf
                    if ($result -eq $true) {
                        $sourceFilePaths += $currentPath
                    } else {
                        $sourceDirPaths += $currentPath
                    }
                }

                # The Soure Path contains one or more directory (this directory can have files under it) and no files to be compressed.
                if ($sourceFilePaths.Count -eq 0 -and $sourceDirPaths.Count -gt 0) {
                    $currentSegmentWeight = 100 / [double]$sourceDirPaths.Count
                    $previousSegmentWeight = 0
                    foreach ($currentSourceDirPath in $sourceDirPaths) {
                        $count = CompressSingleDirHelper $currentSourceDirPath $destinationPath $compressionLevel $true $isUpdateMode $previousSegmentWeight $currentSegmentWeight
                        $numberOfItemsArchived += $count
                        $previousSegmentWeight += $currentSegmentWeight
                    }
                }

                # The Soure Path contains only files to be compressed.
                elseIf ($sourceFilePaths.Count -gt 0 -and $sourceDirPaths.Count -eq 0) {
                    # $previousSegmentWeight is equal to 0 as there are no prior segments.
                    # $currentSegmentWeight is set to 100 as all files have equal weightage.
                    $previousSegmentWeight = 0
                    $currentSegmentWeight = 100

                    $numberOfItemsArchived = CompressFilesHelper $sourceFilePaths $destinationPath $compressionLevel $isUpdateMode $previousSegmentWeight $currentSegmentWeight
                }
                # The Soure Path contains one or more files and one or more directories (this directory can have files under it) to be compressed.
                elseif ($sourceFilePaths.Count -gt 0 -and $sourceDirPaths.Count -gt 0) {
                    # each directory is considered as an individual segments & all the individual files are clubed in to a separate sgemnet.
                    $currentSegmentWeight = 100 / [double]($sourceDirPaths.Count + 1)
                    $previousSegmentWeight = 0

                    foreach ($currentSourceDirPath in $sourceDirPaths) {
                        $count = CompressSingleDirHelper $currentSourceDirPath $destinationPath $compressionLevel $true $isUpdateMode $previousSegmentWeight $currentSegmentWeight
                        $numberOfItemsArchived += $count
                        $previousSegmentWeight += $currentSegmentWeight
                    }

                    $count = CompressFilesHelper $sourceFilePaths $destinationPath $compressionLevel $isUpdateMode $previousSegmentWeight $currentSegmentWeight
                    $numberOfItemsArchived += $count
                }

                return $numberOfItemsArchived
            }

            function CompressFilesHelper {
                param
                (
                    [string[]]
                    $sourceFilePaths,

                    [string]
                    $destinationPath,

                    [string]
                    $compressionLevel,

                    [bool]
                    $isUpdateMode,

                    [double]
                    $previousSegmentWeight,

                    [double]
                    $currentSegmentWeight
                )

                $numberOfItemsArchived = ZipArchiveHelper $sourceFilePaths $destinationPath $compressionLevel $isUpdateMode $null $previousSegmentWeight $currentSegmentWeight

                return $numberOfItemsArchived
            }

            function CompressSingleDirHelper {
                param
                (
                    [string]
                    $sourceDirPath,

                    [string]
                    $destinationPath,

                    [string]
                    $compressionLevel,

                    [bool]
                    $useParentDirAsRoot,

                    [bool]
                    $isUpdateMode,

                    [double]
                    $previousSegmentWeight,

                    [double]
                    $currentSegmentWeight
                )

                [System.Collections.Generic.List[System.String]]$subDirFiles = @()

                if ($useParentDirAsRoot) {
                    $sourceDirInfo = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList $sourceDirPath
                    $sourceDirFullName = $sourceDirInfo.Parent.FullName

                    # If the directory is present at the drive level the DirectoryInfo.Parent include '\' example: C:\
                    # On the other hand if the directory exists at a deper level then DirectoryInfo.Parent
                    # has just the path (without an ending '\'). example C:\source
                    if ($sourceDirFullName.Length -eq 3) {
                        $modifiedSourceDirFullName = $sourceDirFullName
                    } else {
                        $modifiedSourceDirFullName = $sourceDirFullName + "\"
                    }
                } else {
                    $sourceDirFullName = $sourceDirPath
                    $modifiedSourceDirFullName = $sourceDirFullName + "\"
                }

                $dirContents = Get-ChildItem -LiteralPath $sourceDirPath -Recurse
                foreach ($currentContent in $dirContents) {
                    $isContainer = $currentContent -is [System.IO.DirectoryInfo]
                    if (!$isContainer) {
                        $subDirFiles.Add($currentContent.FullName)
                    } else {
                        # The currentContent points to a directory.
                        # We need to check if the directory is an empty directory, if so such a
                        # directory has to be explictly added to the archive file.
                        # if there are no files in the directory the GetFiles() API returns an empty array.
                        $files = $currentContent.GetFiles()
                        if ($files.Count -eq 0) {
                            $subDirFiles.Add($currentContent.FullName + "\")
                        }
                    }
                }

                $numberOfItemsArchived = ZipArchiveHelper $subDirFiles.ToArray() $destinationPath $compressionLevel $isUpdateMode $modifiedSourceDirFullName $previousSegmentWeight $currentSegmentWeight

                return $numberOfItemsArchived
            }

            function ZipArchiveHelper {
                param
                (
                    [System.Collections.Generic.List[System.String]]
                    $sourcePaths,

                    [string]
                    $destinationPath,

                    [string]
                    $compressionLevel,

                    [bool]
                    $isUpdateMode,

                    [string]
                    $modifiedSourceDirFullName,

                    [double]
                    $previousSegmentWeight,

                    [double]
                    $currentSegmentWeight
                )

                $numberOfItemsArchived = 0
                $fileMode = [System.IO.FileMode]::Create
                $result = Test-Path -LiteralPath $DestinationPath -PathType Leaf
                if ($result -eq $true) {
                    $fileMode = [System.IO.FileMode]::Open
                }

                Add-CompressionAssemblies

                try {
                    # At this point we are sure that the archive file has write access.
                    $archiveFileStreamArgs = @($destinationPath, $fileMode)
                    $archiveFileStream = New-Object -TypeName System.IO.FileStream -ArgumentList $archiveFileStreamArgs

                    $zipArchiveArgs = @($archiveFileStream, [System.IO.Compression.ZipArchiveMode]::Update, $false)
                    $zipArchive = New-Object -TypeName System.IO.Compression.ZipArchive -ArgumentList $zipArchiveArgs

                    $currentEntryCount = 0
                    $progressBarStatus = ($LocalizedData.CompressProgressBarText -f $destinationPath)
                    $bufferSize = 4kb
                    $buffer = New-Object Byte[] $bufferSize

                    foreach ($currentFilePath in $sourcePaths) {
                        if ($modifiedSourceDirFullName -ne $null -and $modifiedSourceDirFullName.Length -gt 0) {
                            $index = $currentFilePath.IndexOf($modifiedSourceDirFullName, [System.StringComparison]::OrdinalIgnoreCase)
                            $currentFilePathSubString = $currentFilePath.Substring($index, $modifiedSourceDirFullName.Length)
                            $relativeFilePath = $currentFilePath.Replace($currentFilePathSubString, "").Trim()
                        } else {
                            $relativeFilePath = [System.IO.Path]::GetFileName($currentFilePath)
                        }

                        # Update mode is selected.
                        # Check to see if archive file already contains one or more zip files in it.
                        if ($isUpdateMode -eq $true -and $zipArchive.Entries.Count -gt 0) {
                            $entryToBeUpdated = $null

                            # Check if the file already exists in the archive file.
                            # If so replace it with new file from the input source.
                            # If the file does not exist in the archive file then default to
                            # create mode and create the entry in the archive file.

                            foreach ($currentArchiveEntry in $zipArchive.Entries) {
                                if ($currentArchiveEntry.FullName -eq $relativeFilePath) {
                                    $entryToBeUpdated = $currentArchiveEntry
                                    break
                                }
                            }

                            if ($entryToBeUpdated -ne $null) {
                                $addItemtoArchiveFileMessage = ($LocalizedData.AddItemtoArchiveFile -f $currentFilePath)
                                $entryToBeUpdated.Delete()
                            }
                        }

                        $compression = CompressionLevelMapper $compressionLevel

                        # If a directory needs to be added to an archive file,
                        # by convention the .Net API's expect the path of the diretcory
                        # to end with '\' to detect the path as an directory.
                        if (!$relativeFilePath.EndsWith("\", [StringComparison]::OrdinalIgnoreCase)) {
                            try {
                                try {
                                    $currentFileStream = [System.IO.File]::Open($currentFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
                                } catch {
                                    # Failed to access the file. Write a non terminating error to the pipeline
                                    # and move on with the remaining files.
                                    $exception = $_.Exception
                                    if ($null -ne $_.Exception -and
                                        $null -ne $_.Exception.InnerException) {
                                        $exception = $_.Exception.InnerException
                                    }
                                    $errorRecord = CreateErrorRecordHelper "CompressArchiveUnauthorizedAccessError" $null ([System.Management.Automation.ErrorCategory]::PermissionDenied) $exception $currentFilePath
                                    Write-Error -ErrorRecord $errorRecord
                                }

                                if ($null -ne $currentFileStream) {
                                    $srcStream = New-Object System.IO.BinaryReader $currentFileStream

                                    $currentArchiveEntry = $zipArchive.CreateEntry($relativeFilePath, $compression)

                                    # Updating  the File Creation time so that the same timestamp would be retained after expanding the compressed file.
                                    # At this point we are sure that Get-ChildItem would succeed.
                                    $currentArchiveEntry.LastWriteTime = (Get-Item -LiteralPath $currentFilePath).LastWriteTime

                                    $destStream = New-Object System.IO.BinaryWriter $currentArchiveEntry.Open()

                                    while ($numberOfBytesRead = $srcStream.Read($buffer, 0, $bufferSize)) {
                                        $destStream.Write($buffer, 0, $numberOfBytesRead)
                                        $destStream.Flush()
                                    }

                                    $numberOfItemsArchived += 1
                                    $addItemtoArchiveFileMessage = ($LocalizedData.AddItemtoArchiveFile -f $currentFilePath)
                                }
                            } finally {
                                If ($null -ne $currentFileStream) {
                                    $currentFileStream.Dispose()
                                }
                                If ($null -ne $srcStream) {
                                    $srcStream.Dispose()
                                }
                                If ($null -ne $destStream) {
                                    $destStream.Dispose()
                                }
                            }
                        } else {
                            $currentArchiveEntry = $zipArchive.CreateEntry("$relativeFilePath", $compression)
                            $numberOfItemsArchived += 1
                            $addItemtoArchiveFileMessage = ($LocalizedData.AddItemtoArchiveFile -f $currentFilePath)
                        }

                        if ($null -ne $addItemtoArchiveFileMessage) {
                            Write-Verbose $addItemtoArchiveFileMessage
                        }

                        $currentEntryCount += 1
                        ProgressBarHelper "Compress-Archive" $progressBarStatus $previousSegmentWeight $currentSegmentWeight $sourcePaths.Count  $currentEntryCount
                    }
                } finally {
                    If ($null -ne $zipArchive) {
                        $zipArchive.Dispose()
                    }

                    If ($null -ne $archiveFileStream) {
                        $archiveFileStream.Dispose()
                    }

                    # Complete writing progress.
                    Write-Progress -Activity "Compress-Archive" -Completed
                }

                return $numberOfItemsArchived
            }

            <############################################################################################
# ValidateArchivePathHelper: This is a helper function used to validate the archive file
# path & its file format. The only supported archive file format is .zip
############################################################################################>
            function ValidateArchivePathHelper {
                param
                (
                    [string]
                    $archiveFile
                )

                if ([System.IO.File]::Exists($archiveFile)) {
                    $extension = [system.IO.Path]::GetExtension($archiveFile)

                    # Invalid file extension is specifed for the zip file.
                    if ($extension -ne $zipFileExtension) {
                        $errorMessage = ($LocalizedData.InvalidZipFileExtensionError -f $extension, $zipFileExtension)
                        ThrowTerminatingErrorHelper "NotSupportedArchiveFileExtension" $errorMessage ([System.Management.Automation.ErrorCategory]::InvalidArgument) $extension
                    }
                } else {
                    $errorMessage = ($LocalizedData.PathNotFoundError -f $archiveFile)
                    ThrowTerminatingErrorHelper "PathNotFound" $errorMessage ([System.Management.Automation.ErrorCategory]::InvalidArgument) $archiveFile
                }
            }

            <############################################################################################
# ExpandArchiveHelper: This is a helper function used to expand the archive file contents
# to the specified directory.
############################################################################################>
            function ExpandArchiveHelper {
                param
                (
                    [string]
                    $archiveFile,

                    [string]
                    $expandedDir,

                    [ref]
                    $expandedItems,

                    [boolean]
                    $force,

                    [boolean]
                    $isVerbose,

                    [boolean]
                    $isConfirm
                )

                Add-CompressionAssemblies

                try {
                    # The existance of archive file has already been validated by ValidateArchivePathHelper
                    # before calling this helper function.
                    $archiveFileStreamArgs = @($archiveFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
                    $archiveFileStream = New-Object -TypeName System.IO.FileStream -ArgumentList $archiveFileStreamArgs

                    $zipArchiveArgs = @($archiveFileStream, [System.IO.Compression.ZipArchiveMode]::Read, $false)
                    $zipArchive = New-Object -TypeName System.IO.Compression.ZipArchive -ArgumentList $zipArchiveArgs

                    if ($zipArchive.Entries.Count -eq 0) {
                        $archiveFileIsEmpty = ($LocalizedData.ArchiveFileIsEmpty -f $archiveFile)
                        Write-Verbose $archiveFileIsEmpty
                        return
                    }

                    $currentEntryCount = 0
                    $progressBarStatus = ($LocalizedData.ExpandProgressBarText -f $archiveFile)

                    # The archive entries can either be empty directories or files.
                    foreach ($currentArchiveEntry in $zipArchive.Entries) {
                        $currentArchiveEntryPath = Join-Path -Path $expandedDir -ChildPath $currentArchiveEntry.FullName
                        $extension = [system.IO.Path]::GetExtension($currentArchiveEntryPath)

                        # The current archive entry is an empty directory
                        # The FullName of the Archive Entry representing a directory would end with a trailing '\'.
                        if ($extension -eq [string]::Empty -and
                            $currentArchiveEntryPath.EndsWith("\", [StringComparison]::OrdinalIgnoreCase)) {
                            $pathExists = Test-Path -LiteralPath $currentArchiveEntryPath

                            # The current archive entry expects an empty directory.
                            # Check if the existing directory is empty. If its not empty
                            # then it means that user has added this directory by other means.
                            if ($pathExists -eq $false) {
                                New-Item $currentArchiveEntryPath -ItemType Directory -Confirm:$isConfirm | Out-Null

                                if (Test-Path -LiteralPath $currentArchiveEntryPath -PathType Container) {
                                    $addEmptyDirectorytoExpandedPathMessage = ($LocalizedData.AddItemtoArchiveFile -f $currentArchiveEntryPath)
                                    Write-Verbose $addEmptyDirectorytoExpandedPathMessage

                                    $expandedItems.Value += $currentArchiveEntryPath
                                }
                            }
                        } else {
                            try {
                                $currentArchiveEntryFileInfo = New-Object -TypeName System.IO.FileInfo -ArgumentList $currentArchiveEntryPath
                                $parentDirExists = Test-Path -LiteralPath $currentArchiveEntryFileInfo.DirectoryName -PathType Container

                                # If the Parent directory of the current entry in the archive file does not exist, then create it.
                                if ($parentDirExists -eq $false) {
                                    New-Item $currentArchiveEntryFileInfo.DirectoryName -ItemType Directory -Confirm:$isConfirm | Out-Null

                                    if (!(Test-Path -LiteralPath $currentArchiveEntryFileInfo.DirectoryName -PathType Container)) {
                                        # The directory referred by $currentArchiveEntryFileInfo.DirectoryName was not successfully created.
                                        # This could be because the user has specified -Confirm paramter when Expand-Archive was invoked
                                        # and authorization was not provided when confirmation was prompted. In such a scenario,
                                        # we skip the current file in the archive and continue with the remaining archive file contents.
                                        Continue
                                    }

                                    $expandedItems.Value += $currentArchiveEntryFileInfo.DirectoryName
                                }

                                $hasNonTerminatingError = $false

                                # Check if the file in to which the current archive entry contents
                                # would be expanded already exists.
                                if ($currentArchiveEntryFileInfo.Exists) {
                                    if ($force) {
                                        Remove-Item -LiteralPath $currentArchiveEntryFileInfo.FullName -Force -ErrorVariable ev -Verbose:$isVerbose -Confirm:$isConfirm
                                        if ($ev -ne $null) {
                                            $hasNonTerminatingError = $true
                                        }

                                        if (Test-Path -LiteralPath $currentArchiveEntryFileInfo.FullName -PathType Leaf) {
                                            # The file referred by $currentArchiveEntryFileInfo.FullName was not successfully removed.
                                            # This could be because the user has specified -Confirm paramter when Expand-Archive was invoked
                                            # and authorization was not provided when confirmation was prompted. In such a scenario,
                                            # we skip the current file in the archive and continue with the remaining archive file contents.
                                            Continue
                                        }
                                    } else {
                                        # Write non-terminating error to the pipeline.
                                        $errorMessage = ($LocalizedData.FileExistsError -f $currentArchiveEntryFileInfo.FullName, $archiveFile, $currentArchiveEntryFileInfo.FullName, $currentArchiveEntryFileInfo.FullName)
                                        $errorRecord = CreateErrorRecordHelper "ExpandArchiveFileExists" $errorMessage ([System.Management.Automation.ErrorCategory]::InvalidOperation) $null $currentArchiveEntryFileInfo.FullName
                                        Write-Error -ErrorRecord $errorRecord
                                        $hasNonTerminatingError = $true
                                    }
                                }

                                if (!$hasNonTerminatingError) {
                                    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($currentArchiveEntry, $currentArchiveEntryPath, $false)

                                    # Add the expanded file path to the $expandedItems array,
                                    # to keep track of all the expanded files created while expanding the archive file.
                                    # If user enters CTRL + C then at that point of time, all these expanded files
                                    # would be deleted as part of the clean up process.
                                    $expandedItems.Value += $currentArchiveEntryPath

                                    $addFiletoExpandedPathMessage = ($LocalizedData.CreateFileAtExpandedPath -f $currentArchiveEntryPath)
                                    Write-Verbose $addFiletoExpandedPathMessage
                                }
                            } finally {
                                If ($null -ne $destStream) {
                                    $destStream.Dispose()
                                }

                                If ($null -ne $srcStream) {
                                    $srcStream.Dispose()
                                }
                            }
                        }

                        $currentEntryCount += 1
                        # $currentSegmentWeight is Set to 100 giving equal weightage to each file that is getting expanded.
                        # $previousSegmentWeight is set to 0 as there are no prior segments.
                        $previousSegmentWeight = 0
                        $currentSegmentWeight = 100
                        ProgressBarHelper "Expand-Archive" $progressBarStatus $previousSegmentWeight $currentSegmentWeight $zipArchive.Entries.Count  $currentEntryCount
                    }
                } finally {
                    If ($null -ne $zipArchive) {
                        $zipArchive.Dispose()
                    }

                    If ($null -ne $archiveFileStream) {
                        $archiveFileStream.Dispose()
                    }

                    # Complete writing progress.
                    Write-Progress -Activity "Expand-Archive" -Completed
                }
            }

            <############################################################################################
# ProgressBarHelper: This is a helper function used to display progress message.
# This function is used by both Compress-Archive & Expand-Archive to display archive file
# creation/expansion progress.
############################################################################################>
            function ProgressBarHelper {
                param
                (
                    [string]
                    $cmdletName,

                    [string]
                    $status,

                    [double]
                    $previousSegmentWeight,

                    [double]
                    $currentSegmentWeight,

                    [int]
                    $totalNumberofEntries,

                    [int]
                    $currentEntryCount
                )

                if ($currentEntryCount -gt 0 -and
                    $totalNumberofEntries -gt 0 -and
                    $previousSegmentWeight -ge 0 -and
                    $currentSegmentWeight -gt 0) {
                    $entryDefaultWeight = $currentSegmentWeight / [double]$totalNumberofEntries

                    $percentComplete = $previousSegmentWeight + ($entryDefaultWeight * $currentEntryCount)
                    Write-Progress -Activity $cmdletName -Status $status -PercentComplete $percentComplete
                }
            }

            <############################################################################################
# CSVHelper: This is a helper function used to append comma after each path specifid by
# the SourcePath array. This helper function is used to display all the user supplied paths
# in the WhatIf message.
############################################################################################>
            function CSVHelper {
                param
                (
                    [string[]]
                    $sourcePath
                )

                # SourcePath has already been validated by the calling funcation.
                if ($sourcePath.Count -gt 1) {
                    $sourcePathInCsvFormat = "`n"
                    for ($currentIndex = 0; $currentIndex -lt $sourcePath.Count; $currentIndex++) {
                        if ($currentIndex -eq $sourcePath.Count - 1) {
                            $sourcePathInCsvFormat += $sourcePath[$currentIndex]
                        } else {
                            $sourcePathInCsvFormat += $sourcePath[$currentIndex] + "`n"
                        }
                    }
                } else {
                    $sourcePathInCsvFormat = $sourcePath
                }

                return $sourcePathInCsvFormat
            }

            <############################################################################################
# ThrowTerminatingErrorHelper: This is a helper function used to throw terminating error.
############################################################################################>
            function ThrowTerminatingErrorHelper {
                param
                (
                    [string]
                    $errorId,

                    [string]
                    $errorMessage,

                    [System.Management.Automation.ErrorCategory]
                    $errorCategory,

                    [object]
                    $targetObject,

                    [Exception]
                    $innerException
                )

                if ($innerException -eq $null) {
                    $exception = New-object System.IO.IOException $errorMessage
                } else {
                    $exception = New-Object System.IO.IOException $errorMessage, $innerException
                }

                $exception = New-Object System.IO.IOException $errorMessage
                $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $targetObject
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            <############################################################################################
# CreateErrorRecordHelper: This is a helper function used to create an ErrorRecord
############################################################################################>
            function CreateErrorRecordHelper {
                param
                (
                    [string]
                    $errorId,

                    [string]
                    $errorMessage,

                    [System.Management.Automation.ErrorCategory]
                    $errorCategory,

                    [Exception]
                    $exception,

                    [object]
                    $targetObject
                )

                if ($null -eq $exception) {
                    $exception = New-Object System.IO.IOException $errorMessage
                }

                $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $targetObject
                return $errorRecord
            }
            #endregion Utility Functions

            $isVerbose = $psboundparameters.ContainsKey("Verbose")
            $isConfirm = $psboundparameters.ContainsKey("Confirm")

            $isDestinationPathProvided = $true
            if ($DestinationPath -eq [string]::Empty) {
                $resolvedDestinationPath = $pwd
                $isDestinationPathProvided = $false
            } else {
                $destinationPathExists = Test-Path -Path $DestinationPath -PathType Container
                if ($destinationPathExists) {
                    $resolvedDestinationPath = GetResolvedPathHelper $DestinationPath $false $PSCmdlet
                    if ($resolvedDestinationPath.Count -gt 1) {
                        $errorMessage = ($LocalizedData.InvalidExpandedDirPathError -f $DestinationPath)
                        ThrowTerminatingErrorHelper "InvalidDestinationPath" $errorMessage ([System.Management.Automation.ErrorCategory]::InvalidArgument) $DestinationPath
                    }

                    # At this point we are sure that the provided path resolves to a valid single path.
                    # Calling Resolve-Path again to get the underlying provider name.
                    $suppliedDestinationPath = Resolve-Path -Path $DestinationPath
                    if ($suppliedDestinationPath.Provider.Name -ne "FileSystem") {
                        $errorMessage = ($LocalizedData.ExpandArchiveInValidDestinationPath -f $DestinationPath)
                        ThrowTerminatingErrorHelper "InvalidDirectoryPath" $errorMessage ([System.Management.Automation.ErrorCategory]::InvalidArgument) $DestinationPath
                    }
                } else {
                    $createdItem = New-Item -Path $DestinationPath -ItemType Directory -Confirm:$isConfirm -Verbose:$isVerbose -ErrorAction Stop
                    if ($createdItem -ne $null -and $createdItem.PSProvider.Name -ne "FileSystem") {
                        Remove-Item "$DestinationPath" -Force -Recurse -ErrorAction SilentlyContinue
                        $errorMessage = ($LocalizedData.ExpandArchiveInValidDestinationPath -f $DestinationPath)
                        ThrowTerminatingErrorHelper "InvalidDirectoryPath" $errorMessage ([System.Management.Automation.ErrorCategory]::InvalidArgument) $DestinationPath
                    }

                    $resolvedDestinationPath = GetResolvedPathHelper $DestinationPath $true $PSCmdlet
                }
            }

            $isWhatIf = $psboundparameters.ContainsKey("WhatIf")
            if (!$isWhatIf) {
                $preparingToExpandVerboseMessage = ($LocalizedData.PreparingToExpandVerboseMessage)
                Write-Verbose $preparingToExpandVerboseMessage

                $progressBarStatus = ($LocalizedData.ExpandProgressBarText -f $DestinationPath)
                ProgressBarHelper "Expand-Archive" $progressBarStatus 0 100 100 1
            }
        }
        PROCESS {
            switch ($PsCmdlet.ParameterSetName) {
                "Path" {
                    $resolvedSourcePaths = GetResolvedPathHelper $Path $false $PSCmdlet

                    if ($resolvedSourcePaths.Count -gt 1) {
                        $errorMessage = ($LocalizedData.InvalidArchiveFilePathError -f $Path, $PsCmdlet.ParameterSetName, $PsCmdlet.ParameterSetName)
                        ThrowTerminatingErrorHelper "InvalidArchiveFilePath" $errorMessage ([System.Management.Automation.ErrorCategory]::InvalidArgument) $Path
                    }
                }
                "LiteralPath" {
                    $resolvedSourcePaths = GetResolvedPathHelper $LiteralPath $true $PSCmdlet

                    if ($resolvedSourcePaths.Count -gt 1) {
                        $errorMessage = ($LocalizedData.InvalidArchiveFilePathError -f $LiteralPath, $PsCmdlet.ParameterSetName, $PsCmdlet.ParameterSetName)
                        ThrowTerminatingErrorHelper "InvalidArchiveFilePath" $errorMessage ([System.Management.Automation.ErrorCategory]::InvalidArgument) $LiteralPath
                    }
                }
            }

            ValidateArchivePathHelper $resolvedSourcePaths

            if ($pscmdlet.ShouldProcess($resolvedSourcePaths)) {
                $expandedItems = @()

                try {
                    # StopProcessing is not avaliable in Script cmdlets. However the pipleline execution
                    # is terminated when ever 'CTRL + C' is entered by user to terminate the cmdlet execution.
                    # The finally block is executed whenever pipleline is terminated.
                    # $isArchiveFileProcessingComplete variable is used to track if 'CTRL + C' is entered by the
                    # user.
                    $isArchiveFileProcessingComplete = $false

                    # The User has not provided a destination path, hence we use '$pwd\ArchiveFileName' as the directory where the
                    # archive file contents would be expanded. If the path '$pwd\ArchiveFileName' already exists then we use the
                    # Windows default mechanism of appending a counter value at the end of the directory name where the contents
                    # would be expanded.
                    if (!$isDestinationPathProvided) {
                        $archiveFile = New-Object System.IO.FileInfo $resolvedSourcePaths
                        $resolvedDestinationPath = Join-Path -Path $resolvedDestinationPath -ChildPath $archiveFile.BaseName
                        $destinationPathExists = Test-Path -LiteralPath $resolvedDestinationPath -PathType Container

                        if (!$destinationPathExists) {
                            New-Item -Path $resolvedDestinationPath -ItemType Directory -Confirm:$isConfirm -Verbose:$isVerbose -ErrorAction Stop | Out-Null
                        }
                    }

                    ExpandArchiveHelper $resolvedSourcePaths $resolvedDestinationPath ([ref]$expandedItems) $Force $isVerbose $isConfirm

                    $isArchiveFileProcessingComplete = $true
                } finally {
                    # The $isArchiveFileProcessingComplete would be set to $false if user has typed 'CTRL + C' to
                    # terminate the cmdlet execution or if an unhandled exception is thrown.
                    if ($isArchiveFileProcessingComplete -eq $false) {
                        if ($expandedItems.Count -gt 0) {
                            # delete the expanded file/directory as the archive
                            # file was not completly expanded.
                            $expandedItems | ForEach-Object { Remove-Item $_ -Force -Recurse }
                        }
                    }
                }
            }
        }
    }
}
# SIG # Begin signature block
# MIIcYgYJKoZIhvcNAQcCoIIcUzCCHE8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUH9y4h2FIFqvSiMiYUG0Bt2oI
# Wu2ggheRMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE3MDUwOTAwMDAwMFoXDTIwMDUx
# MzEyMDAwMFowVzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMQ8wDQYD
# VQQHEwZWaWVubmExETAPBgNVBAoTCGRiYXRvb2xzMREwDwYDVQQDEwhkYmF0b29s
# czCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAI8ng7JxnekL0AO4qQgt
# Kr6p3q3SNOPh+SUZH+SyY8EA2I3wR7BMoT7rnZNolTwGjUXn7bRC6vISWg16N202
# 1RBWdTGW2rVPBVLF4HA46jle4hcpEVquXdj3yGYa99ko1w2FOWzLjKvtLqj4tzOh
# K7wa/Gbmv0Si/FU6oOmctzYMI0QXtEG7lR1HsJT5kywwmgcjyuiN28iBIhT6man0
# Ib6xKDv40PblKq5c9AFVldXUGVeBJbLhcEAA1nSPSLGdc7j4J2SulGISYY7ocuX3
# tkv01te72Mv2KkqqpfkLEAQjXgtM0hlgwuc8/A4if+I0YtboCMkVQuwBpbR9/6ys
# Z+sCAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5Y
# MB0GA1UdDgQWBBRcxSkFqeA3vvHU0aq2mVpFRSOdmjAOBgNVHQ8BAf8EBAMCB4Aw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0
# dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwG
# A1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZC
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJ
# RENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQAD
# ggEBANuBGTbzCRhgG0Th09J0m/qDqohWMx6ZOFKhMoKl8f/l6IwyDrkG48JBkWOA
# QYXNAzvp3Ro7aGCNJKRAOcIjNKYef/PFRfFQvMe07nQIj78G8x0q44ZpOVCp9uVj
# sLmIvsmF1dcYhOWs9BOG/Zp9augJUtlYpo4JW+iuZHCqjhKzIc74rEEiZd0hSm8M
# asshvBUSB9e8do/7RhaKezvlciDaFBQvg5s0fICsEhULBRhoyVOiUKUcemprPiTD
# xh3buBLuN0bBayjWmOMlkG1Z6i8DUvWlPGz9jiBT3ONBqxXfghXLL6n8PhfppBhn
# daPQO8+SqF5rqrlyBPmRRaTz2GQwggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7Vv
# lVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEw
# MjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx
# 6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEj
# lpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJN
# YBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2
# DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9
# hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNV
# HRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAo
# BggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgB
# hv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi
# 0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6l
# jlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0k
# riTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/P
# QMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d
# 9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJm
# oecYpJpkUe8wggZqMIIFUqADAgECAhADAZoCOv9YsWvW1ermF/BmMA0GCSqGSIb3
# DQEBBQUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAX
# BgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3Vy
# ZWQgSUQgQ0EtMTAeFw0xNDEwMjIwMDAwMDBaFw0yNDEwMjIwMDAwMDBaMEcxCzAJ
# BgNVBAYTAlVTMREwDwYDVQQKEwhEaWdpQ2VydDElMCMGA1UEAxMcRGlnaUNlcnQg
# VGltZXN0YW1wIFJlc3BvbmRlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAKNkXfx8s+CCNeDg9sYq5kl1O8xu4FOpnx9kWeZ8a39rjJ1V+JLjntVaY1sC
# SVDZg85vZu7dy4XpX6X51Id0iEQ7Gcnl9ZGfxhQ5rCTqqEsskYnMXij0ZLZQt/US
# s3OWCmejvmGfrvP9Enh1DqZbFP1FI46GRFV9GIYFjFWHeUhG98oOjafeTl/iqLYt
# WQJhiGFyGGi5uHzu5uc0LzF3gTAfuzYBje8n4/ea8EwxZI3j6/oZh6h+z+yMDDZb
# esF6uHjHyQYuRhDIjegEYNu8c3T6Ttj+qkDxss5wRoPp2kChWTrZFQlXmVYwk/PJ
# YczQCMxr7GJCkawCwO+k8IkRj3cCAwEAAaOCAzUwggMxMA4GA1UdDwEB/wQEAwIH
# gDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMIIBvwYDVR0g
# BIIBtjCCAbIwggGhBglghkgBhv1sBwEwggGSMCgGCCsGAQUFBwIBFhxodHRwczov
# L3d3dy5kaWdpY2VydC5jb20vQ1BTMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4A
# eQAgAHUAcwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQA
# ZQAgAGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUA
# IABvAGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAA
# YQBuAGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcA
# cgBlAGUAbQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIA
# aQBsAGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQA
# ZQBkACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMAsG
# CWCGSAGG/WwDFTAfBgNVHSMEGDAWgBQVABIrE5iymQftHt+ivlcNK2cCzTAdBgNV
# HQ4EFgQUYVpNJLZJMp1KKnkag0v0HonByn0wfQYDVR0fBHYwdDA4oDagNIYyaHR0
# cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcmww
# OKA2oDSGMmh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJ
# RENBLTEuY3JsMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURDQS0xLmNydDANBgkqhkiG9w0BAQUF
# AAOCAQEAnSV+GzNNsiaBXJuGziMgD4CH5Yj//7HUaiwx7ToXGXEXzakbvFoWOQCd
# 42yE5FpA+94GAYw3+puxnSR+/iCkV61bt5qwYCbqaVchXTQvH3Gwg5QZBWs1kBCg
# e5fH9j/n4hFBpr1i2fAnPTgdKG86Ugnw7HBi02JLsOBzppLA044x2C/jbRcTBu7k
# A7YUq/OPQ6dxnSHdFMoVXZJB2vkPgdGZdA0mxA5/G7X1oPHGdwYoFenYk+VVFvC7
# Cqsc21xIJ2bIo4sKHOWV2q7ELlmgYd3a822iYemKC23sEhi991VUQAOSK2vCUcIK
# SK+w1G7g9BQKOhvjjz3Kr2qNe9zYRDCCBs0wggW1oAMCAQICEAb9+QOWA63qAArr
# Pye7uhswDQYJKoZIhvcNAQEFBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERp
# Z2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMb
# RGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTA2MTExMDAwMDAwMFoXDTIx
# MTExMDAwMDAwMFowYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IElu
# YzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQg
# QXNzdXJlZCBJRCBDQS0xMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# 6IItmfnKwkKVpYBzQHDSnlZUXKnE0kEGj8kz/E1FkVyBn+0snPgWWd+etSQVwpi5
# tHdJ3InECtqvy15r7a2wcTHrzzpADEZNk+yLejYIA6sMNP4YSYL+x8cxSIB8HqIP
# kg5QycaH6zY/2DDD/6b3+6LNb3Mj/qxWBZDwMiEWicZwiPkFl32jx0PdAug7Pe2x
# QaPtP77blUjE7h6z8rwMK5nQxl0SQoHhg26Ccz8mSxSQrllmCsSNvtLOBq6thG9I
# hJtPQLnxTPKvmPv2zkBdXPao8S+v7Iki8msYZbHBc63X8djPHgp0XEK4aH631XcK
# J1Z8D2KkPzIUYJX9BwSiCQIDAQABo4IDejCCA3YwDgYDVR0PAQH/BAQDAgGGMDsG
# A1UdJQQ0MDIGCCsGAQUFBwMBBggrBgEFBQcDAgYIKwYBBQUHAwMGCCsGAQUFBwME
# BggrBgEFBQcDCDCCAdIGA1UdIASCAckwggHFMIIBtAYKYIZIAYb9bAABBDCCAaQw
# OgYIKwYBBQUHAgEWLmh0dHA6Ly93d3cuZGlnaWNlcnQuY29tL3NzbC1jcHMtcmVw
# b3NpdG9yeS5odG0wggFkBggrBgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBzAGUA
# IABvAGYAIAB0AGgAaQBzACAAQwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBvAG4A
# cwB0AGkAdAB1AHQAZQBzACAAYQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAgAHQA
# aABlACAARABpAGcAaQBDAGUAcgB0ACAAQwBQAC8AQwBQAFMAIABhAG4AZAAgAHQA
# aABlACAAUgBlAGwAeQBpAG4AZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBtAGUA
# bgB0ACAAdwBoAGkAYwBoACAAbABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0AHkA
# IABhAG4AZAAgAGEAcgBlACAAaQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABoAGUA
# cgBlAGkAbgAgAGIAeQAgAHIAZQBmAGUAcgBlAG4AYwBlAC4wCwYJYIZIAYb9bAMV
# MBIGA1UdEwEB/wQIMAYBAf8CAQAweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzAB
# hhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9j
# YWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQw
# gYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwHQYDVR0OBBYEFBUA
# EisTmLKZB+0e36K+Vw0rZwLNMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3z
# bcgPMA0GCSqGSIb3DQEBBQUAA4IBAQBGUD7Jtygkpzgdtlspr1LPUukxR6tWXHvV
# DQtBs+/sdR90OPKyXGGinJXDUOSCuSPRujqGcq04eKx1XRcXNHJHhZRW0eu7NoR3
# zCSl8wQZVann4+erYs37iy2QwsDStZS9Xk+xBdIOPRqpFFumhjFiqKgz5Js5p8T1
# zh14dpQlc+Qqq8+cdkvtX8JLFuRLcEwAiR78xXm8TBJX/l/hHrwCXaj++wc4Tw3G
# XZG5D2dFzdaD7eeSDY2xaYxP+1ngIw/Sqq4AfO6cQg7PkdcntxbuD8O9fAqg7iwI
# VYUiuOsYGk38KiGtSTGDR5V3cdyxG0tLHBCcdxTBnU8vWpUIKRAmMYIEOzCCBDcC
# AQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcG
# A1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBB
# c3N1cmVkIElEIENvZGUgU2lnbmluZyBDQQIQAsF1KHTVwoQxhSrYoGRpyjAJBgUr
# DgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
# hkiG9w0BCQQxFgQUNK7i93hwKc7EgcilP3wO3tHpSggwDQYJKoZIhvcNAQEBBQAE
# ggEAGxLMRmtNjEH+3Mp6HRSUiw9xS1CXRljzN6hlLaCq7ri9sw9+4TrZRE69G4Dv
# +mWqQy1mJN2VRqDRITaye1bsMeMJHSKpW4pUdDj5mPdsjjSG4GQt+i9VaWN/oJnF
# ktZ5wvydiOnd9AoCLRUza2nMbT2auWgezLScrzbR03lV7S1ckLL2CwSSoSYoHYns
# Ib29UnqHk8S/nzMdQ4l4i7utbZKsPf4mGq7B0DQPGYSIcx1WP3IehjL+puei0KOc
# kC4x5KpbNXBcojWak8EVmBBUVY+9phH6Dx85i9H0/SL3dSjkWLB2T9UjprX/4hBO
# wU8ghgoG8JS8V16UA0xThjfC9KGCAg8wggILBgkqhkiG9w0BCQYxggH8MIIB+AIB
# ATB2MGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3VyZWQg
# SUQgQ0EtMQIQAwGaAjr/WLFr1tXq5hfwZjAJBgUrDgMCGgUAoF0wGAYJKoZIhvcN
# AQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjAwMzAzMTA0NTE0WjAj
# BgkqhkiG9w0BCQQxFgQUA3NkqBln9pTv2PJ10AZTCdK5locwDQYJKoZIhvcNAQEB
# BQAEggEATjAB3UaXDE9Da9+tyrFczSSmv4R7X2rhGA4dceBNwhKDdtZ2NdojdS77
# 58u1ofRo1QiaDWuDRehIqF9vfqgzR85/oqQ80ObUwNcotuRMHtDE2vgYxVReLRTq
# n3vb6fA7SmWHkx5dU/i1kb82bZHYFC+h9nxDKI4B1z27ZmNtDQG3Nt1l7hN/+J2b
# dUc3X006YRlOu8tQPcIapvLRjHUq0smAQoCmpy9nNDBCH1C2yv/VjjDV3epezvcg
# XwRThvALuTqkCWffjFyv0KGsu35ZsWx32pQGkdHYIf6b6z1F0u27E2D8mCYG36T7
# WCHTymYrOOvloFkHe9GwWVjmsOt2Lg==
# SIG # End signature block
