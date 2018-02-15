---
external help file: UMN-Azure-help.xml
Module Name: UMN-Azure
online version: 
schema: 2.0.0
---

# Get-AzureOAuthTokenService

## SYNOPSIS
Get Valid OAuth Token. 
The access token is good for an hour, and there is no refresh token.

## SYNTAX

```
Get-AzureOAuthTokenService [-tenantID] <String> [-clientid] <String> [-accessKey] <String> [-resource] <Object>
```

## DESCRIPTION
This OAuth token is intended for use with CLI, automation, and service calls.
No user interaction is required.
Requires an application to be registered in Azure AD with appropriate API permissions configured.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$tokenInfo = Get-AzureOAuthTokenService -tenantID 'Azure AD Tenant ID' -clientid 'Application ID' -accessKey 'Preset key for app' -resource 'MS API Resource'
```

## PARAMETERS

### -tenantID
Azure AD Directory ID/TenantID

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

### -clientid
Azure AD Custom Application ID

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

### -accessKey
Azure AD Custom Application access key

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

### -resource
Resource to be interacted with.
Example = https://api.loganalytics.io.
Use the clientID here if authenticating a token to your own custom app.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.Array

## NOTES
Author: Kyle Weeks

## RELATED LINKS

