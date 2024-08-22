# Define variables
$Uri = "https://raw.githubusercontent.com/ilandtechnology/AVDToolset/main/ZEBRA-ZD220.zip"
$packageFile = "ZEBRA.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Zebra ZD220 Driver ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Zebra ZD220 Driver package
Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver: Downloading Zebra ZD220 Driver installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Zebra ZD220 Driver: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver: Expanding Zebra ZD220 Driver package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver: Expanded Zebra ZD220 Driver package."

# Install the Zebra ZD220 Driver package
Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver: Installing the Zebra ZD220 Driver..."
$process = Start-Process -FilePath "pnputil.exe" -ArgumentList "/a $(Join-Path $LocalWVDpath '\ZEBRA\ZBRN.inf')" -PassThru
$process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()
Add-PrinterDriver -Name "ZDesigner ZD220-203dpi ZPL"

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver: Installed successfully."
    Write-Host "*** AIB Customization - Install Zebra ZD220 Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Zebra ZD220 Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}