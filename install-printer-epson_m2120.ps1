# Define variables
$Uri = "https://stavdprdbrs01.blob.core.windows.net/drivers/EPSON-M2120.zip?sv=2023-01-03&st=2024-12-17T13%3A35%3A18Z&se=2030-01-01T02%3A59%3A00Z&sr=b&sp=r&sig=Ax74Ny%2Fs4a86Li3Ajd3vLZ8%2FlkgElBYQMZVvo9OvCmg%3D"
$packageFile = "EPSON.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Epson M2120 Driver ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Epson M2120 Driver: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Epson M2120 Driver: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Epson M2120 Driver package
Write-Host "AVD AIB Customization - Install Epson M2120 Driver: Downloading Epson M2120 Driver installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install Epson M2120 Driver: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Epson M2120 Driver: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Epson M2120 Driver: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install Epson M2120 Driver: Expanding Epson M2120 Driver package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install Epson M2120 Driver: Expanded Epson M2120 Driver package."

# Install the Epson M2120 Driver package
Write-Host "AVD AIB Customization - Install Epson M2120 Driver: Installing the Epson M2120 Driver..."
$process = Start-Process -FilePath "pnputil.exe" -ArgumentList "/a $(Join-Path $LocalWVDpath '\EPSON\E_WF1WZE.INF')" -PassThru
$process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()
Add-PrinterDriver -Name "EPSON M2120 Series"

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install Epson M2120 Driver: Installed successfully."
    Write-Host "*** AIB Customization - Install Epson M2120 Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Epson M2120 Driver: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Epson M2120 Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}