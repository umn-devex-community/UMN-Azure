---
external help file: UMN-Azure-help.xml
Module Name: umn-azure
online version:
schema: 2.0.0
---

# Get-AzureOneDriveRootContent

## SYNOPSIS
Gets the One Drive Root Content

## SYNTAX

```
Get-AzureOneDriveRootContent [-accessToken] <String> [[-apiVersion] <String>] [-driveID] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Will get all IDs of folders and files at the root of a one Drive with Child item info.

## EXAMPLES

### EXAMPLE 1
```
Get-AzureOneDriveRootContent -accessToken $accessToken -driveID $driveID
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
The drive ID to be queried.

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
