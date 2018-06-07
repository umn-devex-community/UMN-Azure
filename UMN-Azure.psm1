###

# Copyright 2017 University of Minnesota, Office of Information Technology

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>. 

#region Basic Azure VM build

function New-AzureRGTempateComplete
{
    <#
        .Synopsis
            Create Resource Group Templete to build VM
        
        .DESCRIPTION
            Create Resource Group Templete to build VM

        .PARAMETER resourceGroupName,
            Resource group VM is to belong to.

        .PARAMETER Location
            Azure zone, Central US and so forth.

         .PARAMETER vm
            Name of the VM

        .PARAMETER localUserName
            Name of the new local user

        .PARAMETER localPswd
            Local administrator password

        .PARAMETER storageAccountName
            Storage account name for VM storage

        .PARAMETER storageAccountKey
            Storage account key

        .PARAMETER vmSize
            Basic size of VM, such as A0

        .PARAMETER sku
            OS SKU -- such as 2012-R2-Datacenter

        .PARAMETER netSecGroup
            network security group - plan ahead

        .PARAMETER netSecRG
            network security resource group template

        .PARAMETER virtNetName
            Name of virtual network to be access on

        .PARAMETER vnetRG
            Name of virtual network gateway resource group    
                   
        .PARAMETER scriptPath
            Path in Azure Storeage where Powershell file resides that will be run on vm at build time

        .PARAMETER scriptFile
            Name of File in scriptPath location that will be run on vm at build time

        .EXAMPLE
            New-AzureRGTempateComplete -resourceGroupName $resourceGroupName -Location $Location -vm $vm -vmSize $vmSize -storageAccountName $storageAccountName -netSecGroup $netSecGroup -netSecRG $netSecRG -virtNetName $virtNetName -vnetRG $vnetRG -localUserName $localUserName -localPswd $localPswd
        
        .EXAMPLE
            Another example of how to use this cmdlet
                    
        .Notes
            Author: Travis Sobeck
    #>

    [CmdletBinding()]
    Param
    (
        [ValidateNotNullOrEmpty()]
        [string]$resourceGroupName,

        [ValidateSet("eastus", "eastus2", "westus","centralus")]
        [string]$Location,

        [ValidateNotNullOrEmpty()]
        [string]$vm,

        [ValidateNotNullOrEmpty()]
        [string]$localUserName,

        [ValidateNotNullOrEmpty()]
        [string]$localPswd,

        [ValidateNotNullOrEmpty()]
        [string]$storageAccountName,
        
        [ValidateNotNullOrEmpty()]
        [string]$storageAccountKey,

        [string]$vmSize,

        [string]$sku,

        [string]$netSecGroup,

        [string]$netSecRG,

        [string]$virtNetName,

        [string]$vnetRG,
        
        [string]$scriptPath,

        [string]$scriptFile

    )

    $virtNetObject = Get-AzureRmVirtualNetwork -ResourceGroupName $vnetRG -Name $virtNetName
    $ipPrefix = $virtNetObject.AddressSpace.AddressPrefixes
    $subnets = $virtNetObject.Subnets
    foreach ($subnet in $subnets){
        if ($subnet.Name -eq 'default'){$subnetPrifix = $subnet.AddressPrefix;$subnetRef = $subnet.Id}
    }
    if ($subnetPrifix -eq $null){throw "Failed to find default subnet"}

    $netSecGroupID = (Get-AzureRmNetworkSecurityGroup -Name $netSecGroup -ResourceGroupName $netSecRG).Id
    $netIntName = $vm + "-nic-1"# + (Get-Random -Minimum 100 -Maximum 999)
    $pubIPName = $vm + "-PubIP"# + (Get-Random -Minimum 100 -Maximum 999)
    $pubDNSName = $vm# + "umn"
    $diskUri = "https://$storageAccountName" + ".blob.core.windows.net/vhds/$vm" + (Get-Random -Minimum 10000 -Maximum 99999) + '.vhd'

    $vmTemplate = @{type = "Microsoft.Compute/virtualMachines";name = $vm;apiVersion = "2015-06-15";location = $location;dependsOn = @("Microsoft.Network/networkInterfaces/$netIntName");
        properties = @{osProfile = @{computerName = $vm;adminUsername = $localUserName;adminPassword = $localPswd;windowsConfiguration = @{provisionVmAgent = 'true'}};
            hardwareProfile = @{vmSize = $vmSize};
            networkProfile = @{networkInterfaces = @(@{id="[resourceId('Microsoft.Network/networkInterfaces', '$netIntName')]"})};
            storageProfile = @{imageReference = @{publisher = "MicrosoftWindowsServer"; offer = "WindowsServer"; sku = $sku; version = "latest"};
                osDisk = @{name = $vm;vhd = @{uri = $diskUri};createOption = "fromImage"};
                dataDisks = @()}
        }
    }
    if ($scriptFile -and $scriptPath){
        $customScript = @{type = "Microsoft.Compute/virtualMachines/extensions";name = "$vm/BuildScript";apiVersion = "2016-03-30";location = $location;dependsOn = @("Microsoft.Compute/virtualMachines/$vm");
                            properties = @{publisher = "Microsoft.Compute";type = "CustomScriptExtension";typeHandlerVersion = "1.8";autoUpgradeMinorVersion = "true";
                                settings = @{fileUris = @(($scriptPath+$scriptFile));commandToExecute = "powershell.exe -ExecutionPolicy Unrestricted -File $scriptFile"};
                                protectedSettings = @{storageAccountName = $storageAccountName;storageAccountKey = $storageAccountKey}
                            }
                        }
    }
    $netInterfaceTemplate = @{type = "Microsoft.Network/networkInterfaces";name = $netIntName;apiVersion = "2015-06-15";location = $location;dependsOn = @("Microsoft.Network/publicIpAddresses/$pubIPName");
       properties = @{primary = $true;
        ipConfigurations = @(@{
            name = "ipconfig1";properties = @{subnet = @{id = $subnetRef};privateIPAllocationMethod = "Dynamic";publicIpAddress = @{id = "[resourceId('$resourceGroupName','Microsoft.Network/publicIpAddresses', '$pubIPName')]"}}
        });
        networkSecurityGroup = @{id = $netSecGroupID}
       }
    }

    $pubIpTemplate = @{type = "Microsoft.Network/publicIpAddresses";name = $pubIPName;apiVersion = "2015-06-15";location = $location;
       properties = @{publicIpAllocationMethod = "Dynamic";dnsSettings = @{domainNameLabel = $pubDNSName}} 
    }

    @{'$schema'='http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#';contentVersion="1.0.0.0";
        parameters = @{};
        variables = @{};
        resources = @($vmTemplate;$customScript;$netInterfaceTemplate;$pubIpTemplate);
        outputs = @{};
    } | ConvertTo-Json -Depth 7 | Out-File -FilePath .\$vm.json -Force 

    Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile .\$vm.json -Mode Incremental -Verbose

}

