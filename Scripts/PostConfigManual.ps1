
Install-PackageProvider -Name NuGet -Force
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
Install-Module -Name Az.Storage -Force -Verbose
New-Item -Path "C:\MSIX" -ItemType Directory
New-Item -Path "C:\MSIX\Packages" -ItemType Directory
New-Item -Path "C:\MSIX\Scripts" -ItemType Directory
Invoke-WebRequest -URI "https://aka.ms/msixmgr" -OutFile "C:\MSIX\MSIXmgrTool.zip"
Expand-Archive -Path "C:\MSIX\MSIXmgrTool.zip" -DestinationPath "C:\MSIX\msixmgr"
Invoke-WebRequest -URI "https://raw.githubusercontent.com/JCoreMS/DeployMSIXVM/main/Scripts/ConvertMSIX2VHD.ps1" -OutFile "C:\MSIX\Scripts\ConvertMSIX2VHD.ps1"
Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Private
Invoke-WebRequest -Uri "https://download.microsoft.com/download/d/9/7/d9707be8-06db-4b13-a992-48666aad8b78/91b9474c34904fe39de2b66827a93267.msixbundle" -OutFile "C:\MSIX\MsixPackagingTool.msixbundle"
Invoke-WebRequest -URI "https://www.tmurgent.com/APPV/Tools/PsfTooling/PsfTooling-x64-5.0.0.0.msix" -OutFile "C:\MSIX\PsfTooling-x64-5.0.0.0.msix"
Add-AppPackage -Path "C:\MSIX\MsixPackagingTool.msixbundle"
Add-AppPackage -Path "C:\MSIX\PsfTooling-x64-5.0.0.0.msix"
Stop-Service -Name ShellHWDetection -Force
set-service -Name ShellHWDetection -StartupType Disabled
reg add HKLM\Software\Policies\Microsoft\WindowsStore /v AutoDownload /t REG_DWORD /d 0 /f
Schtasks /Change /Tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /Disable
reg add HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Debug /v ContentDeliveryAllowedOverride /t REG_DWORD /d 0x2 /f
Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Public
$Cert = New-SelfSignedCertificate -FriendlyName "MSIX App Attach Test CodeSigning" -CertStoreLocation Cert:\LocalMachine\My -Subject "MSIXAppAttachTest" -Type CodeSigningCert
$Cert | Move-Item -Destination cert:\LocalMachine\TrustedPeople
