$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Windows Features ***"

# Install the .NET Framework 3.5
$enableResult = 0
Write-Host "AVD AIB Customization - Install Windows Features: Installing the NET Framework 3.5..."
Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -NoRestart -ErrorAction Stop
if( -not $? ) { $enableResult = 1 }

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if( $enableResult -eq 0 ) {
    Write-Host "AVD AIB Customization - Install Windows Features: Install successfully."
    Write-Host "*** AIB Customization - Install Windows Features - Time taken: $elapsedTime ***"
    exit $enableResult
} else {
    Write-Host "AVD AIB Customization - Install Windows Features: Install failed with exit code $enableResult."
    Write-Host "*** AIB Customization - Install Windows Features: Time taken: $elapsedTime ***"
    exit $enableResult
}