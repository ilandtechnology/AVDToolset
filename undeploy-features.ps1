$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Uninstall Windows Features ***"

# Install the update
Write-Host "AVD AIB Customization - Uninstall Windows Features : Uninstalling the WorkFolders-Client..."
$enableResult = Disable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed

# Check the exit code of the installation and cleanup
if ($enableResult.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Uninstall Windows Features : Uninstall successfully."
    Write-Host "*** AIB Customization - Uninstall Windows Features - Time taken: $elapsedTime ***"
} else {
    Write-Host "AVD AIB Customization - Uninstall Windows Features : Uninstall failed with exit code $($enableResult.ExitCode)."
    Write-Host "*** AIB Customization - Uninstall Windows Features - Time taken: $elapsedTime ***"
    exit $enableResult.ExitCode
}