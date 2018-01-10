---
external help file: UMN-Azure-help.xml
Module Name: UMN-Azure
online version: 
schema: 2.0.0
---

# Get-AzureMarketplaceCharges

## SYNOPSIS
Get azure marketplace usage

## SYNTAX

```
Get-AzureMarketplaceCharges [-enrollment] <String> [-key] <String> [[-billingPeriodID] <String>]
 [[-startDate] <String>] [[-endDate] <String>] [<CommonParameters>]
```

## DESCRIPTION
For getting marketplace usage data.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$result = Get-AzureMarketplaceCharges -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber'
```

### -------------------------- EXAMPLE 2 --------------------------
```
$result = Get-AzureMarketplaceCharges -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -billingPeriodID '201701'
```

### -------------------------- EXAMPLE 3 --------------------------
```
$result = Get-AzureMarketplaceCharges -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -startDate '20170515' -endDate '20170602'
```

## PARAMETERS

### -enrollment
Your Enterprise Enrollment number.
Available form the EA portal.

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

### -key
API key gathered from the EA portal for use with billing API.

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

### -billingPeriodID
An optional parameter to specify that you wish to get from the following year and month.
Format YYYYMM

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

### -startDate
Start date time of the query - ####-##-## year, month, day = 2017-01-28

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

### -endDate
End date time of the query - ####-##-## year, month, day = 2017-01-28

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

