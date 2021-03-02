# UMN-Azure

A powerShell module building out on basic public cloud consumption.

Three areas of focus.

First on deploying basic VM infrastrucutre using templates.

Second on azure billing and usage consumption.

Third on graph API access query.

# Releases

## 1.2.4 3-2-21

Add cmdlets for Consumption API. Get-AzureReservedInstanceConsumption,
Get-AzureMarketplaceConsumption, and Get-AzureEnrollmentConsumption.
All require a user_impersonation accessToken. See Az Cli for such as
az login -u user -p pass
az account get-access-token

## 1.2.3 12-30-19
Update azure billing api to use invoke-restmethod.

## 1.2.2 12-16-19
Update Billing API to V3.
Add Azure Reserve Instance billing function.

## 1.2.1 7-17-18
Add LogAnalytic write data functions.

## 1.2.0 6-7-18
Add OneDrive cmdlets for access through the Graph API.

## 1.1.1 -- 2-15-18
Add Code Signing

## Prior to 1.1.1
Initial public release of working module for Azure public cloud
