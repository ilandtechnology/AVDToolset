$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Uninstall OneDrive ***"

# Install the update
Write-Host "AVD AIB Customization - Uninstall OneDrive : Uninstalling the OneDrive..."
Start-Process -FilePath "OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait | Out-Null

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB Customization - Uninstall OneDrive - Time taken: $elapsedTime ***"

# Check the exit code of the installation and cleanup
if ($LASTEXITCODE -eq 0) {
    Write-Host "AVD AIB Customization - Uninstall OneDrive : Uninstall successfully."
} else {
    Write-Host "AVD AIB Customization - Uninstall OneDrive : Uninstall failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}