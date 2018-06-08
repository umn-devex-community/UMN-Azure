---
external help file: UMN-Azure-help.xml
Module Name: umn-azure
online version:
schema: 2.0.0
---

# Get-AzureOneDriveFiles

## SYNOPSIS
Function to query One Drive for files

## SYNTAX

```
Get-AzureOneDriveFiles [-accessToken] <String> [[-apiVersion] <String>] [-driveID] <String> [-itemIDs] <Array>
 [-outPutPath] <String> [[-rootCreated] <String>] [-userPrincipalName] <String> [<CommonParameters>]
```

## DESCRIPTION
Needed in order to upload large files to One Drive via the Graph API.

## EXAMPLES

### EXAMPLE 1
```
Get-AzureOneDriveFiles -accessToken $accessToken -driveID $driveID -itemIDs $arrayOfItemIds -outPutPath c:\temp -rootCreated $False -userPrincipalName 'moon@domain.edu'
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

### -itemIDs
An array of file/folder item IDs to be downloaded.
See Get-AzureOneDriveRootContent as a starting place.

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -outPutPath
Local path to store the files.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -rootCreated
A switch for when looping through from the root of a one drive to gather the entire one drive.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Needed
Accept pipeline input: False
Accept wildcard characters: False
```

### -userPrincipalName
The Azure AD UserPrincipalName of the OneDrive account owner.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
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
