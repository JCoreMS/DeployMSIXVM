# Deploy Azure VM with MSIX App Attach Tools
This deployment will create a VM from the Microsoft Gallery and configure and install software for use when creating MSIX App attach images.
- MSIX App Attach Store App
- MSIX Manager command line tool
- PSFTooling App
- Disables Plug and Play service (prevents new disk pop-up when mounting VHDs)
- Creates C:\MSIX directory with apps and script to convert MSIX to VHD
- Maps drive to File Share for moving over completed packages used by AVD

## Pre-requisites

- Azure Tenant and Subscription
- Resource Group
- VNet and Subnet
- Storage Account with Azure File Share where completed packages will be stored
- Keyvault for storing credentials (Resource ID)
- Keyvault Secret for VM Local Admin password (URL for 'Secret Identifier')
- Appropriate Permissions on Keyvault and Resource Group to create the VM and read the Keyvault

## Deploy via Portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FJCoreMS%2FDeployMSIXVM%2Fmain%2FDeployMSIX_VM.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FJCoreMS%2FDeployMSIXVM%2Fmain%2FDeployMSIX_VM.json)

## Deploy from PowerShell

You will need the appropriate PowerShell modules installed and connected to Azure.  Then you can run the following from PowerShell:  
```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName <resource-group-name> -TemplateFile https://raw.githubusercontent.com/JCoreMS/DeployMSIXVM/main/DeployMSIX_VM.json
```
