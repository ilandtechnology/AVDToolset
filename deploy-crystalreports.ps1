# Define variables
$Uri = "https://raw.githubusercontent.com/ilandtechnology/AVDToolset/main/crystalreports_xi-sss.msi"
$packageFile = "crystalreports_xi-sss.msi"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Crystal Reports ***"

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
    Write-Host "AVD AIB Customization - Install Crystal Reports : Creating temp directory."
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
} else {
    Write-Host "AVD AIB Customization - Install Crystal Reports : Temp directory already exists."
}
if (-not (Test-Path -Path $LocalWVDpath)) {
    Write-Host "AVD AIB Customization - Install Crystal Reports : Creating directory: $LocalWVDpath."
    New-Item -ItemType Directory -Path $LocalWVDpath | Out-Null
} else {
    Write-Host "AVD AIB Customization - Install Crystal Reports : $LocalWVDpath already exists."
}

# Download the Crystal Reports package
Write-Host "AVD AIB Customization - Install Crystal Reports : Downloading Crystal Reports installer from URI: $Uri."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)

# Check if the file was downloaded successfully
if (Test-Path -Path $(Join-Path $LocalWVDpath $packageFile)) {
    Write-Host "AVD AIB Customization - Install Crystal Reports : Package downloaded successfully."
} else {
    Write-Host "AVD AIB Customization - Install Crystal Reports : Package failed to download."
    exit 1
}

# Install the Crystal Reports package
Write-Host "AVD AIB Customization - Install Crystal Reports : Installing the Crystal Reports..."
($process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $(Join-Path $LocalWVDpath $packageFile) /qn /l*v C:\CRInstall.log ADDLOCAL=ALL REBOOT=ReallySuppress" -PassThru).PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()
Write-Host "ExitCode: $($process.ExitCode)"

# Check the exit code of the installation and cleanup
if ($process.ExitCode -eq 0) {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Crystal Reports : Installed successfully."
    Write-Host "*** AIB Customization - Install Crystal Reports - Time taken: $elapsedTime ***"
} else {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Crystal Reports : Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Crystal Reports - Time taken: $elapsedTime ***"
    exit $process.ExitCode
}