$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Uninstall Windows Features ***"

# Uninstall the WorkFolders-Client feature
$enableResult = 0
Write-Host "AVD AIB Customization - Uninstall Windows Features : Uninstalling the WorkFolders-Client..."
if ([Environment]::OSVersion.Version -ge (New-Object 'Version' 10.0.22000)) { Disable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client -NoRestart }
if( -not $? ) { $enableResult = 1 }
Write-Host "AVD AIB Customization - Uninstall Windows Features : Uninstalling the Windows Media Player..."
if ([Environment]::OSVersion.Version -ge (New-Object 'Version' 10.0.22000)) { Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart }
if( -not $? ) { $enableResult = 1 }

# Check the exit code of the installation and cleanup
if ( $enableResult -eq 0 ) {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Uninstall Windows Features : Uninstall successfully."
    Write-Host "*** AIB Customization - Uninstall Windows Features - Time taken: $elapsedTime ***"
} else {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Uninstall Windows Features : Uninstall failed with exit code $enableResult."
    Write-Host "*** AIB Customization - Uninstall Windows Features - Time taken: $elapsedTime ***"
    exit $enableResult
}