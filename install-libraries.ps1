# Define variables
$Uri = "https://stavdprdbrs01.blob.core.windows.net/misc/libraries.zip?sv=2023-01-03&st=2024-12-16T17%3A50%3A49Z&se=2030-01-01T02%3A59%3A00Z&sr=b&sp=r&sig=QK%2BchqZqE3HskI6z8QJJRm7Sp%2FJ06%2F8qi0myv3KBlzA%3D"
$packageFile = "libraries.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install SSPlus Libraries ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install SSPlus Libraries: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install SSPlus Libraries: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the SSPlus Libraries package
Write-Host "AVD AIB Customization - Install SSPlus Libraries: Downloading SSPlus Libraries installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install SSPlus Libraries: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install SSPlus Libraries: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install SSPlus Libraries: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install SSPlus Libraries: Expanding SSPlus Libraries package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath" `
    -Force
Write-Host "AVD AIB Customization - Install SSPlus Libraries: Expanded SSPlus Libraries package."

# Install the SSPlus Libraries package
Write-Host "AVD AIB Customization - Install SSPlus Libraries: Installing the SSPlus Libraries..."
foreach ($file in Get-ChildItem $(Join-Path $LocalWVDpath "libraries\*.ocx"), $(Join-Path $LocalWVDpath "libraries\*.dll")) {
    $libPath = $file.FullName
    $localPath = Join-Path "$env:windir\SysWOW64" $file.Name
    
    if (Test-Path $localPath) {
        Write-Warning "A biblioteca $($file.Name) já está registrada no sistema."
    } else {
        try {
            Copy-Item -Path $libPath -Destination $env:windir\SysWOW64 -ErrorAction SilentlyContinue -Force
            Write-Output "Registrando a biblioteca $localPath..."
            $process = Start-Process -FilePath "regsvr32.exe" -ArgumentList "/s $localPath" -PassThru
            $process.WaitForExit()
        } catch {
            Write-Warning "Não foi possível copiar a biblioteca $($file.Name) para o sistema."
            continue
        }
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
    Write-Host "AVD AIB Customization - Install SSPlus Libraries: Installed successfully."
    Write-Host "*** AIB Customization - Install SSPlus Libraries: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install SSPlus Libraries: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install SSPlus Libraries: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}