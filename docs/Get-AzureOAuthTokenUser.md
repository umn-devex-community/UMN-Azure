---
external help file: UMN-Azure-help.xml
Module Name: umn-azure
online version:
schema: 2.0.0
---

# Get-AzureOAuthTokenUser

## SYNOPSIS
Get Valid OAuth Token. 
The access token is good for an hour, the refresh token is mostly permanent and can be used to get a new access token without having to re-authenticate

## SYNTAX

```
Get-AzureOAuthTokenUser [-tenantID] <String> [-clientid] <String> [-accessKey] <String> [-redirectUri] <String>
 [-resource] <Object> [[-prompt] <String>] [[-refreshtoken] <String>] [<CommonParameters>]
```

## DESCRIPTION
This is based on authenticating against a custom Web/API Application registered in Azure AD which has permissions to Azure AD, Azure Management, and other APIs.

## EXAMPLES

### EXAMPLE 1
```
$tokenInfo = Get-AzureOAuthTokenUser -tenantID 'Azure AD Tenant ID' -clientid 'Application ID' -accessKey 'Preset key for app' -redirectUri 'https redirect uri of app' -resource 'MS API Resource'
```

### EXAMPLE 2
```
$tokenInfo = Get-AzureOAuthTokenUser -tenantID 'Azure AD Tenant ID' -clientid 'Application ID' -accessKey 'Preset key for app' -redirectUri 'https redirect uri of app' -resource 'MS API Resource' -refreshtoken 'your refresh token from a previous call'
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

### -redirectUri
For return stream of claims

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

### -resource
Resource to be interacted with.
Example = https://api.loganalytics.io, or https://graph.microsoft.com

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -prompt
Define if your app login should prompt the user for consent in the Azure portal on login.
none = will never request and rely on SSO (web apps)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Consent
Accept pipeline input: False
Accept wildcard characters: False
```

### -refreshtoken
Supply a refresh token to get a new valid token for use after expiring

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Array

## NOTES
Author: Kyle Weeks

## RELATED LINKS
