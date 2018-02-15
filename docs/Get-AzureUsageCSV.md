---
external help file: UMN-Azure-help.xml
Module Name: UMN-Azure
online version: 
schema: 2.0.0
---

# Get-AzureUsageCSV

## SYNOPSIS
Get azure usage directly as a CSV (as if downloading from the web UI)

## SYNTAX

```
Get-AzureUsageCSV [-enrollment] <String> [-key] <String> [-billingPeriod] <String> [-outputDir] <String>
```

## DESCRIPTION
There are other options for retrieving usage information.
Directly as a CSV non-polling, polling, or JSON.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$result = Get-AzureUsageCSV -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -billingPeriodID '201701' -outputDir 'c:\'
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

### -billingPeriod
{{Fill billingPeriod Description}}

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

### -outputDir
A directory for outputing a CSV of collected data.

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

## INPUTS

## OUTPUTS

## NOTES
Author: Kyle Weeks

## RELATED LINKS

