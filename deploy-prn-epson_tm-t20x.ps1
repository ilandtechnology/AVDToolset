# Define variables
$Uri = "https://raw.githubusercontent.com/ilandtechnology/AVDToolset/main/EPSON.zip"
$packageFile = "EPSON.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Epson TM-T20X Driver ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Epson TM-T20X Driver: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Epson TM-T20X Driver: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Epson TM-T20X Driver package
Write-Host "AVD AIB Customization - Install Epson TM-T20X Driver: Downloading Epson TM-T20X Driver installer from URI: $Uri."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install Epson TM-T20X Driver: Package downloaded successfully."
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Epson TM-T20X Driver: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Epson TM-T20X Driver: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install Epson TM-T20X Driver: Expanding Epson TM-T20X Driver package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install Epson TM-T20X Driver: Expanded Epson TM-T20X Driver package."

# Install the Epson TM-T20X Driver package
Write-Host "AVD AIB Customization - Install Epson TM-T20X Driver: Installing the Epson TM-T20X Driver..."
($process = Start-Process -FilePath "pnputil.exe" -ArgumentList "/a $(Join-Path $LocalWVDpath '\EPSON\EA6INSTMT.INF')" -PassThru).PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()
Add-PrinterDriver -Name "EPSON TM-T(203dpi) Receipt6"

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install Epson TM-T20X Driver: Installed successfully."
    Write-Host "*** AIB Customization - Install Epson TM-T20X Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Epson TM-T20X Driver: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Epson TM-T20X Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}