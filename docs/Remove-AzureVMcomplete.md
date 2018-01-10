---
external help file: UMN-Azure-help.xml
Module Name: UMN-Azure
online version: 
schema: 2.0.0
---

# Remove-AzureVMcomplete

## SYNOPSIS
Delete VM

## SYNTAX

```
Remove-AzureVMcomplete [[-ResourceGroupName] <String>] [[-vm] <String>] [[-storageRGname] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Delete a VM and its NIC/PublicIP/osDisk

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$result = Remove-AzureVMcomplete -ResourceGroupName "VPN-GW" -vm "mynewtest"
```

## PARAMETERS

### -ResourceGroupName
The name of the resource group the VM belongs to

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -vm
The name of the VM

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

### -storageRGname
The resource group name of the storage account

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: RG_Template
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

