# Define variables
$packageFile = "HP-120X.zip"
$baseUri = "https://stgavdprdbrs01-microsoftrouting.blob.core.windows.net/drivers/"
$sas = "sv=2022-11-02&ss=b&srt=co&sp=r&se=2028-01-01T02:59:59Z&st=2025-02-21T03:00:00Z&spr=https&sig=qkDCJAUaSucfOdDYTkmIryQOayzu3oLMGtNXYluzfwE%3D"
$Uri = $baseUri + $packageFile + "?" + $sas
$packageFile = $packageFile.Split("-")[0] + ".zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the HP Neverstop Laser MFP 120x PCLm-S Driver package
Write-Host "AVD AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Downloading HP Neverstop Laser MFP 120x PCLm-S Driver installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Unblock-File -Path $(Join-Path $LocalWVDpath $packageFile) -Confirm:$false
    Write-Host "AVD AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Expanding HP Neverstop Laser MFP 120x PCLm-S Driver package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Expanded HP Neverstop Laser MFP 120x PCLm-S Driver package."

# Install the HP Neverstop Laser MFP 120x PCLm-S Driver package
Write-Host "AVD AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Installing the HP Neverstop Laser MFP 120x PCLm-S Driver..."
$process = Start-Process -FilePath "pnputil.exe" -ArgumentList "/a $(Join-Path $LocalWVDpath '\HP\HPYPCLMS29_V4.INF')" -PassThru
$process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()
Add-PrinterDriver -Name "HP Neverstop Laser MFP 120x PCLm-S"

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Installed successfully."
    Write-Host "*** AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install HP Neverstop Laser MFP 120x PCLm-S Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}