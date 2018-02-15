---
external help file: UMN-Azure-help.xml
Module Name: UMN-Azure
online version: 
schema: 2.0.0
---

# Get-AzureBillingPeriods

## SYNOPSIS
Get current available billing periods, and some metadata around them.

## SYNTAX

```
Get-AzureBillingPeriods [-key] <String> [-enrollment] <String>
```

## DESCRIPTION
A call to get available billing periods from your EA portal.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$result =  Get-AzureBillingPeriods -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber'
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

## INPUTS

## OUTPUTS

## NOTES
Author: Kyle Weeks

## RELATED LINKS

