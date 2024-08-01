$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Windows Features ***"

# Install the update
Write-Host "AVD AIB Customization - Install Windows Features : Installing the NET Framework 3.5..."
Enable-WindowsOptionalFeature -Online -FeatureName NetFx3

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB Customization - Install Windows Features - Time taken: $elapsedTime ***"

# Check the exit code of the installation and cleanup
if ($LASTEXITCODE -eq 0) {
    Write-Host "AVD AIB Customization - Install Windows Features : Install successfully."
} else {
    Write-Host "AVD AIB Customization - Install Windows Features : Install failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}