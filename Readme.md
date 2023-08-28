# Deploy Azure VM with MSIX App Attach Tools
This deployment will create a VM from the Microsoft Gallery and configure and install software for use when creating MSIX App attach images.
- MSIX App Attach Store App
- MSIX Manager command line tool
- PSFTooling App
- Disables Plug and Play service (prevents new disk pop-up when mounting VHDs)
- Creates C:\MSIX directory with apps and script to convert MSIX to VHD
- Creates a self-signed certificate and places it within the "Trusted People Store" for signing packages
  (Consider a Certificate from a Certificate Authority for Production Use)

## Pre-requisites

- Azure Tenant and Subscription
- Resource Group
- VNet and Subnet

## Deploy via Portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FJCoreMS%2FDeployMSIXVM%2Fmaster%2Fsolution.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FJCoreMS%2FDeployMSIXVM%2Fmaster%2FuiDefinition.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FJCoreMS%2FDeployMSIXVM%2Fmaster%2Fsolution.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FJCoreMS%2FDeployMSIXVM%2Fmaster%2FuiDefinition.json)

## Deploy from PowerShell

You will need the appropriate PowerShell modules installed and connected to Azure.  Then you can run the following from PowerShell:  
```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName <resource-group-name> -TemplateFile https://raw.githubusercontent.com/JCoreMS/DeployMSIXVM/main/solution.bicep
```
