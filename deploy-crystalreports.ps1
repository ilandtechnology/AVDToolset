# Define variables
$Uri = "https://raw.githubusercontent.com/ilandtechnology/AVDToolset/main/crystalreports_xi-sss.msi"
$packageFile = "crystalreports_xi-sss.msi"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Crystal Reports ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Crystal Reports: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Crystal Reports: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Crystal Reports package
Write-Host "AVD AIB Customization - Install Crystal Reports: Downloading Crystal Reports installer from URI: $Uri."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install Crystal Reports: Package downloaded successfully."
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Crystal Reports: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Crystal Reports: Time taken: $elapsedTime ***"
    exit 1
}

# Install the Crystal Reports package
Write-Host "AVD AIB Customization - Install Crystal Reports: Installing the Crystal Reports..."
($process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $(Join-Path $LocalWVDpath $packageFile) /qn /l*v C:\Temp\CRInstall.log ADDLOCAL=ALL ALLUSERS=1 REBOOT=ReallySuppress" -PassThru).PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
pause
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install Crystal Reports: Installed successfully."
    Write-Host "*** AIB Customization - Install Crystal Reports: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Crystal Reports: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Crystal Reports: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}