# Define variables
$Uri = "https://raw.githubusercontent.com/ilandtechnology/AVDToolset/main/BEMATECH-MP4200HS.zip"
$packageFile = "BEMATECH.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Bematech MP4200HS Driver ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Bematech MP4200HS Driver: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Bematech MP4200HS Driver: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Bematech MP4200HS Driver package
Write-Host "AVD AIB Customization - Install Bematech MP4200HS Driver: Downloading Bematech MP4200HS Driver installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install Bematech MP4200HS Driver: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Bematech MP4200HS Driver: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Bematech MP4200HS Driver: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install Bematech MP4200HS Driver: Expanding Bematech MP4200HS Driver package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install Bematech MP4200HS Driver: Expanded Bematech MP4200HS Driver package."

# Install the Bematech MP4200HS Driver package
Write-Host "AVD AIB Customization - Install Bematech MP4200HS Driver: Installing the Bematech MP4200HS Driver..."
Start-Process -FilePath "certutil" -ArgumentList " -addstore Root $(Join-Path $LocalWVDpath '\ELGIN\OEM.CER')"
Start-Process -FilePath "certutil" -ArgumentList " -addstore TrustedPublisher $(Join-Path $LocalWVDpath '\ELGIN\OEM.CER')"
$process = Start-Process -FilePath "pnputil.exe" -ArgumentList " /a $(Join-Path $LocalWVDpath '\ELGIN\ELGIN.INF')" -PassThru
$process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()
Add-PrinterDriver -Name "Bematech MP-4200 HS"

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install Bematech MP4200HS Driver: Installed successfully."
    Write-Host "*** AIB Customization - Install Bematech MP4200HS Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Bematech MP4200HS Driver: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Bematech MP4200HS Driver: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}