$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Windows Features ***"

# Install the .NET Framework 3.5
Write-Host "AVD AIB Customization - Install Windows Features : Installing the NET Framework 3.5..."
$enableResult = Enable-WindowsOptionalFeature -Online -FeatureName NetFx3

# Check the exit code of the installation and cleanup
if ($enableResult.ExitCode -eq 0) {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Windows Features : Install successfully."
    Write-Host "*** AIB Customization - Install Windows Features - Time taken: $elapsedTime ***"
} else {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Windows Features : Install failed with exit code $($enableResult.ExitCode)."
    Write-Host "*** AIB Customization - Install Windows Features - Time taken: $elapsedTime ***"
    exit $enableResult.ExitCode
}