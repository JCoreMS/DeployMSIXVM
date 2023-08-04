@description('Username for the Virtual Machine.')
param adminUsername string = 'jcore'

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Create the VM with a Public IP to access the Virtual Machine?')
param publicIPAllowed bool = false

@description('The Windows version for the VM.')
param OSoffer string

@description('The Windows build version for the VM.')
param OSVersion string = 'win11-22h2-ent'

@description('Size of the virtual machine.')
param vmDiskType string

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v5'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the virtual machine. (must be 15 characters or less)')
@maxLength(15)
param vmName string = 'vmMSIXTools'

@description('Virtual Network to attach MSIX Tools VM to.')
param VNet object = {
  name: ''
  id: ''
  location: ''
  subscriptionName: ''
}

@description('Subnet to use for MSIX VM Tools VM.')
param SubnetName string

@description('Storage Account where MSIX packages where be stored for AVD. (mapped for ease of copying resulting MSIX packages)')
param StorageAcctName string

@secure()
@description('Storage Account Key used for mapping drive to MSIX Storage / share.')
param StorageAcctKey string

@description('Share name for EXISTING MSIX package file share.')
param FileshareName string = 'msix'

@description('Do not change. Used for deployment purposes only.')
param Timestamp string = utcNow('u')


var StorageSuffix = environment().suffixes.storage

resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = if(publicIPAllowed) {
  name: 'pip-${vmName}'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'nic-${vmName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${VNet.id}/subnets/${SubnetName}'
          }
          publicIPAddress: publicIPAllowed ? {
            id: pip.id
          } : null
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: OSoffer
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: vmDiskType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', nic.name)
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource configVm 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  name: 'VmExtension-PowerShell-CustomizeMSIXTools'
  location: location
  parent: vm
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
      fileUris: [ 'https://raw.githubusercontent.com/JCoreMS/DeployMSIXVM/main/Scripts/New-AzureMsixAppAttachImage.ps1' ]
      timestamp: Timestamp
    }
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File New-AzureMsixAppAttachImage.ps1 -FileShareName ${FileshareName} -StorageAccountKey ${StorageAcctKey} -StorageAccountName $${StorageAcctName} -VMUserName ${adminUsername} -VMUserPassword ${adminPassword} -StorageSuffix ${StorageSuffix}'
    }
  }
}
