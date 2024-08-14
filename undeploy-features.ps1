$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Uninstall Windows Features ***"

# Uninstall the WorkFolders-Client feature
$enableResult = 0

Write-Host "AVD AIB Customization - Uninstall Windows Features: Uninstalling the Printing PDF Services..."
Disable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -NoRestart
if( -not $? ) { $enableResult = 1 }
Write-Host "AVD AIB Customization - Uninstall Windows Features: Uninstalling the Printing XPS Services..."
Disable-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features -NoRestart
if( -not $? ) { $enableResult = 1 }
# Write-Host "AVD AIB Customization - Uninstall Windows Features: Uninstalling the PowerShell V2..."
# Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -NoRestart
# if( -not $? ) { $enableResult = 1 }
Write-Host "AVD AIB Customization - Uninstall Windows Features: Uninstalling the WorkFolders-Client..."
Disable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client -NoRestart
if( -not $? ) { $enableResult = 1 }
Write-Host "AVD AIB Customization - Uninstall Windows Features: Uninstalling the Windows Media Player..."
if ([Environment]::OSVersion.Version -ge (New-Object 'Version' 10.0.22000)) { Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart } else { Disable-WindowsOptionalFeature -Online -FeatureName MediaPlayback -NoRestart }
if( -not $? ) { $enableResult = 1 }
# Remove-WindowsCapability -Online -Name Microsoft.Windows.WordPad~~~~
# if( -not $? ) { $enableResult = 1 }
# Remove-WindowsCapability -Online -Name Print.Fax.Scan~~~~0.0.1.0
# if( -not $? ) { $enableResult = 1 }

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($enableResult -eq 0) {
    Write-Host "AVD AIB Customization - Uninstall Windows Features: Uninstall successfully."
    Write-Host "*** AIB Customization - Uninstall Windows Features: Time taken: $elapsedTime ***"
    exit $enableResult
} else {
    Write-Host "AVD AIB Customization - Uninstall Windows Features: Uninstall failed with exit code $enableResult."
    Write-Host "*** AIB Customization - Uninstall Windows Features: Time taken: $elapsedTime ***"
    exit $enableResult
}