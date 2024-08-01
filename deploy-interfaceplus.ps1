# Define variables
$Uri = "https://raw.githubusercontent.com/ilandtechnology/AVDToolset/main/interfaceplus.msi"
$packageFile = "interfaceplus.msi"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Interface Plus ***"

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
    Write-Host "AVD AIB Customization - Install Interface Plus : Creating temp directory."
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
} else {
    Write-Host "AVD AIB Customization - Install Interface Plus : Temp directory already exists."
}
if( -not (Test-Path -Path $LocalWVDpath)) {
    Write-Host "AVD AIB Customization - Install Interface Plus : Creating directory: $LocalWVDpath."
    New-Item -ItemType Directory -Path $LocalWVDpath | Out-Null
}
else {
    Write-Host "AVD AIB Customization - Install Interface Plus : $LocalWVDpath already exists."
}

# Download the Interface Plus package
Write-Host "AVD AIB Customization - Install Interface Plus : Downloading Interface Plus installer from URI: $Uri."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $Uri -OutFile $(Join-Path $LocalWVDpath $packageFile)

# Check if the file was downloaded successfully
if (Test-Path -Path $(Join-Path $LocalWVDpath $packageFile)) {
    Write-Host "AVD AIB Customization - Install Interface Plus : Package downloaded successfully."
} else {
    Write-Host "AVD AIB Customization - Install Interface Plus : Package failed to download."
    exit 1
}

# Install the Interface Plus package
Write-Host "AVD AIB Customization - Install Interface Plus : Installing the Interface Plus..."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/package $(Join-Path $LocalWVDpath "interfaceplus.msi") /qb /norestart" -Wait -PassThru | Out-Null

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB Customization - Install Interface Plus - Time taken: $elapsedTime ***"

# Check the exit code of the installation and cleanup
if ($LASTEXITCODE -eq 0) {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    Write-Host "AVD AIB Customization - Install Interface Plus : Installed successfully."
} else {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    Write-Host "AVD AIB Customization - Install Interface Plus : Installation failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}