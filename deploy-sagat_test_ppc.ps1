# Define variables
$Uri = "https://raw.githubusercontent.com/ilandtechnology/AVDToolset/main/SAGAT_Test_PPC.exe"
$packageFile = "SAGAT_Test_PPC.exe"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install SAGAT Test PPC ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Install SAGAT Test PPC package
Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Downloading Install SAGAT Test PPC installer from URI: $Uri."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Package downloaded successfully."
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Install SAGAT Test PPC: Time taken: $elapsedTime ***"
    exit 1
}

# Install the Install SAGAT Test PPC package
Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Installing the Install SAGAT Test PPC..."
($process = Start-Process -FilePath $(Join-Path $LocalWVDpath $packageFile) -ArgumentList "/S" -PassThru).PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
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
    Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Installed successfully."
    Write-Host "*** AIB Customization - Install Install SAGAT Test PPC: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Install SAGAT Test PPC: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}