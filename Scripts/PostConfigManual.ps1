
$MSIXPackageURL = "https://download.microsoft.com/download/d/0/0/d0043667-b1db-4060-9c82-eaee1fa619e8/493b543c21624db8832da8791ebf98f3.msixbundle"

$PsfToolPackageURL = "https://www.tmurgent.com/AppV/Tools/PsfTooling/PsfTooling-6.3.0.0-x64.msix"

Write-Host "Installing NuGet package provider..."
Install-PackageProvider -Name NuGet -Force
Write-Host "Installing Hyper-V feature..."
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
Write-Host "Installing Az Storage module..."
Install-Module -Name Az.Storage -Force -Verbose
Write-Host "Creating needed folders C:\MSIX..."
New-Item -Path "C:\MSIX" -ItemType Directory
New-Item -Path "C:\MSIX\Packages" -ItemType Directory
New-Item -Path "C:\MSIX\Scripts" -ItemType Directory
Write-Host "Downloading MSIX Manager Tool..."
Invoke-WebRequest -URI "https://aka.ms/msixmgr" -OutFile "C:\MSIX\MSIXmgrTool.zip"
Write-Host "Expanding ZIP file for MSIX Manager tool..."
Expand-Archive -Path "C:\MSIX\MSIXmgrTool.zip" -DestinationPath "C:\MSIX\msixmgr"
Write-Host "Downloading utility script Convert MSIX to VHD from JCoreMS Repo..."
Invoke-WebRequest -URI "https://raw.githubusercontent.com/JCoreMS/DeployMSIXVM/main/Scripts/ConvertMSIX2VHD.ps1" -OutFile "C:\MSIX\Scripts\ConvertMSIX2VHD.ps1"
Write-Host "Setting NIC profile to Private..."
Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Private
Write-Host "Downloading MSIX Packaging Tool from Windows Store..."
Invoke-WebRequest -Uri $MSIXPackageURL -OutFile "C:\MSIX\MsixPackagingTool.msixbundle"
Write-Host "Downloading PSF Toolling app from Windows Store..."
Invoke-WebRequest -URI $PsfToolPackageURL -OutFile "C:\MSIX\PsfTooling-x64.msix"
Write-Host "Installing MSIX Packaging Tool..."
Add-AppPackage -Path "C:\MSIX\MSIXPackagingTool.msixbundle"
Write-Host "Installing PSF Tooling app..."
Add-AppPackage -Path "C:\MSIX\PsfTooling-x64.msix"
Write-Host "Stopping ShellHWDetection (Plug and Play) service and setting to disabled..."
Write-Host "  This prevents pop-up when mounting VHDs." -ForegroundColor Cyan
Stop-Service -Name ShellHWDetection -Force
set-service -Name ShellHWDetection -StartupType Disabled
Write-Host "Disabling Windows Updates and Windows Store updates..."
reg add HKLM\Software\Policies\Microsoft\WindowsStore /v AutoDownload /t REG_DWORD /d 0 /f
Schtasks /Change /Tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /Disable
reg add HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Debug /v ContentDeliveryAllowedOverride /t REG_DWORD /d 0x2 /f
Write-Host "Setting NIC profile back to Public..."
Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Public
Write-Host "Creating Self Signed Certificate for testing purposes and saving to TrustedPeople store..."
$Cert = New-SelfSignedCertificate -FriendlyName "MSIX App Attach Test CodeSigning" -CertStoreLocation Cert:\LocalMachine\My -Subject "MSIXAppAttachTest" -Type CodeSigningCert
$Cert | Move-Item -Destination cert:\LocalMachine\TrustedPeople
Write-Host "DONE!" -ForegroundColor Green