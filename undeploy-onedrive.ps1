$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Uninstall OneDrive ***"

# Install the update
Write-Host "AVD AIB Customization - Uninstall OneDrive : Uninstalling the OneDrive..."
Start-Process -FilePath "OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait | Out-Null

# Check the exit code of the installation and cleanup
if ($LASTEXITCODE -eq 0) {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Uninstall OneDrive : Uninstall successfully."
    Write-Host "*** AIB Customization - Uninstall OneDrive - Time taken: $elapsedTime ***"
} else {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Uninstall OneDrive : Uninstall successfully."
    Write-Host "AVD AIB Customization - Uninstall OneDrive : Uninstall failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}