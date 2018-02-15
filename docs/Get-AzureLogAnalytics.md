---
external help file: UMN-Azure-help.xml
Module Name: UMN-Azure
online version: 
schema: 2.0.0
---

# Get-AzureLogAnalytics

## SYNOPSIS
Query Azure Log Analytics

## SYNTAX

```
Get-AzureLogAnalytics [-workspaceID] <String> [-accessToken] <String> [-query] <String>
```

## DESCRIPTION
Requires having identity set in Azure AD to allow access to Log Analytics API, and an Azure AD Application registered to get an API OAuth token from.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
-accessToken $accessToken -query $query
```

## PARAMETERS

### -workspaceID
The workspaceID reference for this API is the subscription which has the Log Analytics account.

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
A valid Log Analytics query.
Example = 'AzureDiagnostics | where ResultType == "Failed" | where RunbookName_s == "Name of runbook" |where TimeGenerated \> ago(1h)'

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

## INPUTS

## OUTPUTS

## NOTES
Author: Kyle Weeks

## RELATED LINKS

