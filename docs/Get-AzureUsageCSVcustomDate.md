---
external help file: UMN-Azure-help.xml
Module Name: umn-azure
online version:
schema: 2.0.0
---

# Get-AzureUsageCSVcustomDate

## SYNOPSIS
Get azure usage in a CSV format directly - providing a custom date range

## SYNTAX

```
Get-AzureUsageCSVcustomDate [-enrollment] <String> [-key] <String> [-outputDir] <String> [-startDate] <String>
 [-endDate] <String> [<CommonParameters>]
```

## DESCRIPTION
There are other options for retrieving usage information.
Directly as a CSV non-polling, polling, or JSON.
This method requests a custom data file be generated (up to 36 months of data).
It is saved to a blob storage point.
The function will poll that location until it is available, then output the csv.

## EXAMPLES

### EXAMPLE 1
```
$result = Get-AzureUsageCSV -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -startDate '20170515' -endDate '20170602' -outputDir 'c:\'
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

### -outputDir
{{Fill outputDir Description}}

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

### -startDate
Start date time of the query - ####-##-## year, month, day = 2017-01-28

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

### -endDate
End date time of the query - ####-##-## year, month, day = 2017-01-28

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Kyle Weeks

## RELATED LINKS
