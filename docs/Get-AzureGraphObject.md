---
external help file: UMN-Azure-help.xml
Module Name: umn-azure
online version:
schema: 2.0.0
---

# Get-AzureGraphObject

## SYNOPSIS
Query Azure Graph API for object details

## SYNTAX

```
Get-AzureGraphObject [-accessToken] <String> [[-apiVersion] <String>] [[-batchSize] <Int32>]
 [-objectType] <String> [<CommonParameters>]
```

## DESCRIPTION
Use the $top oData filter to query objects in bulk using paging.

## EXAMPLES

### EXAMPLE 1
```
$results = Get-AzureGraphObject -accessToken $accessToken -objectType ''
```

### EXAMPLE 2
```
$results = Get-AzureGraphObject -accessToken $accessToken -apiVersion 'Beta' -batchSize 500 -objectType ''
```

## PARAMETERS

### -accessToken
An OAuth accessToken.
See Get-AzureOAuthTokenUser as a possible source.

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
Some of the API versions in Graph are 'beta' - default to 1.0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -batchSize
Used to determine how many records to return per page.
Microsoft Graph behaviors are per api...

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 200
Accept pipeline input: False
Accept wildcard characters: False
```

### -objectType
The object type to query.
Paging with the $top filter is supported for all /users, but the $top filter is rejected.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Kyle Weeks

## RELATED LINKS