## Build VM
function New-AzureVMcomplete
{
    <#
        .Synopsis
            Build VM
        
        .DESCRIPTION
            Build a VM along with required resources

        .PARAMETER resourceGroupName,
            Resource group VM is to belong to.

        .PARAMETER Location
            Azure zone, Central US and so forth.

         .PARAMETER vm
            Name of the VM

        .PARAMETER localUserName
            Name of the new local user

        .PARAMETER localPswd
            Local administrator password

        .PARAMETER storageAccountName
            Storage account name for VM storage

        .PARAMETER storageAccountKey
            Storage account key

        .PARAMETER vmSize
            Basic size of VM, such as A0

        .PARAMETER sku
            OS SKU -- such as 2012-R2-Datacenter

        .PARAMETER netSecGroup
            network security group - plan ahead

        .PARAMETER netSecRG
            network security resource group template

        .PARAMETER virtNetName
            Name of virtual network to be access on

        .PARAMETER vnetRG
            Name of virtual network gateway resource group    
                
        .EXAMPLE
            $result = New-AzureVMcomplete -ResourceGroupName "VPN-GW" -Location eastus -vmname "mynewtest" -VMSize Basic_A0

        .Notes
            Author: Travis Sobeck
    #>
    [CmdletBinding()]
    Param
    (
        [ValidateNotNullOrEmpty()]
        [string]$resourceGroupName,

        [ValidateSet("eastus", "eastus2", "westus","centralus")]
        [string]$Location,

        [ValidateNotNullOrEmpty()]
        [string]$vm,

        [ValidateNotNullOrEmpty()]
        [string]$localUserName,

        [ValidateNotNullOrEmpty()]
        [string]$localPswd,

        [ValidateNotNullOrEmpty()]
        [string]$storageAccountName,
        
        [ValidateNotNullOrEmpty()]
        [string]$storageAccountKey,

        [string]$vmSize,

        [string]$sku,

        [string]$netSecGroup,

        [string]$netSecRG,

        [string]$virtNetName,

        [string]$vnetRG        

    )

    New-AzureRGTempateComplete -resourceGroupName $resourceGroupName -Location $Location -vm $vm -vmSize $vmSize -storageAccountName $storageAccountName -netSecGroup $netSecGroup -netSecRG $netSecRG -virtNetName $virtNetName -vnetRG $vnetRG -localUserName $localUserName -localPswd $localPswd
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile .\$vm.json
    Remove-Item -Path .\$vm.json -Force
}

function Remove-AzureVMcomplete
{
    <#
        .Synopsis
            Delete VM
        
        .DESCRIPTION
            Delete a VM and its NIC/PublicIP/osDisk
        
        .PARAMETER resourceGroupName
            The name of the resource group the VM belongs to

        .PARAMETER vm
            The name of the VM

        .PARAMETER storageRGname
            The resource group name of the storage account

        .EXAMPLE
            $result = Remove-AzureVMcomplete -ResourceGroupName "VPN-GW" -vm "mynewtest"
            
        .Notes
            Author: Travis Sobeck
    #>
    [CmdletBinding()]
    Param
    (
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName,

        [ValidateNotNullOrEmpty()]
        [string]$vm,

        [ValidateNotNullOrEmpty()]
        [string]$storageRGname = 'RG_Template'
    )

    $vmObj = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vm
    #### should probably stop vm
    $null = Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vm -Force # Status      : Succeeded
    ## get NetworkInterface info
    $netID = $vmObj.NetworkInterfaceIDs[0]
    $net = Get-AzureRmResource -ResourceId $netID
    $netIpConfigID = $net.Properties.ipConfigurations[0].id
    ## get Public IP info
    $pubIP = Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName
    $pubIpName = ($pubIP | Where-Object {$_.IpConfiguration[0].Id -eq $netIpConfigID}).Name

    ### Deletion order is very important
    ## remove vm
    $null = Remove-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vm -Force ## Status = Succeeded

    ## remove network Interface
    $null = Remove-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $net.Name -Force

    ## remove public IP
    if ($pubIpName -ne $null){$null = Remove-AzureRmPublicIpAddress -ResourceGroupName $resourceGroupName -Name $pubIpName -Force}
    else{write-host "No Public IP"}

    ## Delete Disk
    [array]$diskArray = ($vmObj.StorageProfile.OsDisk.vhd.Uri).Split('/')
    $container = $diskArray[-2] ## check this equals vhds
    $diskName = $diskArray[-1] ## check this equals $vm<rand>.vhd
    $StorageAccountName = ($diskArray[-3]).Split('.')[0] # do a Find-AzureRmResource -ResourceGroupNameContains $resourceGroupName -ResourceType 'Microsoft.Storage/storageAccounts' make sure its in there
    $StorageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $storageRGname -Name $StorageAccountName)[0].Value
    $ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    $null = Remove-AzureStorageBlob -Blob $diskName -Container $container -Context $ctx

    ## clean out of AD
    Remove-ADComputer -Identity $vm -Confirm:$false
}

#endregion

#region Azure Log Analytics

function Get-AzureLogAnalytics
{
    <#
        .Synopsis
            Query Azure Log Analytics
        
        .DESCRIPTION
            Requires having identity set in Azure AD to allow access to Log Analytics API, and an Azure AD Application registered to get an API OAuth token from.
        
        .PARAMETER workspaceID
            The workspaceID reference for this API is the subscription which has the Log Analytics account.

        .PARAMETER accessToken
            An OAuth accessToken. See Get-AzureOAuthTokenUser as a possible source.

        .PARAMETER query
            A valid Log Analytics query. Example = 'AzureDiagnostics | where ResultType == "Failed" | where RunbookName_s == "Name of runbook" |where TimeGenerated > ago(1h)'

        .EXAMPLE
            $result = Get-AzureLogAnalytics -workspaceID <Subscription ID> -accessToken $accessToken -query $query 
               
        .Notes
            Author: Kyle Weeks
    #>

    param 
    (
        [Parameter(Mandatory=$true)]
        [string] $workspaceID,

        [Parameter(Mandatory=$true)]
        [string] $accessToken,

        [Parameter(Mandatory=$true)]
        [string] $query
    )
    
    Begin
    {
        $contentType = 'application/json'
        $uri = "https://api.loganalytics.io/v1/workspaces/"+$workspaceID+"/query"
        $header = @{"Authorization"="Bearer $accessToken"}
        $body = @{"query"=$query} |ConvertTo-Json
    }

    Process
    {
        $response = Invoke-RestMethod -Method Post -Uri $uri -Body $body -Headers $header -ContentType $contentType
    }

    End
    {
        return $response
	}
}



