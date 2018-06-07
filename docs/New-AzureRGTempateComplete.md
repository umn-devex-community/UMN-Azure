---
external help file: UMN-Azure-help.xml
Module Name: umn-azure
online version:
schema: 2.0.0
---

# New-AzureRGTempateComplete

## SYNOPSIS
Create Resource Group Templete to build VM

## SYNTAX

```
New-AzureRGTempateComplete [[-resourceGroupName] <String>] [[-Location] <String>] [[-vm] <String>]
 [[-localUserName] <String>] [[-localPswd] <String>] [[-storageAccountName] <String>]
 [[-storageAccountKey] <String>] [[-vmSize] <String>] [[-sku] <String>] [[-netSecGroup] <String>]
 [[-netSecRG] <String>] [[-virtNetName] <String>] [[-vnetRG] <String>] [[-scriptPath] <String>]
 [[-scriptFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
Create Resource Group Templete to build VM

## EXAMPLES

### EXAMPLE 1
```
New-AzureRGTempateComplete -resourceGroupName $resourceGroupName -Location $Location -vm $vm -vmSize $vmSize -storageAccountName $storageAccountName -netSecGroup $netSecGroup -netSecRG $netSecRG -virtNetName $virtNetName -vnetRG $vnetRG -localUserName $localUserName -localPswd $localPswd
```

### EXAMPLE 2
```
Another example of how to use this cmdlet
```

## PARAMETERS

### -resourceGroupName
{{Fill resourceGroupName Description}}

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

### -Location
Azure zone, Central US and so forth.

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

### -vm
Name of the VM

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

### -localUserName
Name of the new local user

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

### -localPswd
Local administrator password

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

### -storageAccountName
Storage account name for VM storage

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -storageAccountKey
Storage account key

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

### -vmSize
Basic size of VM, such as A0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -sku
OS SKU -- such as 2012-R2-Datacenter

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -netSecGroup
network security group - plan ahead

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -netSecRG
network security resource group template

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -virtNetName
Name of virtual network to be access on

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -vnetRG
Name of virtual network gateway resource group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -scriptPath
Path in Azure Storeage where Powershell file resides that will be run on vm at build time

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -scriptFile
Name of File in scriptPath location that will be run on vm at build time

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Travis Sobeck

## RELATED LINKS
