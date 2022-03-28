 
<#Author       : Jonathan Core
# Creation Date: 03-28-2022
# Usage        : Expand ALL MSIX packages in a folder to VHDx in subfolder


********************************************************************************
Date                         Version      Changes
------------------------------------------------------------------------
03/28/2022                     1.0        Intial Version


*********************************************************************************

Folder Structure - 
Ensure you run the script from within the folder where your MSIX
Packages Reside and have extracted the MSIXMgr tool within that folder. The script
will call the x64 version and can be changed below if x86 is desired. It will then 
create a VHDxFiles folder where the images are extracted. 
#>


$Packages = Get-ChildItem -Path "C:\MSIX\Packages\" -File *.msix
Write-Host "Extracting MSIX files to VHD...."

$VHDxFolder = "C:\MSIX\VHDxFiles"

if (!(Test-Path $VHDxFolder))
{
write-host "-------> VHDxFiles Subfolder being created." -ForegroundColor Yellow
New-Item -itemType Directory $VHDxFolder
}
else
{
write-host "-------> VHDxFiles Subfolder already exists, continuing..." -ForegroundColor Green
}

write-host "-------> Stoping HW Shell Service temporarily. This will suppress format prompts as VHDs are mounted."  -ForegroundColor Green

# This prevents the format drive popup after each VHD is mounted, restarted at end of run
Stop-Service -Name ShellHWDetection  

Foreach($file in $Packages){
    Write-Host "-------> Working on:" $file.Name -ForegroundColor Green

    $pkgpath = $file.Name
    $VHDFile = $VHDxFolder +"\"+$File.BaseName + ".vhdx"


    #Create VHD file 
    New-VHD -SizeBytes 1GB -Path $VHDFile -Dynamic -Confirm:$false
    $vhdObject = Mount-VHD $VHDFile -Passthru
    $disk = Initialize-Disk -Passthru -Number $vhdObject.Number
    $partition = New-Partition -AssignDriveLetter -UseMaximumSize -DiskNumber $disk.Number
    Format-Volume -FileSystem NTFS -Confirm:$false -DriveLetter $partition.DriveLetter -Force

    $MSIXPath = $partition.driveletter+":\apps"
    ## $destination = $partition.driveletter + ":\" + $FileName

    #Extract package
    & ".\msixmgr\x64\msixmgr.exe" -Unpack -packagePath $pkgpath -destination $MSIXPath -applyacls

    #Disconnect VHD
    Dismount-VHD -Path $VHDFile
}

write-host "-------> Starting HW Shell Service back up."  -ForegroundColor Green
Start-Service -Name ShellHWDetection
Write-Host "Completed! Files are located in $VHDxFolder" -ForegroundColor Green