#endregion

#region Azure Graph API
## A starter point for the graph API
## Based on https://developer.microsoft.com/en-us/graph/graph-explorer
## oData Filtering/paging is supported. See https://msdn.microsoft.com/en-us/library/azure/ad/graph/howto/azure-ad-graph-api-supported-queries-filters-and-paging-options
## Example: $uri = "https://graph.microsoft.com/v1.0/users?" + '$filter' + "=userPrincipalName eq '$userPrincipalName'"

function Get-AzureGraphUsers
{
    <#
        .Synopsis
            Query Azure Graph API for basic user details
        
        .DESCRIPTION
            Requires having identity set in Azure AD to allow access to Graph API, and an Azure AD Application registered to get an API OAuth token from.

        .PARAMETER accessToken
            An OAuth accessToken. See Get-AzureOAuthTokenUser as a possible source.

        .PARAMETER userPrincipalNames
            A valid user userPrincipalName

        .PARAMETER query
            Optional to query specified information about the user object.

        .EXAMPLE
            $result = Get-AzureGraphUsers -accessToken $accessToken -userPrincipalName 'jemina@somedomain.onmicrosoft.com' -query
               
        .Notes
            Author: Kyle Weeks
    #>

    param 
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [array] $userPrincipalNames,

        [Parameter(Mandatory=$true)]
        [string] $accessToken,

        [ValidateSet('owndedDevices','registeredDevices','manager','directReports','memberOf','createdObjects','owndedObjects','licenseDetails','extensions','messages','mailFolders','calendar','calendars','calendarGroups','calendarView','events','people','contacts','contactFolders','inferenceClassification','photo','photos','drive','drives','planner','onenote')]
        [string]$query
    )
    
    Begin
    {
        $header = @{"Authorization"="Bearer $accessToken"}
        $users = @{}
    }

    Process
    {
        Foreach ($PSItem in $userPrincipalNames)
            {
                $results = $null
                $uri = "https://graph.microsoft.com/v1.0/users/$PSItem/$query"
                $results = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
                $users.Add($PSItem,$results)
            }
    }

    End
    {
        return $users
	}
}

Function Get-AzureGraphObject{

    <#
        .Synopsis
            Query Azure Graph API for object details
        
        .DESCRIPTION
            Use the $top oData filter to query objects in bulk using paging.

        .PARAMETER accessToken
            An OAuth accessToken. See Get-AzureOAuthTokenUser as a possible source.

        .PARAMETER apiVersion
            Some of the API versions in Graph are 'beta' - default to 1.0

        .PARAMETER batchSize
            Used to determine how many records to return per page. Microsoft Graph behaviors are per api...
            
        .PARAMETER objectType
            The object type to query.
            Paging with the $top filter is supported for all /users, but the $top filter is rejected.

        .EXAMPLE
            $results = Get-AzureGraphObject -accessToken $accessToken -objectType ''

        .EXAMPLE
            $results = Get-AzureGraphObject -accessToken $accessToken -apiVersion 'Beta' -batchSize 500 -objectType ''

        .Notes
            Author: Kyle Weeks
    #>

    param
        (
        [Parameter(Mandatory=$true)]
        [string] $accessToken,
        
        [Parameter(Mandatory=$false)]
        [string]$apiVersion,
        
        [Parameter(Mandatory=$false)]
        [int]$batchSize = '200',

        [Parameter(Mandatory=$true)]
        [string]$objectType
        )
  
    Begin
    {
        if(-not $apiVersion) 
            {$apiVersion='v1.0'}

        $header = @{"Authorization"="Bearer $accessToken"}
        $uri = "https://graph.microsoft.com/$apiVersion/$objectType`?top eq $batchSize"
        If($objectType -eq 'users')
            {
                $uri = "https://graph.microsoft.com/$apiVersion/$objectType"
            }

        ## Testing
        $i=0
    }

    Process
    {
        $results= @()
        do
        {
            $return = $null
            $return = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
            $uri = $return.'@odata.nextlink'
            $results = $results + $return.value
            $i++
            write-host "Pass number $i"

        }
        until ($uri -eq $null)
    }

    End
    {
        return $results
    }

}

function Get-AzureOneDriveID 
{
<#
    .Synopsis
        Gets One Drive ID by User
    
    .DESCRIPTION
        Gets One Drive ID by User
    
    .PARAMETER accessToken
        oAuth Access token with API permissions allowed for One Drive on the https://graph.microsoft.com resource.

    .PARAMETER apiVersion
        Defaults to 1.0. Can set for beta or other as they allow.

    .PARAMETER userPrincipalName
        User Principal Name of the user's one drive.

    .EXAMPLE
        Get-AzureOneDriveID -accessToken $accessToken -userPrincipalName 'moon@domain.edu'
            
    .Notes
        Author: Kyle Weeks
#>  
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$accessToken,

    [string]$apiVersion = 'v1.0',

    [Parameter(Mandatory=$true)]
    [string]$userPrincipalName
)

    Begin
    {
        $header = @{"Authorization"="Bearer $accessToken"}
    }
    Process
    {    
        $uri = "https://graph.microsoft.com/$apiVersion/users/$userPrincipalName/drives"
        $return = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    }

    End
    {
        return $return.value.Id
    }
}

