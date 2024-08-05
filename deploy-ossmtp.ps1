# Define variables
$Uri = "https://raw.githubusercontent.com/ilandtechnology/AVDToolset/main/ossmtp.msi"
$packageFile = "ossmtp.msi"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install OstroSoft SMTP Component ***"

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
    Write-Host "AVD AIB Customization - Install OstroSoft SMTP Component : Creating temp directory."
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
} else {
    Write-Host "AVD AIB Customization - Install OstroSoft SMTP Component : Temp directory already exists."
}
if (-not (Test-Path -Path $LocalWVDpath)) {
    Write-Host "AVD AIB Customization - Install OstroSoft SMTP Component : Creating directory: $LocalWVDpath."
    New-Item -ItemType Directory -Path $LocalWVDpath | Out-Null
} else {
    Write-Host "AVD AIB Customization - Install OstroSoft SMTP Component : $LocalWVDpath already exists."
}

# Download the OstroSoft SMTP Component package
Write-Host "AVD AIB Customization - Install OstroSoft SMTP Component : Downloading OstroSoft SMTP Component installer from URI: $Uri."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)

# Check if the file was downloaded successfully
if (Test-Path -Path $(Join-Path $LocalWVDpath $packageFile)) {
    Write-Host "AVD AIB Customization - Install OstroSoft SMTP Component : Package downloaded successfully."
} else {
    Write-Host "AVD AIB Customization - Install OstroSoft SMTP Component : Package failed to download."
    exit 1
}

# Install the OstroSoft SMTP Component package
Write-Host "AVD AIB Customization - Install OstroSoft SMTP Component : Installing the OstroSoft SMTP Component..."
($process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/package $(Join-Path $LocalWVDpath $packageFile) /qn /norestart" -PassThru).PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()

# Check the exit code of the installation and cleanup
if ($process.ExitCode -eq 0) {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install OstroSoft SMTP Component : Installed successfully."
    Write-Host "*** AIB Customization - Install OstroSoft SMTP Component - Time taken: $elapsedTime ***"
} else {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install OstroSoft SMTP Component : Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install OstroSoft SMTP Component - Time taken: $elapsedTime ***"
    exit $process.ExitCode
}