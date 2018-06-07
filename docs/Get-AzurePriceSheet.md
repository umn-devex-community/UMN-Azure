---
external help file: UMN-Azure-help.xml
Module Name: umn-azure
online version:
schema: 2.0.0
---

# Get-AzurePriceSheet

## SYNOPSIS
Get current price sheet from enterprise portal

## SYNTAX

```
Get-AzurePriceSheet [-key] <String> [-enrollment] <String> [[-billingPeriodID] <String>] [<CommonParameters>]
```

## DESCRIPTION
Use this call to get a price sheet of resources from the EA portal using an API key

## EXAMPLES

### EXAMPLE 1
```
$result = Get-AzurePriceSheet -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber'
```

### EXAMPLE 2
```
$result = Get-AzurePriceSheet -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -billingPeriodID '201701'
```

## PARAMETERS

### -key
API key gathered from the EA portal for use with billing API.

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

### -enrollment
Your Enterprise Enrollment number.
Available form the EA portal.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Kyle Weeks

## RELATED LINKS
