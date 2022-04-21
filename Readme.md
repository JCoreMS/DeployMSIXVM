# Deploy Azure VM with MSIX App Attach Tools

Pre-requisites:

- Azure Tenant and Subscription
- Resource Group
- VNet and Subnet
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
