# Define variables
$Uri = "https://raw.githubusercontent.com/ilandtechnology/AVDToolset/main/ZEBRA.zip"
$packageFile = "ZEBRA.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Zebra ZD220 Driver ***"

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : Creating temp directory."
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
} else {
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : Temp directory already exists."
}
if (-not (Test-Path -Path $LocalWVDpath)) {
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : Creating directory: $LocalWVDpath."
    New-Item -ItemType Directory -Path $LocalWVDpath | Out-Null
} else {
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : $LocalWVDpath already exists."
}

# Download the Zebra ZD220 Driver package
Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : Downloading Zebra ZD220 Driver installer from URI: $Uri."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)

# Check if the file was downloaded successfully
if (Test-Path -Path $(Join-Path $LocalWVDpath $packageFile)) {
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : Package downloaded successfully."
} else {
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : Package failed to download."
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : Expanding Zebra ZD220 Driver package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : Expanded Zebra ZD220 Driver package."

# Install the Zebra ZD220 Driver package
Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : Installing the Zebra ZD220 Driver..."
Start-Process -FilePath "pnputil.exe" -ArgumentList "/a $(Join-Path $LocalWVDpath '\ZEBRA\ZBRN.inf')" -Wait -PassThru | Out-Null
Add-PrinterDriver -Name "ZDesigner ZD220-203dpi ZPL"

# Check the exit code of the installation and cleanup
if ($LASTEXITCODE -eq 0) {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : Installed successfully."
    Write-Host "*** AIB Customization - Install Zebra ZD220 Driver - Time taken: $elapsedTime ***"
} else {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Zebra ZD220 Driver : Installation failed with exit code $LASTEXITCODE."
    Write-Host "*** AIB Customization - Install Zebra ZD220 Driver - Time taken: $elapsedTime ***"
    exit $LASTEXITCODE
}