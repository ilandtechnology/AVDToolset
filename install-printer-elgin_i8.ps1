# Define variables
$Uri = "https://stavdprdbrs01.blob.core.windows.net/drivers/ELGIN-i8.zip?sv=2023-01-03&st=2024-12-16T22%3A50%3A07Z&se=2030-01-01T02%3A59%3A00Z&sr=b&sp=r&sig=xRzynjSORXW8mAVMz4rgBHykSXNzBoq9aCgVSYkUlF0%3D"
$packageFile = "ELGIN.zip"
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
pause
$process = Start-Process -FilePath "pnputil.exe" -ArgumentList "/add-driver $(Join-Path $LocalWVDpath '\ELGIN\POSPrinterDriver_x64.inf') /install" -PassThru
$process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()
Add-PrinterDriver -Name "ELGIN i8"
pause
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