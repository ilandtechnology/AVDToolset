# Define variables
$Uri = "https://stavdprdbrs01.blob.core.windows.net/drivers/SAMSUNG-M2835DW.zip?sv=2023-01-03&st=2024-12-16T22%3A48%3A56Z&se=2030-01-01T02%3A59%3A00Z&sr=b&sp=r&sig=PdEW87Z7pj0dsmNxLgR5OOkG7v87e1KyaZY2y6VqzJA%3D"
$packageFile = "SAMSUNG.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Samsung M2835DW Driver ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Samsung M2835DW Driver: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Samsung M2835DW Driver: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Samsung M2835DW Driver package
Write-Host "AVD AIB Customization - Install Samsung M2835DW Driver: Downloading Samsung M2835DW Driver installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install Samsung M2835DW Driver: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Samsung M2835DW Driver: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Samsung M2835DW Driver: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install Samsung M2835DW Driver: Expanding Samsung M2835DW Driver package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install Samsung M2835DW Driver: Expanded Samsung M2835DW Driver package."

# Install the Samsung M2835DW Driver package
Write-Host "AVD AIB Customization - Install Samsung M2835DW Driver: Installing the Samsung M2835DW Driver..."
$process = Start-Process -FilePath "pnputil.exe" -ArgumentList "/add-driver $(Join-Path $LocalWVDpath '\SAMSUNG\ssk5m.inf') /install" -PassThru
$process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()
Add-PrinterDriver -Name "Samsung M283x Series"

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install Samsung M2835DW Driver: Installed successfully."
    Write-Host "*** AIB Customization - Install Samsung M2835DW Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Samsung M2835DW Driver: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Samsung M2835DW Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}