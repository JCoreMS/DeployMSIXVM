# Prerequisites
# Stage the application and its associated conversion XML file in an Azure Storage Account Container
# Established an SMB share for the MSIX App Attach images

Param(

    [parameter(Mandatory)]
    [string]$FileShareName,

    [parameter(Mandatory)]
    [string]$StorageAccountKey,

    [parameter(Mandatory)]
    [string]$StorageAccountName,

    [parameter(Mandatory)]
    [string]$VMUserName,

    [parameter(Mandatory)]
    [String]$VMUserPassword,

    [parameter(Mandatory)]
    [string]$StorageSuffix
)

# Create Log file for output and troublehsooting
$Log = "C:\PostConfig.log"
New-Item $Log
Get-Date | Out-file $Log

$Username = $ENV:COMPUTERNAME + '\' + $VMUserName
$Password = ConvertTo-SecureString -String $VMUserPassword -AsPlainText -Force
[pscredential]$Credential = New-Object System.Management.Automation.PSCredential ($Username, $Password)

$Username | Out-File $Log -Append

$Error.Clear()

#Install NuGet and Hyper-V tools
"Installing NuGet Provider needed for Hyper-V module" | Out-File $Log -Append
Install-PackageProvider -Name NuGet -Force
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

"Installing Hyper-V Windows Component needed to convert MSIX to VHD" | Out-File $Log -Append
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

"Installing Azure PowerShell Cmdlets" | Out-File $Log -Append
Install-Module -Name Az.Storage -Force
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

#Make Local MSIX Dir for tools
"Creating Directories" | Out-File $Log -Append
New-Item -Path "C:\MSIX" -ItemType Directory
New-Item -Path "C:\MSIX\Packages" -ItemType Directory
New-Item -Path "C:\MSIX\Scripts" -ItemType Directory
New-Item -Path "C:\MSIX\MSIXPackagingTool" -ItemType Directory
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

# Downloads and extracts the MSIX Manager Tool
"Downloading and Extracting the MSIX Manager Command Line tool" | Out-File $Log -Append
Invoke-WebRequest -URI "https://aka.ms/msixmgr" -OutFile "C:\MSIX\MSIXmgrTool.zip"
Expand-Archive -Path "C:\MSIX\MSIXmgrTool.zip" -DestinationPath "C:\MSIX\msixmgr"
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

# Download Script to convert MSIX to VHD
"Downloading MSIX to VHD Script" | Out-File $Log -Append
Invoke-WebRequest -URI "https://raw.githubusercontent.com/JCoreMS/DeployMSIXVM/main/Scripts/ConvertMSIX2VHD.ps1" -OutFile "C:\MSIX\Scripts\ConvertMSIX2VHD.ps1"
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

# Configure NIC to Private (Dependency for PSRemoting)
"Set Network Adapter to Private Profile (req'd for PSRemoting)" | Out-file $Log -Append
Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Private
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

# Download the MSIX Packaging Tool
"Downloading MSIX Packaging Tool" | Out-File $Log -Append
Invoke-WebRequest -Uri "https://download.microsoft.com/download/d/9/7/d9707be8-06db-4b13-a992-48666aad8b78/91b9474c34904fe39de2b66827a93267.msixbundle" -OutFile "C:\MSIX\MsixPackagingTool.msixbundle"
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

# Download the PFSTooling Tool
"Downloading PSFTooling Tool" | Out-File $Log -Append
Invoke-WebRequest -URI "https://www.tmurgent.com/APPV/Tools/PsfTooling/PsfTooling-x64-5.0.0.0.msix" -OutFile "C:\MSIX\PsfTooling-x64-5.0.0.0.msix"
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

"Enabling PSRemoting" | Out-file $Log -Append
Enable-PSRemoting -Force
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

$FileShare = '\\' + $StorageAccountName + '.file.' + $StorageSuffix + '\' + $FileShareName
$Username = 'Azure\' + $StorageAccountName

Invoke-Command -ComputerName $ENV:COMPUTERNAME -Credential $Credential -ScriptBlock {
    # Installs the MSIX Packaging Tool
    "Installing MSIX Packaging Tool as $Using:VMUserName" | Out-File $Using:Log -Append
    Add-AppPackage -Path "C:\MSIX\MSIXPackagingTool.msixbundle"
    If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Using:Log -Append}
    Else{"-----ERROR-----> $Error" | Out-File $Using:Log -Append; $Error.Clear()}

    # Downloads and installs the PFSTooling Tool
    "Installing PSFTooling Tool as $Using:VMUserName" | Out-File $Using:Log -Append
    Add-AppPackage -Path "C:\MSIX\PsfTooling-x64-5.0.0.0.msix"
    If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Using:Log -Append}
    Else{"-----ERROR-----> $Error" | Out-File $Using:Log -Append; $Error.Clear()}

    # Map Drive for MSIX Share
    "Mapping MSIX Share to M:" | Out-File $Using:Log -Append
    # cmd.exe /C "net use M: `\\$Using:StorageAccountName.file.core.windows.net\$Using:FileShareName $Using:StorageAccountKey /u:AZURE\$Using:StorageAccountName /persistent:yes" | Out-File $Using:Log -Append
    "$($Using:FileShare)" | Out-File $Using:Log -Append
    "$($Using:Username)" | Out-File $Using:Log -Append
    $Password = ConvertTo-SecureString -String "$($Using:StorageAccountKey)" -AsPlainText -Force
    [pscredential]$Credential = New-Object System.Management.Automation.PSCredential ($Using:Username, $Password)
    New-SmbGlobalMapping -RemotePath $Using:FileShare -Credential $Credential -LocalPath 'M:'
    
    If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Using:Log -Append}
    Else{"-----ERROR-----> $Error" | Out-File $Using:Log -Append; $Error.Clear()}
   
}

Disable-PSRemoting -Force

# Stops the Shell HW Detection service to prevent the format disk popup
"Stoping Plug and Play Service and setting to disabled" | Out-file $Log -Append
Stop-Service -Name ShellHWDetection -Force
set-service -Name ShellHWDetection -StartupType Disabled
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

# Turn off auto updates
"Turn Off Auto Updates via Registry and Disable Scheduled Tasks" | Out-File $Log -Append
reg add HKLM\Software\Policies\Microsoft\WindowsStore /v AutoDownload /t REG_DWORD /d 0 /f
Schtasks /Change /Tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /Disable
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

# Disable Content Delivery auto download apps that they want to promote to users:
"Disable Content Delivery auto download apps" | Out-File $Log -Append
reg add HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Debug /v ContentDeliveryAllowedOverride /t REG_DWORD /d 0x2 /f
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

"Set Network Adapter back to Prublic Profile" | Out-file $Log -Append
Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Public
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

# Create and install Self-Signed Code Signing Certificate
"Creating Self Signed Code Signing Certificate" | Out-File $Log -Append
$Cert = New-SelfSignedCertificate -FriendlyName "MSIX App Attach Test CodeSigning" -CertStoreLocation Cert:\LocalMachine\My -Subject "MSIXAppAttachTest" -Type CodeSigningCert
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

"Moving Cert from Personal to Trusted People Store on Local Machine"
$Cert | Move-Item -Destination cert:\LocalMachine\TrustedPeople | Out-File $Log -Append
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}

"-------------------------- END SCRIPT RUN ------------------------" | Out-File $Log -Append

"Rebooting VM...." | Out-File $Log -Append
Restart-Computer -Force
If($Error.Count -eq 0){".... COMPLETED!" | Out-File $Log -Append}
Else{"-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear()}
