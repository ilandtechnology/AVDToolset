# Define variables
$Uri = "https://raw.githubusercontent.com/ilandtechnology/AVDToolset/main/crystalreports_xi-sss.msi"
$packageFile = "crystalreports_xi-sss.msi"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Cristal Reports XI ***"

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
    Write-Host "AVD AIB Customization - Install Cristal Reports XI : Creating temp directory."
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
} else {
    Write-Host "AVD AIB Customization - Install Cristal Reports XI : Temp directory already exists."
}
if( -not (Test-Path -Path $LocalWVDpath)) {
    Write-Host "AVD AIB Customization - Install Cristal Reports XI : Creating directory: $LocalWVDpath."
    New-Item -ItemType Directory -Path $LocalWVDpath | Out-Null
}
else {
    Write-Host "AVD AIB Customization - Install Cristal Reports XI : $LocalWVDpath already exists."
}

# Download the Cristal Reports XI package
Write-Host "AVD AIB Customization - Install Cristal Reports XI : Downloading Cristal Reports XI installer from URI: $Uri."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $Uri -OutFile $(Join-Path $LocalWVDpath $packageFile)

# Check if the file was downloaded successfully
if (Test-Path -Path $(Join-Path $LocalWVDpath $packageFile)) {
    Write-Host "AVD AIB Customization - Install Cristal Reports XI : Package downloaded successfully."
} else {
    Write-Host "AVD AIB Customization - Install Cristal Reports XI : Package failed to download."
    exit 1
}

# Install the Cristal Reports XI package
Write-Host "AVD AIB Customization - Install Cristal Reports XI : Installing the Cristal Reports XI..."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/package $(Join-Path $LocalWVDpath "crystalreports_xi-sss.msi") /qb /norestart" -Wait -PassThru | Out-Null

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB Customization - Install Cristal Reports XI - Time taken: $elapsedTime ***"

# Check the exit code of the installation and cleanup
if ($LASTEXITCODE -eq 0) {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    Write-Host "AVD AIB Customization - Install Cristal Reports XI : Installed successfully."
} else {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    Write-Host "AVD AIB Customization - Install Cristal Reports XI : Installation failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}