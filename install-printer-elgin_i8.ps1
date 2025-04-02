# Define variables
$packageFile = "ELGIN-i8.zip"
$baseUri = "https://stgavdprdbrs01-microsoftrouting.blob.core.windows.net/drivers/"
$sas = "sv=2022-11-02&ss=b&srt=co&sp=r&se=2028-01-01T02:59:59Z&st=2025-02-21T03:00:00Z&spr=https&sig=qkDCJAUaSucfOdDYTkmIryQOayzu3oLMGtNXYluzfwE%3D"
$Uri = $baseUri + $packageFile + "?" + $sas
$packageFile = $packageFile.Split("-")[0] + ".zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install ELGIN i8 Driver ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install ELGIN i8 Driver: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install ELGIN i8 Driver: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the ELGIN i8 Driver package
Write-Host "AVD AIB Customization - Install ELGIN i8 Driver: Downloading ELGIN i8 Driver installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install ELGIN i8 Driver: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install ELGIN i8 Driver: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install ELGIN i8 Driver: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install ELGIN i8 Driver: Expanding ELGIN i8 Driver package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install ELGIN i8 Driver: Expanded ELGIN i8 Driver package."

# Install the ELGIN i8 Driver package
Write-Host "AVD AIB Customization - Install ELGIN i8 Driver: Installing the ELGIN i8 Driver..."
$process = Start-Process -FilePath "pnputil.exe" -ArgumentList "/add-driver $(Join-Path $LocalWVDpath '\ELGIN\POSPrinterDriver_x64.inf') /install" -PassThru
$process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()
Add-PrinterDriver -Name "ELGIN i8"
# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install ELGIN i8 Driver: Installed successfully."
    Write-Host "*** AIB Customization - Install ELGIN i8 Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install ELGIN i8 Driver: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install ELGIN i8 Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}