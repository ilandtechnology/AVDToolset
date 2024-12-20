# Define variables
$Uri = "https://stavdprdbrs01.blob.core.windows.net/progs/Foxit.zip?sv=2023-01-03&st=2024-12-17T14%3A13%3A33Z&se=2030-01-01T02%3A59%3A00Z&sr=b&sp=r&sig=4RL%2FdLfUmjRtLWkNAlZUc7gVsJ%2FAHYuQn9bgMY73eVQ%3D"
$packageFile = "Foxit.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Foxit PDF Reader ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Install Foxit PDF Reader: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Install Foxit PDF Reader: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Install Foxit PDF Reader package
Write-Host "AVD AIB Customization - Install Install Foxit PDF Reader: Downloading Install Foxit PDF Reader installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install Install Foxit PDF Reader: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Install Foxit PDF Reader: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Install Foxit PDF Reader: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install Install Foxit PDF Reader: Expanding Install Foxit PDF Reader package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install Install Foxit PDF Reader: Expanded Install Foxit PDF Reader package."

# Install the Install Foxit PDF Reader package
Write-Host "AVD AIB Customization - Install Install Foxit PDF Reader: Installing the Install Foxit PDF Reader..."
$FoxitMSI = (Get-ChildItem -Path $LocalWVDpath -Recurse -Filter "FoxitPDFReader*.msi")[0].FullName
$FoxitMST = (Get-ChildItem -Path $LocalWVDpath -Recurse -Filter "FoxitPDFReader*.mst")[0].FullName
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/package $FoxitMSI TRANSFORMS=$FoxitMST /qn /norestart" -PassThru
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
    Write-Host "AVD AIB Customization - Install Install Foxit PDF Reader: Installed successfully."
    Write-Host "*** AIB Customization - Install Install Foxit PDF Reader: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Install Foxit PDF Reader: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Install Foxit PDF Reader: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}