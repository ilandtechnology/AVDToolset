$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Uninstall Windows Features ***"

# Install the update
Write-Host "AVD AIB Customization - Uninstall Windows Features : Uninstalling the WorkFolders-Client..."
Disable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB Customization - Uninstall Windows Features - Time taken: $elapsedTime ***"

# Check the exit code of the installation and cleanup
if ($LASTEXITCODE -eq 0) {
    Write-Host "AVD AIB Customization - Uninstall Windows Features : Uninstall successfully."
} else {
    Write-Host "AVD AIB Customization - Uninstall Windows Features : Uninstall failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}