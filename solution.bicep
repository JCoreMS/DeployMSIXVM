@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '19h1-ent'
  '19h1-ent-gensecond'
  '19h1-entn'
  '19h1-entn-gensecond'
  '19h1-evd'
  '19h1-pro'
  '19h1-pro-gensecond'
  '19h1-pro-zh-cn'
  '19h1-pro-zh-cn-gensecond'
  '19h1-pron'
  '19h1-pron-gensecond'
  '19h2-ent'
  '19h2-ent-g2'
  '19h2-entn'
  '19h2-entn-g2'
  '19h2-evd'
  '19h2-evd-g2'
  '19h2-pro'
  '19h2-pro-g2'
  '19h2-pro-zh-cn'
  '19h2-pro-zh-cn-g2'
  '19h2-pron'
  '19h2-pron-g2'
  '20h1-ent'
  '20h1-ent-g2'
  '20h1-entn'
  '20h1-entn-g2'
  '20h1-evd'
  '20h1-evd-g2'
  '20h1-pro'
  '20h1-pro-g2'
  '20h1-pro-zh-cn'
  '20h1-pro-zh-cn-g2'
  '20h1-pron'
  '20h1-pron-g2'
  '20h2-ent'
  '20h2-ent-g2'
  '20h2-entn'
  '20h2-entn-g2'
  '20h2-evd'
  '20h2-evd-g2'
  '20h2-pro'
  '20h2-pro-g2'
  '20h2-pro-zh-cn'
  '20h2-pro-zh-cn-g2'
  '20h2-pron'
  '20h2-pron-g2'
  '21h1-ent'
  '21h1-ent-g2'
  '21h1-entn'
  '21h1-entn-g2'
  '21h1-evd'
  '21h1-evd-g2'
  '21h1-pro'
  '21h1-pro-g2'
  '21h1-pro-zh-cn'
  '21h1-pro-zh-cn-g2'
  '21h1-pron'
  '21h1-pron-g2'
  'rs1-enterprise'
  'rs1-enterprise-g2'
  'rs1-enterprisen'
  'rs1-enterprisen-g2'
  'RS3-Pro'
  'rs3-pro-test'
  'RS3-ProN'
  'rs4-pro'
  'rs4-pro-g2'
  'rs4-pron'
  'rs5-enterprise'
  'rs5-enterprise-g2'
  'rs5-enterprise-standard'
  'rs5-enterprise-standard-g2'
  'rs5-enterprisen'
  'rs5-enterprisen-g2'
  'rs5-enterprisen-standard'
  'rs5-enterprisen-standard-g2'
  'rs5-evd'
  'rs5-evd-g2'
  'rs5-pro'
  'rs5-pro-g2'
  'rs5-pro-zh-cn-g2'
  'rs5-pron'
  'rs5-pron-g2'
  'win10-21h2-avd'
  'win10-21h2-avd-g2'
  'win10-21h2-ent'
  'win10-21h2-ent-g2'
  'win10-21h2-ent-ltsc'
  'win10-21h2-ent-ltsc-g2'
  'win10-21h2-entn'
  'win10-21h2-entn-g2'
  'win10-21h2-entn-ltsc'
  'win10-21h2-entn-ltsc-g2'
  'win10-21h2-pro'
  'win10-21h2-pro-g2'
  'win10-21h2-pro-zh-cn'
  'win10-21h2-pro-zh-cn-g2'
  'win10-21h2-pron'
  'win10-21h2-pron-g2'
])
param OSVersion string = 'win10-21h2-ent-g2'

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v5'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the virtual machine. (must be 15 characters or less)')
@maxLength(15)
param vmName string = 'vmMSIXTools'

@description('Virtual Network to attach MSIX Tools VM to.')
param VNetName string = 'vnet-eastus2-External'

@description('Subnet to use for MSIX VM Tools VM.')
param SubnetName string = 'sub-eus2-extv-wkstns'

@description('Storage Account where MSIX packages where be stored for AVD. (mapped for ease of copying resulting MSIX packages)')
param StorageAcctName string = 'storeus2avdmsix'

@secure()
@description('Storage Account Key used for mapping drive to MSIX Storage / share.')
param StorageAcctKey string

@description('Share name for MSIX package file share.')
param FileshareName string = 'msix'

@description('Do not change. Used for deployment purposes only.')

var StorageSuffix = environment().suffixes.storage

param Timestamp string = utcNow('u')

resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-MSIXToolsVM'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'nic-MSIXToolsvm'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', VNetName, SubnetName)
          }
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
        offer: 'Windows-10'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
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
