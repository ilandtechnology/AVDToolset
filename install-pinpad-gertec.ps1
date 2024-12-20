# Define variables
$Uri = "https://stavdprdbrs01.blob.core.windows.net/progs/SAGAT_Test_PPC.exe?sv=2023-01-03&st=2024-12-17T13%3A29%3A57Z&se=2030-01-01T02%3A59%3A00Z&sr=b&sp=r&sig=OjVI354nnTxnrak5V%2FC%2Feml%2BHDVpNFlWvou%2FXdpcXP0%3D"
$packageFile = "SAGAT_Test_PPC.exe"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install SAGAT Test PPC ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Install SAGAT Test PPC package
Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Downloading Install SAGAT Test PPC installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Install SAGAT Test PPC: Time taken: $elapsedTime ***"
    exit 1
}

# Install the Install SAGAT Test PPC package
Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Installing the Install SAGAT Test PPC..."
($process = Start-Process -FilePath $(Join-Path $LocalWVDpath $packageFile) -ArgumentList "/S" -PassThru).PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Installed successfully."
    Write-Host "*** AIB Customization - Install Install SAGAT Test PPC: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Install SAGAT Test PPC: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Install SAGAT Test PPC: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}