---
external help file: UMN-Azure-help.xml
Module Name: umn-azure
online version:
schema: 2.0.0
---

# New-OneDriveFolder

## SYNOPSIS
Creates a new folder

## SYNTAX

```
New-OneDriveFolder [-accessToken] <String> [[-apiVersion] <String>] [-folderName] <String>
 [[-parentID] <String>] [[-root] <Boolean>] [-userPrincipalName] <String> [<CommonParameters>]
```

## DESCRIPTION
Provide a item ID of parent folder or create new folder at root of OneDrive

## EXAMPLES

### EXAMPLE 1
```
New-OneDriveFolder -accessToken $accessToken -folderName 'New Folder' -root $true -userPrincipalName 'moon@domain.edu'
```

### EXAMPLE 2
```
New-OneDriveFolder -accessToken $accessToken -folderName 'New Folder' -parentID $parentID -userPrincipalName 'moon@domain.edu'
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

### -folderName
Name of the new folder

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

### -parentID
Item of the parent folder

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -root
Boolean switch.
If true - no parent ID is needed, and will create folder in root of One Drive.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -userPrincipalName
UserPrincipalName of the OneDrive account owner.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
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
