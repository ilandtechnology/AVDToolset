# Define variables
$Uri = "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/92ac27d7-6832-4bac-8205-922458d3df2b/public/windows11.0-kb5040527-x64_4713766dc272c376bee6d39d39a84a85bcd7f1e7.msu"
$packageFile = "windows11.0-kb5040527-x64.msu"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install KB5040527 ***"

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
    Write-Host "AVD AIB Customization - Install KB5040527 : Creating temp directory."
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
} else {
    Write-Host "AVD AIB Customization - Install KB5040527 : Temp directory already exists."
}
if( -not (Test-Path -Path $LocalWVDpath)) {
    Write-Host "AVD AIB Customization - Install KB5040527 : Creating directory: $LocalWVDpath."
    New-Item -ItemType Directory -Path $LocalWVDpath | Out-Null
}
else {
    Write-Host "AVD AIB Customization - Install KB5040527 : $LocalWVDpath already exists."
}

# Install the update
Write-Host "AVD AIB Customization - Install KB5040527 : Installing the KB5040527..."
Start-Process -FilePath "OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait | Out-Null
Disable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client
Enable-WindowsOptionalFeature -Online -FeatureName NetFx3


$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB Customization - Install KB5040527 - Time taken: $elapsedTime ***"

# Check the exit code of the installation and cleanup
if ($LASTEXITCODE -eq 0) {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    Write-Host "AVD AIB Customization - Install KB5040527 : Installed successfully."
} else {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    Write-Host "AVD AIB Customization - Install KB5040527 : Installation failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}