function Get-AzureOneDriveFiles
{
<#
    .Synopsis
        Function to query One Drive for files
    
    .DESCRIPTION
        Needed in order to upload large files to One Drive via the Graph API.
    
    .PARAMETER accessToken
        oAuth Access token with API permissions allowed for One Drive on the https://graph.microsoft.com resource.

    .PARAMETER apiVersion
        Defaults to 1.0. Can set for beta or other as they allow.

    .PARAMETER driveID
        The OneDrive ID of the O365 User. See Get-AzureOneDriveID.

    .PARAMETER itemIDs
        An array of file/folder item IDs to be downloaded. See Get-AzureOneDriveRootContent as a starting place.

    .PARAMETER outPutPath
        Local path to store the files.

    .PARAMETER rootCreated
        A switch for when looping through from the root of a one drive to gather the entire one drive.

    .PARAMETER userPrincipalName
        The Azure AD UserPrincipalName of the OneDrive account owner.

    .EXAMPLE
        Get-AzureOneDriveFiles -accessToken $accessToken -driveID $driveID -itemIDs $arrayOfItemIds -outPutPath c:\temp -rootCreated $False -userPrincipalName 'moon@domain.edu'
            
    .Notes
        Author: Kyle Weeks
#>    
param (
    [Parameter(Mandatory=$true)]
    [string]$accessToken,

    [string]$apiVersion = 'V1.0',

    [Parameter(Mandatory=$true)]
    [string]$driveID,
    
    [Parameter(Mandatory=$true)]
    [array]$itemIDs,

    [Parameter(Mandatory=$true)]
    [string]$outPutPath,

    [string]$rootCreated = 'needed',

    [Parameter(Mandatory=$true)]
    [string]$userPrincipalName
    )

Begin
{
    $user = ($userPrincipalName -split ("@"))[0]
    $header = @{"Authorization"="Bearer $accessToken"}

    # Check and create output directory
    If ($outPutPath -notmatch '.+?\\$') {$outPutPath += '\'}
    Try {Get-ChildItem -path $outputPath\$user -ErrorAction stop}
    Catch {New-Item -ItemType directory -Path $outPutPath\$user}

    # Get first folder structure of root:/ and create if needed.
    If($rootCreated -eq 'needed')
        {
            $itemIDs | ForEach-Object {
                $child = $_
                $return = Get-AzureOneDriveItem -accessToken $accessToken -driveID $driveID -itemID $child
                
                # Folder / File Loop
                if ($return.folder){
                    $parent = $return.parentReference.path -replace ("/drives/$driveID/root:","$outPutPath\$user")
                    $parent = $parent -replace ("/","\")
                    New-Item -ItemType directory -Path ($parent + '\' + $return.name) -Force
                    }
                if ($return.file){
                    $fileName = $return.name
                    If ($outPutPath -match '.+?\\$') {$outPutPath = $outPutPath.Substring(0,$outPutPath.Length-1)}
                    $filePath = $return.parentReference.path -replace ("/drives/$driveID/root:","$outPutPath\$user")
                    $filePath = $filePath -replace ("/","\")
                    $outfile = $filePath + '\' + $fileName
                    $download = $return.'@microsoft.graph.downloadUrl'
                    Invoke-WebRequest -Method Get -Uri $download -OutFile $outfile
                    }   
                if ($return.package.type)
                    {
                        $type = $return.package.type
                        $location = $return.parentReference
                        Write-Host "$type found at location $location. Unable to download for user $user"
                    }
            }        
        }

    }


Process{
    Foreach ($PSItem in $itemIDs){    
            # Get Children of Item
            $uri = "https://graph.microsoft.com/$apiVersion/drives/$driveID/items/$PSItem"+"?expand=children(select=id,name)"
            $return = Invoke-RestMethod -Method Get -Uri $uri -Headers $header 
            $children = $return.children

            # Process each item
            $children | ForEach-Object{
                    $child = $_.id
                    $return = Get-AzureOneDriveItem -accessToken $accessToken -driveID $driveID -itemID $child
                    
                    # Folder / File Loop
                    if ($return.folder){
                        $parent = $return.parentReference.path -replace ("/drives/$driveID/root:","$outPutPath\$user")
                        $parent = $parent -replace ("/","\")
                        New-Item -ItemType Directory -Path ($parent + '\' + $return.name) -Force
                        Try {
                            $newArray = New-Object System.Collections.ArrayList($null)
                            $return | foreach-object {$null = $newArray.Add($_.id)} 
                            Start-Sleep -Seconds 1
                            Get-AzureOneDriveFiles -accessToken $accessToken -driveID $driveID -itemIDs $newArray -user $user -outPutPath $outPutPath -rootCreated 'done'
                        }
                        Catch{}                  
                        }
                    if ($return.file){
                            $fileName = $return.name
                            If ($outPutPath -match '.+?\\$') {$outPutPath = $outPutPath.Substring(0,$outPutPath.Length-1)}
                            $filePath = $return.parentReference.path -replace ("/drives/$driveID/root:","$outPutPath\$user")
                            $filePath = $filePath -replace ("/","\")
                            $outfile = $filePath + '\' + $fileName
                            $download = $return.'@microsoft.graph.downloadUrl'
                            Invoke-WebRequest -Method Get -Uri $download -OutFile $outfile
                        }
                    if ($return.package.type)
                    {
                        $type = $return.package.type
                        $location = $return.parentReference
                        Write-Host "$type found at location $location. Unable to download for user $user"
                    }       
                }
        }
    }
end{}
}

function Get-AzureOneDriveItem
{
<#
    .Synopsis
        Gets One Drive Item by ID
    
    .DESCRIPTION
        Gets One Drive Item by ID
    
    .PARAMETER accessToken
        oAuth Access token with API permissions allowed for One Drive on the https://graph.microsoft.com resource.

    .PARAMETER apiVersion
        Defaults to 1.0. Can set for beta or other as they allow.

    .PARAMETER driveID
        The OneDrive ID of the O365 User. See Get-AzureOneDriveID.

    .PARAMETER itemID
        The itemID of the folder/file.

    .EXAMPLE
        Get-AzureOneDriveItem -accessToken $accessToken -driveID $driveID -itemID $itemID
            
    .Notes
        Author: Kyle Weeks
#>  
param(
    [Parameter(Mandatory=$true)]
    [string]$accessToken,

    [string]$apiVersion = 'v1.0',

    [Parameter(Mandatory=$true)]
    [string]$driveID,

    [Parameter(Mandatory=$true)]
    [string]$itemID
)
Begin{}
Process
{
    $header = @{"Authorization"="Bearer $accessToken"}
    $uri = "https://graph.microsoft.com/$apiVersion/drives/$driveID/items/$itemID"
    $return = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
}
End{return $return}
}
function Get-AzureOneDriveRootContent 
{
<#
    .Synopsis
        Gets the One Drive Root Content
    
    .DESCRIPTION
        Will get all IDs of folders and files at the root of a one Drive with Child item info.
    
    .PARAMETER accessToken
        oAuth Access token with API permissions allowed for One Drive on the https://graph.microsoft.com resource.

    .PARAMETER apiVersion
        Defaults to 1.0. Can set for beta or other as they allow.

    .PARAMETER driveID
        The drive ID to be queried.

    .EXAMPLE
        Get-AzureOneDriveRootContent -accessToken $accessToken -driveID $driveID
            
    .Notes
        Author: Kyle Weeks
#>  
[CmdletBinding()]
param 
(
    [Parameter(Mandatory=$true)]
    [string]$accessToken,

    [string]$apiVersion = 'V1.0',

    [Parameter(Mandatory=$true)]
    [string]$driveID
)

    Begin
    {
        $header = @{"Authorization"="Bearer $accessToken"}
    }

    Process
    {
        $uri = "https://graph.microsoft.com/$apiVersion/drives/$driveID/root?expand=children(select=id,name,type,property)"
        $return = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    }
    End
    {
        return $return.children
    }
}

function New-OneDriveFolder
{
<#
    .Synopsis
        Creates a new folder
    
    .DESCRIPTION
        Provide a item ID of parent folder or create new folder at root of OneDrive
    
    .PARAMETER accessToken
        oAuth Access token with API permissions allowed for One Drive on the https://graph.microsoft.com resource.

    .PARAMETER apiVersion
        Defaults to 1.0. Can set for beta or other as they allow.

    .PARAMETER folderName
        Name of the new folder

    .PARAMETER parentID
        Item of the parent folder

    .PARAMETER root
        Boolean switch. If true - no parent ID is needed, and will create folder in root of One Drive.

    .PARAMETER userPrincipalName
        UserPrincipalName of the OneDrive account owner.        

    .EXAMPLE
        New-OneDriveFolder -accessToken $accessToken -folderName 'New Folder' -root $true -userPrincipalName 'moon@domain.edu'

    .EXAMPLE
        New-OneDriveFolder -accessToken $accessToken -folderName 'New Folder' -parentID $parentID -userPrincipalName 'moon@domain.edu'
            
    .Notes
        Author: Kyle Weeks
#>  
[CmdletBinding()]
param 
(
    [Parameter(Mandatory=$true)]
    [string]$accessToken,

    [string]$apiVersion = 'V1.0',

    [Parameter(Mandatory=$true)]
    [string]$folderName,

    [string]$parentID,

    [boolean]$root = $false,

    [Parameter(Mandatory=$true)]
    [string]$userPrincipalName
)
Begin
{
    $body = @{folder=@{"@odata.type"="microsoft.graph.folder"};name="$folderName"} |ConvertTo-Json
    $header = @{"Authorization"="Bearer $accessToken"}
    If ($root -eq $false)
    {
        $uri = "https://graph.microsoft.com/$apiVersion/users/$userPrincipalName/drive/items/$parentID/children"
    }
    else 
    {
        $uri = "https://graph.microsoft.com/$apiVersion/users/$userPrincipalName/drive/root/children"   
    }
    
    
}
Process
{
    $return = Invoke-RestMethod -Method Post -Uri $uri -Headers $header -Body $body -ContentType 'application/json'
}
End
{
    return $return
}

}

function New-OneDriveLargeFileUpload 
{
<#
    .Synopsis
        Upload large files to OneDrive
    
    .DESCRIPTION
        Will break down a large file into chunks for upload to OneDrive for Business account. Requires prep work for administrative control.
    
    .PARAMETER chunkSize
        The byte chunk size to break the file into. Has to be a multiple of 327680 or OneDrive API will reject.

    .PARAMETER localFilePath
        Path to the local file to be uploaded. Include the file name with extension.

    .PARAMETER uploadURL
        The upload URL provided from the upload session request. See New-AzureOneDriveLargeFileSession call to retrieve.

    .EXAMPLE
        New-OneDriveLargeFileUpload -localFilePath c:\temp\aVeryLargeFile.vhd -uploadURL $uploadURL
            
    .Notes
        Author: Kyle Weeks
#>
param
(
    [int]$chunkSize=4915200,
    
    [Parameter(Mandatory=$true)]
    [string]$LocalFilePath,

    [Parameter(Mandatory=$true)]
    [string]$uploadURL
)
Begin
{    
    $reader = [System.IO.File]::OpenRead($LocalFilePath)
    $fileLength = $reader.Length
    $buffer = New-Object Byte[] $chunkSize
    $moreChunks = $true
    $byteCount = 0
}
Process
{    
    while($moreChunks)
    {
        ## Test for end of file
        If (($reader.Position + $buffer.Length) -gt $fileLength)
            {
                $bits = ($fileLength - $reader.Position)
                $buffer = New-Object Byte[] $bits
                $bytesRead = $reader.Read($buffer, 0, $bits)
                $moreChunks = $false
            }
        Else {$bytesRead = $reader.Read($buffer, 0, $buffer.Length)} 

        $output = $buffer
        $contentLength = $bytesread
        $uploadRange = ($reader.Position -1)
        $contentRange = "$bytecount"+"-"+$uploadRange+"/$fileLength"
        $headerUpload = @{
                "Content-Length"=$contentLength;
                "Content-Range"="bytes $contentRange"
                }
        $return = Invoke-RestMethod -Method Put -Uri $uploadURL -Headers $headerUpload -Body $output
        $byteCount =  $byteCount + $chunkSize
        $return.nextExpectedRanges

    }
}
End
{
    $reader.Close()
    return $return
}
}
    
function New-AzureOneDriveLargeFileSession
{
<#
    .Synopsis
        Generates a One Drive large file upload session.
    
    .DESCRIPTION
        Needed in order to upload large files to One Drive via the Graph API.
    
    .PARAMETER accessToken
        oAuth Access token with API permissions allowed for One Drive on the https://graph.microsoft.com resource.

    .PARAMETER apiVersion
        Defaults to 1.0. Can set for beta or other as they allow.

    .PARAMETER driveID
        The OneDrive ID of the O365 User. See Get-AzureOneDriveID.

    .PARAMETER OneDriveFilePath
        The One Drive folder path with file name. "New Folder/Microsoft.jpg"

    .EXAMPLE
        New-AzureOneDriveLargeFileSession -accessToken $accessToken -driveID $driveID -oneDriveFilePath $oneDriveFilePath
            
    .Notes
        Author: Kyle Weeks
#>    
    param
    (
        [Parameter(Mandatory=$true)]    
        [string]$accessToken,

        [string]$apiVersion = "v1.0",

        [Parameter(Mandatory=$true)]
        [string]$driveID,

        [Parameter(Mandatory=$true)]
        [string]$OneDriveFilePath
    )
Begin
{
    $header = @{"Authorization"="Bearer $accessToken"}
    $method = 'POST'
    $uri = "https://graph.microsoft.com/$apiVersion/drives/$driveID/root:/$OneDriveFilePath"+":/createUploadSession"
}
Process
{
    $response = Invoke-RestMethod -Method $method -Uri $uri -Headers $header
    $uploadURL = $response.uploadurl

}
End
{
    return $uploadURL
}
}

#endregion


#region Azure Marketplace billing

function Get-AzureMarketplaceCharges
{
    <#
        .Synopsis
            Get azure marketplace usage
        
        .DESCRIPTION
            For getting marketplace usage data.
        
        .PARAMETER key
            API key gathered from the EA portal for use with billing API.

        .PARAMETER enrollment
            Your Enterprise Enrollment number. Available form the EA portal.

        .PARAMETER billingPeriodID
            An optional parameter to specify that you wish to get from the following year and month. Format YYYYMM
        
        .PARAMETER startDate
            Start date time of the query - ####-##-## year, month, day = 2017-01-28
        
        .PARAMETER endDate
            End date time of the query - ####-##-## year, month, day = 2017-01-28
        
        .EXAMPLE
            $result = Get-AzureMarketplaceCharges -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' 
        
        .EXAMPLE
            $result = Get-AzureMarketplaceCharges -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -billingPeriodID '201701'
        
        .EXAMPLE
            $result = Get-AzureMarketplaceCharges -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -startDate '20170515' -endDate '20170602'
            
        .Notes
            Author: Kyle Weeks
    #>

    param 
    (
        [Parameter(Mandatory=$true)]
        [string] $enrollment,

        [Parameter(Mandatory=$true)]
        [string] $key,

        [string]$billingPeriodID,

        [ValidateLength(1,10)]
        [string]$startDate,

        [ValidateLength(1,10)]
        [string]$endDate
    )
    
    Begin{
    $header = @{"authorization"="bearer $key"}

    if ($billingPeriodID -eq '') {$uri = "https://consumption.azure.com/v2/enrollments/$enrollment/marketplacecharges"}
    Else {$uri = "https://consumption.azure.com/v2/enrollments/$enrollment/billingPeriods/$billingPeriodID/marketplacecharges"}

    if ($startDate -ne '') {if ($endDate -ne ''){$uri = "https://consumption.azure.com/v2/enrollments/$enrollment/marketplacechargesbycustomdate?startTime=$startDate&endTime=$endDate"}}
    }

    Process
    {
        $response = Invoke-WebRequest $uri -Headers $header -ErrorAction Stop
    }

    End
    {
        return $response
	}
}

#endregion

#region Azure OAuth authentication

function Get-AzureOAuthTokenService{
    <#
        .Synopsis
           Get Valid OAuth Token.  The access token is good for an hour, and there is no refresh token.
        
        .DESCRIPTION
            This OAuth token is intended for use with CLI, automation, and service calls. No user interaction is required.
            Requires an application to be registered in Azure AD with appropriate API permissions configured.

        .PARAMETER tenantID
            Azure AD Directory ID/TenantID

        .PARAMETER clientid
            Azure AD Custom Application ID

        .PARAMETER accessKey
            Azure AD Custom Application access key


        .PARAMETER resource
            Resource to be interacted with. Example = https://api.loganalytics.io. Use the clientID here if authenticating a token to your own custom app.
        
        .PARAMATER scope    
            An alternate to url resource to provide security scope to actions of an API such as with OneDrive.

        .EXAMPLE
            $tokenInfo = Get-AzureOAuthTokenService -tenantID 'Azure AD Tenant ID' -clientid 'Application ID' -accessKey 'Preset key for app' -resource 'MS API Resource'
        
        .Notes
            Author: Kyle Weeks
    #>
    [CmdletBinding()]
    [OutputType([array])]
    Param
    (
        [Parameter(Mandatory)]
        [string]$tenantID,

        [Parameter(Mandatory)]
        [string]$clientid,

        [Parameter(Mandatory)]
        [string]$accessKey,

        [string]$resource,

        [string]$scope = ''
    )     
     
    Begin
    {
        $uri = "https://login.microsoftonline.com/$tenantID/oauth2/token"
    }

    Process
    {
        If ($scope -ne '')
            {$body = @{grant_type="client_credentials";client_id=$clientid;client_secret=$accessKey;scope=$scope}}
        else 
            {$body = @{grant_type="client_credentials";client_id=$clientid;client_secret=$accessKey;resource=$resource}}        

        $response = Invoke-RestMethod -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body
        $accessToken = $response.access_token
    }

    End
    {
        return $accessToken
    }
}

function Get-AzureOAuthTokenUser{
    <#
        .Synopsis
           Get Valid OAuth Token.  The access token is good for an hour, the refresh token is mostly permanent and can be used to get a new access token without having to re-authenticate
        
        .DESCRIPTION
            This is based on authenticating against a custom Web/API Application registered in Azure AD which has permissions to Azure AD, Azure Management, and other APIs.

        .PARAMETER tenantID
            Azure AD Directory ID/TenantID

        .PARAMETER clientid
            Azure AD Custom Application ID

        .PARAMETER accessKey
            Azure AD Custom Application access key

        .PARAMETER redirectUri
            For return stream of claims

        .PARAMETER resource
            Resource to be interacted with. Example = https://api.loganalytics.io, or https://graph.microsoft.com

        .PARAMETER refreshtoken
            Supply a refresh token to get a new valid token for use after expiring

        .PARAMETER prompt
            Define if your app login should prompt the user for consent in the Azure portal on login. none = will never request and rely on SSO (web apps)
                    
        .EXAMPLE
            $tokenInfo = Get-AzureOAuthTokenUser -tenantID 'Azure AD Tenant ID' -clientid 'Application ID' -accessKey 'Preset key for app' -redirectUri 'https redirect uri of app' -resource 'MS API Resource'
        
        .EXAMPLE
            $tokenInfo = Get-AzureOAuthTokenUser -tenantID 'Azure AD Tenant ID' -clientid 'Application ID' -accessKey 'Preset key for app' -redirectUri 'https redirect uri of app' -resource 'MS API Resource' -refreshtoken 'your refresh token from a previous call'

        .Notes
            Author: Kyle Weeks
    #>
    [CmdletBinding()]
    [OutputType([array])]
    Param
    (
        [Parameter(Mandatory)]
        [string]$tenantID,

        [Parameter(Mandatory)]
        [string]$clientid,

        [Parameter(Mandatory)]
        [string]$accessKey,

        [Parameter(Mandatory)]
        [string]$redirectUri,

        $resource,

        $scope = '',

        [ValidateSet('login','none','consent')]
        [string]$prompt = "consent",

        [string]$refreshtoken
        )     
     
    Begin
    {
        # Build Azure REST Endpoints
        $baseURI = "https://login.microsoftonline.com/$tenantID"
        $tokenEndpoint = $baseURI + "/oauth2/token"
        $authorizeEndpoint = $baseURI + "/oauth2/authorize"
    }

    Process
    {
        If (!$refreshtoken){

            # Get a claim code which is used to get a token
            $responseType = 'code'
            $grantType = "authorization_code"

            # Construct the claim authorization endpoint
            If ($scope -ne ''){
                $uri = $authorizeEndpoint+"?client_id=$clientid&response_type=$responseType&scope=$scope&redirect_uri=$redirectUri&prompt=$prompt"
            }
            else {
                $uri = $authorizeEndpoint+"?client_id=$clientid&response_type=$responseType&resource=$resource&redirect_uri=$redirectUri&prompt=$prompt"
            }
            # OAuth is generally used interactive for users... not core friendly.
            ## Popup a new IE window, log in, authorize app as needed, and collect claim code
            $ie = New-Object -comObject InternetExplorer.Application
            $ie.visible = $true
            $null = $ie.navigate($uri)

            #Wait for user interaction in IE, manual approval
            do{Start-Sleep 1}until($ie.LocationURL -match 'code=([^&]*)')
            $null = $ie.LocationURL -match 'code=([^&]*)'
            $authorizationCode = $matches[1]
            $null = $ie.Quit()

            # exchange the authorization code for tokens
            $uri = $tokenEndpoint
            If ($scope -ne ''){
                $body = @{client_id=$clientid;grant_type=$grantType;code=$authorizationCode;redirect_uri=$redirectUri;client_secret=$accessKey;resource=$resource}
            }
            Else {
                $body = @{client_id=$clientid;grant_type=$grantType;code=$authorizationCode;redirect_uri=$redirectUri;client_secret=$accessKey;resource=$resource}
            }
            
            $response = Invoke-RestMethod -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body

            $properties = @{
                accessToken = $response.access_token
                refreshToken = $response.refresh_token
                jwt = $response.id_token
        }
        }

        Else {
            ## Exchange a refresh token for new tokens
            $grantType = "refresh_token"
            $uri = $tokenEndpoint
            $body = @{client_id=$clientid;grant_type=$grantType;client_secret=$accessKey;refresh_token=$refreshtoken}
 
            $response = Invoke-RestMethod -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body
            $properties = @{
                accessToken = $response.access_token
                refreshToken = $response.refresh_token
                jwt = $response.id_token
        }

    }
    }

    End
    {
        return $properties
    }
}

#endregion


#region Azure Price Sheets

function Get-AzurePriceSheet {
    <#
        .Synopsis
            Get current price sheet from enterprise portal
        
        .DESCRIPTION
            Use this call to get a price sheet of resources from the EA portal using an API key
        
        .PARAMETER key
            API key gathered from the EA portal for use with billing API.

        .PARAMETER enrollment
            Your Enterprise Enrollment number. Available form the EA portal.

        .PARAMETER billingPeriodID
            An optional parameter to specify that you wish to get from the following year and month. Format YYYYMM

        .EXAMPLE
            $result = Get-AzurePriceSheet -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber'
        
        .EXAMPLE
            $result = Get-AzurePriceSheet -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -billingPeriodID '201701'

        .Notes
            Author: Kyle Weeks
    #>

    param
    (
        [Parameter(Mandatory=$true)]
        [string]$key,

        [Parameter(Mandatory=$true)]
        [string]$enrollment,

        [string]$billingPeriodID
    )

    Begin{
        $header = @{"authorization"="bearer $key"}
        If (-not $billingPeriodID){$uri = "https://consumption.azure.com/v2/enrollments/$enrollment/pricesheet"}
        Else {$uri = "https://consumption.azure.com/v2/enrollments/$enrollment/billingPeriods/$billingPeriodID/pricesheet"}
    }

    Process
    {
        $response = Invoke-WebRequest -Uri $uri -Headers $header
        $return = $response.Content |ConvertFrom-Json
    }

    End
    {
        return $return

    }
}


function Get-AzureBillingPeriods {
    <#
        .Synopsis
            Get current available billing periods, and some metadata around them.
    
        .DESCRIPTION
            A call to get available billing periods from your EA portal.
        
        .PARAMETER key
            API key gathered from the EA portal for use with billing API.

        .PARAMETER enrollment
            Your Enterprise Enrollment number. Available form the EA portal.

        .EXAMPLE
            $result =  Get-AzureBillingPeriods -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber'
        
        .Notes
            Author: Kyle Weeks
    #>


    param 
    (
        [Parameter(Mandatory=$true)]
        [string]$key,

        [Parameter(Mandatory=$true)]
        [string]$enrollment
    )

    Begin{
        $header = @{"authorization"="bearer $key"}
        $uri = "https://consumption.azure.com/v2/enrollments/$enrollment/billingPeriods"
    }

    Process
    {
        $response = Invoke-WebRequest -Uri $uri -Headers $header
        $return = $response.Content |ConvertFrom-Json 
    }

    End
    {
        return $return
    }
}

#endregion

#region Azure Usage

function Get-AzureUsageJSON
{
    <#
        .Synopsis
            Get azure usage in a JSON format directly
        
        .DESCRIPTION
            There are other options for retrieving usage information. Directly as a CSV non-polling, polling, or JSON.
            If no billing period is included. The current month cycle will be retreived.

        .PARAMETER key
            API key gathered from the EA portal for use with billing API.

        .PARAMETER enrollment
            Your Enterprise Enrollment number. Available form the EA portal.

        .PARAMETER billingPeriodID
            An optional parameter to specify that you wish to get from the following year and month. Format YYYYMM

        .PARAMETER startDate
            Start date time of the query - ####-##-## year, month, day = 2017-01-28
        
        .PARAMETER endDate
            End date time of the query - ####-##-## year, month, day = 2017-01-28        
       
        .EXAMPLE
            $result = Get-AzureUsageJSON -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' 
        
        .EXAMPLE
            $result = Get-AzureUsageJSON -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -billingPeriodID '201701'
        
        .EXAMPLE
            $result = Get-AzureUsageJSON -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -startDate '20170515' -endDate '20170602'

        .Notes
            Author: Kyle Weeks
    #>

    param 
    (
        [Parameter(Mandatory=$true)]
        [string] $enrollment,

        [Parameter(Mandatory=$true)]
        [string] $key,

        [string]$billingPeriod, ## year + month

        [ValidateLength(1,10)]
        [string]$startDate, ####-##-## year, month, day = 2017-01-28

        [ValidateLength(1,10)]
        [string]$endDate ####-##-## year, month, day = 2017-01-28
    )

    Begin{
        $header = @{"authorization"="bearer $key"}

        If ($billingPeriod -eq ''){$uri = "https://consumption.azure.com/v2/enrollments/$enrollment/usagedetails"}
        Else {$uri = "https://consumption.azure.com/v2/enrollments/$enrollment/billingPeriods/$billingPeriod/usagedetails"}

        if ($startDate -ne '') {if ($endDate -ne ''){$uri = "https://consumption.azure.com/v2/enrollments/$enrollment/usagedetailsbycustomdate?startTime=$startDate&endTime=$endDate"}}
    
    }

    Process
    {
        $usage = @()
        while ($uri -ne $null)
	    {
		    $response = Invoke-WebRequest $uri -Headers $header -ErrorAction Stop
		    if ($response.StatusCode -eq 200) {
			    $usage += ($response.Content | ConvertFrom-Json).Data

			    # get next page link - loop for more data
			    $uri = ($response.Content | ConvertFrom-Json).nextLink
		    }
	    }
    }

    End
    {
        return $usage
    }
}

function Get-AzureUsageCSV
{
    <#
        .Synopsis
            Get azure usage directly as a CSV (as if downloading from the web UI)
        
        .DESCRIPTION
            There are other options for retrieving usage information. Directly as a CSV non-polling, polling, or JSON.
        
        .PARAMETER key
            API key gathered from the EA portal for use with billing API.

        .PARAMETER enrollment
            Your Enterprise Enrollment number. Available form the EA portal.

        .PARAMETER billingPeriodID
            An optional parameter to specify that you wish to get from the following year and month. Format YYYYMM

        .PARAMETER outputDir
            A directory for outputing a CSV of collected data.
 
        .EXAMPLE
        $result = Get-AzureUsageCSV -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -billingPeriodID '201701' -outputDir 'c:\'

        .Notes
            Author: Kyle Weeks
    #>

    param 
    (
        [Parameter(Mandatory=$true)]
        [string] $enrollment,

        [Parameter(Mandatory=$true)]
        [string] $key,

        [Parameter(Mandatory=$true)]
        [string]$billingPeriod,  ## year+month

        [Parameter(Mandatory=$true)]
        [string]$outputDir
    )

    Begin{
        $header = @{"authorization"="bearer $key"}
        $uri = "https://consumption.azure.com/v2/enrollments/$enrollment/usagedetails/download?billingPeriod=$billingPeriod"
        If ($outputDir -notlike '*\') {$outputDir = $outputDir + '\'}
        $outfile = $outputDir+"AzureUsage-"+"$billingPeriod"+".csv"
    }

    Process
    {
	    $response = Invoke-WebRequest $uri -Headers $header -OutFile $outfile |Out-Null
    }

    End
    {
        return $response
    }

}

function Get-AzureUsageCSVcustomDate
{
    <#
        .Synopsis
            Get azure usage in a CSV format directly - providing a custom date range
        
        .DESCRIPTION
            There are other options for retrieving usage information. Directly as a CSV non-polling, polling, or JSON.
            This method requests a custom data file be generated (up to 36 months of data). It is saved to a blob storage point.
            The function will poll that location until it is available, then output the csv.
        
        .PARAMETER key
            API key gathered from the EA portal for use with billing API.

        .PARAMETER enrollment
            Your Enterprise Enrollment number. Available form the EA portal.

        .PARAMETER billingPeriodID
            An optional parameter to specify that you wish to get from the following year and month. Format YYYYMM
        
        .PARAMETER startDate
            Start date time of the query - ####-##-## year, month, day = 2017-01-28
        
        .PARAMETER endDate
            End date time of the query - ####-##-## year, month, day = 2017-01-28  
        
        .EXAMPLE
            $result = Get-AzureUsageCSV -key 'apiKeyFromEAPortal' -enrollment 'EAEnrollmentNumber' -startDate '20170515' -endDate '20170602' -outputDir 'c:\'

        .Notes
            Author: Kyle Weeks
    #>

    param 
    (
        [Parameter(Mandatory=$true)]
        [string] $enrollment,

        [Parameter(Mandatory=$true)]
        [string] $key,

        [Parameter(Mandatory=$true)]
        [string]$outputDir,

        [Parameter(Mandatory=$true)]
        [ValidateLength(1,10)]
        [string]$startDate, ####-##-## year, month, day = 2017-01-28

        [Parameter(Mandatory=$true)]
        [ValidateLength(1,10)]
        [string]$endDate ####-##-## year, month, day = 2017-01-28
    )

    Begin{
        $header = @{"authorization"="bearer $key"}
        $uri = "https://consumption.azure.com/v2/enrollments/$enrollment/usagedetails/submit?startTime=$startDate&endTime=$endDate"
        If ($outputDir -notlike '*\') {$outputDir = $outputDir + '\'}
        $outfile = $outputDir+"AzureUsage-"+"$startDate"+"_"+"$endDate"+".csv"
    }

    Process
    {
	    $results = Invoke-WebRequest -Method Post $uri -Headers $header
        $temp = $results.Content |ConvertFrom-Json
        $status = ''

        while ($status -eq '')
            {
            $test = Invoke-WebRequest -Method get -Uri ($temp.reportUrl) -Headers $header
            $json = $test.Content |Convertfrom-Json    
            $status = $json.status
            }

        If ($status -eq '3')
            {
            $results = Invoke-WebRequest -Method post -Uri ($json.blobPath) -Headers $header -OutFile $outfile
            }
    }

    End
    {
        return $results
    }
}

#endregion