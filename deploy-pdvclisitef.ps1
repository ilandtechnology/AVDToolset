# Define variables
$Uri = "https://raw.githubusercontent.com/ilandtechnology/AVDToolset/main/PDVCliSiTef.zip"
$packageFile = "PDVCliSiTef.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install PDV CliSiTef ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Install PDV CliSiTef: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Install PDV CliSiTef: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Install PDV CliSiTef package
Write-Host "AVD AIB Customization - Install Install PDV CliSiTef: Downloading Install PDV CliSiTef installer from URI: $Uri."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install Install PDV CliSiTef: Package downloaded successfully."
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Install PDV CliSiTef: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Install PDV CliSiTef: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install Install PDV CliSiTef: Expanding Install PDV CliSiTef package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install Install PDV CliSiTef: Expanded Install PDV CliSiTef package."

# Install the Install PDV CliSiTef package
Write-Host "AVD AIB Customization - Install Install PDV CliSiTef: Installing the Install PDV CliSiTef..."
($process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/package $(Join-Path $LocalWVDpath "PDVCliSiTef\PDVCliSiTef.msi") /qn /norestart" -PassThru).PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
pause
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install Install PDV CliSiTef: Installed successfully."
    Write-Host "*** AIB Customization - Install Install PDV CliSiTef: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Install PDV CliSiTef: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Install PDV CliSiTef: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}