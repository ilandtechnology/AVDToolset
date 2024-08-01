$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Uninstall OneDrive ***"

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
    Write-Host "AVD AIB Customization - Uninstall OneDrive : Creating temp directory."
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
} else {
    Write-Host "AVD AIB Customization - Uninstall OneDrive : Temp directory already exists."
}
if( -not (Test-Path -Path $LocalWVDpath)) {
    Write-Host "AVD AIB Customization - Uninstall OneDrive : Creating directory: $LocalWVDpath."
    New-Item -ItemType Directory -Path $LocalWVDpath | Out-Null
}
else {
    Write-Host "AVD AIB Customization - Uninstall OneDrive : $LocalWVDpath already exists."
}

# Install the update
Write-Host "AVD AIB Customization - Uninstall OneDrive : Uninstalling the OneDrive..."
Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
Start-Process -FilePath "OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait | Out-Null


$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB Customization - Uninstall OneDrive - Time taken: $elapsedTime ***"

# Check the exit code of the installation and cleanup
if ($LASTEXITCODE -eq 0) {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    Write-Host "AVD AIB Customization - Uninstall OneDrive : Installed successfully."
} else {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    Write-Host "AVD AIB Customization - Uninstall OneDrive : Installation failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}