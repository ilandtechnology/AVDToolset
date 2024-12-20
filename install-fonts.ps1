# Define variables
$Uri = "https://stavdprdbrs01.blob.core.windows.net/misc/fonts.zip?sv=2023-01-03&st=2024-12-16T17%3A44%3A37Z&se=2030-01-01T02%3A59%3A00Z&sr=b&sp=r&sig=IEqT1UY7NqNkIvlpuGm2FVnTNb3KR2xKo9TDoyKOFoY%3D"
$packageFile = "fonts.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Fonts ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install Fonts: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install Fonts: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the Fonts package
Write-Host "AVD AIB Customization - Install Fonts: Downloading Fonts installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install Fonts: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install Fonts: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install Fonts: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install Fonts: Expanding Fonts package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install Fonts: Expanded Fonts package."

# Install the Fonts package
Write-Host "AVD AIB Customization - Install Fonts: Installing the Fonts..."
$CopyOptions = 4 + 16 + 1024 + 2048 + 4096 # 4 = Do not display a progress dialog box, 16 = Respond with "Yes to All" for any dialog box that is displayed, 1024 = Do not confirm the creation of a new directory if the operation requires one to be created, 2048 = Do not display a user interface if an error occurs, 4096 = Version 4.71. Do not copy the security attributes of the file.
$CopyFlag = [String]::Format("{0:x}", $CopyOptions)
$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
foreach ($file in Get-ChildItem $(Join-Path $LocalWVDpath "\fonts\*.ttf"))
{
    $fileName = $file.Name
    if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
        Write-Output $fileName
        $fonts.CopyHere($file.FullName, $CopyFlag)
    }
}

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation and cleanup
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install Fonts: Installed successfully."
    Write-Host "*** AIB Customization - Install Fonts: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install Fonts: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install Fonts: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}