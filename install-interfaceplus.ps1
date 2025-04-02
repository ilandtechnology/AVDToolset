# Define variables
$packageFile = "interfaceplus.msi"
$baseUri = "https://stgavdprdbrs01-microsoftrouting.blob.core.windows.net/progs/"
$sas = "sv=2022-11-02&ss=b&srt=co&sp=r&se=2028-01-01T02:59:59Z&st=2025-02-21T03:00:00Z&spr=https&sig=qkDCJAUaSucfOdDYTkmIryQOayzu3oLMGtNXYluzfwE%3D"
$Uri = $baseUri + $packageFile + "?" + $sas
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Interface Plus ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Interface Plus: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Interface Plus: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Interface Plus package
Write-Host "AVD AIB Customization - Install Interface Plus: Downloading Interface Plus installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Unblock-File -Path $(Join-Path $LocalWVDpath $packageFile) -Confirm:$false
    Write-Host "AVD AIB Customization - Install Interface Plus: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Interface Plus: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Interface Plus: Time taken: $elapsedTime ***"
    exit 1
}

# Install the Interface Plus package
Write-Host "AVD AIB Customization - Install Interface Plus: Installing the Interface Plus..."
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/package $(Join-Path $LocalWVDpath $packageFile) /qn /norestart" -PassThru
$process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install Interface Plus: Installed successfully."
    Write-Host "*** AIB Customization - Install Interface Plus: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Interface Plus: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Interface Plus: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}