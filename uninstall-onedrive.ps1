$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Uninstall OneDrive ***"

# Install the update
Write-Host "AVD AIB Customization - Uninstall OneDrive: Uninstalling the OneDrive..."

if (Test-Path -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe) {
    Write-Host "AVD AIB Customization - Uninstall OneDrive: OneDrive is installed."
    $process = Start-Process -FilePath $(Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe -Name UninstallString -ErrorAction SilentlyContinue).UninstallString.Replace("""","").Split("/")[0] -ArgumentList "/uninstall /allusers" -PassThru
    $process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
    $process.WaitForExit()
} elseif (Test-Path -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe) {
    Write-Host "AVD AIB Customization - Uninstall OneDrive: OneDrive is installed."
    $process = Start-Process -FilePath $(Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe -Name UninstallString -ErrorAction SilentlyContinue).UninstallString.Replace("""","").Split("/")[0] -ArgumentList "/uninstall /allusers" -PassThru
    $process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
    $process.WaitForExit()
} else {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Uninstall OneDrive: OneDrive is not installed."
    Write-Host "*** AIB Customization - Uninstall OneDrive - Time taken: $elapsedTime ***"
    exit 0
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Uninstall OneDrive: Uninstall successfully."
    Write-Host "*** AIB Customization - Uninstall OneDrive - Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Uninstall OneDrive: Uninstall successfully."
    Write-Host "AVD AIB Customization - Uninstall OneDrive: Uninstall failed with exit code $($process.ExitCode)."
    exit $process.ExitCode
}