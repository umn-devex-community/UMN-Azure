---
external help file: UMN-Azure-help.xml
Module Name: umn-azure
online version:
schema: 2.0.0
---

# New-OneDriveLargeFileUpload

## SYNOPSIS
Upload large files to OneDrive

## SYNTAX

```
New-OneDriveLargeFileUpload [[-chunkSize] <Int32>] [-LocalFilePath] <String> [-uploadURL] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Will break down a large file into chunks for upload to OneDrive for Business account.
Requires prep work for administrative control.

## EXAMPLES

### EXAMPLE 1
```
New-OneDriveLargeFileUpload -localFilePath c:\temp\aVeryLargeFile.vhd -uploadURL $uploadURL
```

## PARAMETERS

### -chunkSize
The byte chunk size to break the file into.
Has to be a multiple of 327680 or OneDrive API will reject.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 4915200
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalFilePath
Path to the local file to be uploaded.
Include the file name with extension.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -uploadURL
The upload URL provided from the upload session request.
See New-AzureOneDriveLargeFileSession call to retrieve.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Kyle Weeks

## RELATED LINKS
