---
external help file: UMN-Azure-help.xml
Module Name: umn-azure
online version:
schema: 2.0.0
---

# New-AzureOneDriveLargeFileSession

## SYNOPSIS
Generates a One Drive large file upload session.

## SYNTAX

```
New-AzureOneDriveLargeFileSession [-accessToken] <String> [[-apiVersion] <String>] [-driveID] <String>
 [-OneDriveFilePath] <String> [<CommonParameters>]
```

## DESCRIPTION
Needed in order to upload large files to One Drive via the Graph API.

## EXAMPLES

### EXAMPLE 1
```
New-AzureOneDriveLargeFileSession -accessToken $accessToken -driveID $driveID -oneDriveFilePath $oneDriveFilePath
```

## PARAMETERS

### -accessToken
oAuth Access token with API permissions allowed for One Drive on the https://graph.microsoft.com resource.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -apiVersion
Defaults to 1.0.
Can set for beta or other as they allow.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: V1.0
Accept pipeline input: False
Accept wildcard characters: False
```

### -driveID
The OneDrive ID of the O365 User.
See Get-AzureOneDriveID.

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

### -OneDriveFilePath
The One Drive folder path with file name.
"New Folder/Microsoft.jpg"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
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
