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

        $contentType = 'application/json'
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

        [Parameter(Mandatory)]
        $resource
    )     
     
    Begin
    {
        $uri = "https://login.microsoftonline.com/$tenantID/oauth2/token"
    }

    Process
    {
        $body = @{grant_type="client_credentials";client_id=$clientid;client_secret=$accessKey;resource=$resource}
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

        [Parameter(Mandatory)]
        $resource,

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
            $uri = $authorizeEndpoint+"?client_id=$clientid&response_type=$responseType&resource=$resource&redirect_uri=$redirectUri&prompt=$prompt"
        
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
            $body = @{client_id=$clientid;grant_type=$grantType;code=$authorizationCode;redirect_uri=$redirectUri;client_secret=$accessKey;resource=$resource}
 
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