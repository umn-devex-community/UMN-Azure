---
external help file: UMN-Azure-help.xml
Module Name: umn-azure
online version:
schema: 2.0.0
---

# Get-AzureGraphUsers

## SYNOPSIS
Query Azure Graph API for basic user details

## SYNTAX

```
Get-AzureGraphUsers [-userPrincipalNames] <Array> [-accessToken] <String> [[-query] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Requires having identity set in Azure AD to allow access to Graph API, and an Azure AD Application registered to get an API OAuth token from.

## EXAMPLES

### EXAMPLE 1
```
$result = Get-AzureGraphUsers -accessToken $accessToken -userPrincipalName 'jemina@somedomain.onmicrosoft.com' -query
```

## PARAMETERS

### -userPrincipalNames
A valid user userPrincipalName

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -accessToken
An OAuth accessToken.
See Get-AzureOAuthTokenUser as a possible source.

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

### -query
Optional to query specified information about the user object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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
