# Define variables
$Uri = "https://ftp.postgresql.org/pub/odbc/versions.old/msi/psqlodbc_13_02_0000-x86-1.zip"
$packageFile = "psqlodbc_13_02_0000-x86.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install PostgreSQL ODBC ***"

# Function to create directory if it doesn't exist
function New-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        Write-Host "AVD AIB Customization - Install PostgreSQL ODBC: Creating directory: $path."
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "AVD AIB Customization - Install PostgreSQL ODBC: Directory already exists: $path."
    }
}

# Ensure destination and local WVD paths exist
New-Directory -path $destinationFolder
New-Directory -path $LocalWVDpath

# Download the PostgreSQL ODBC package
Write-Host "AVD AIB Customization - Install PostgreSQL ODBC: Downloading PostgreSQL ODBC installer from URI: $Uri."
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC: Package downloaded successfully."
    $ProgressPreference = 'Continue'
} catch {
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC: Failed to download package: $($_.Exception.Message)"
    Write-Host "*** AIB Customization - Install PostgreSQL ODBC: Time taken: $elapsedTime ***"
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install PostgreSQL ODBC: Expanding PostgreSQL ODBC package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath\pgsqlodbc" `
    -Force
Write-Host "AVD AIB Customization - Install PostgreSQL ODBC: Expanded PostgreSQL ODBC package."

# Install the PostgreSQL ODBC package
Write-Host "AVD AIB Customization - Install PostgreSQL ODBC: Installing the PostgreSQL ODBC..."
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/package $(Join-Path $LocalWVDpath "pgsqlodbc\psqlodbc_x86.msi") /qn /norestart" -PassThru
$process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal
$process.WaitForExit()

# Cleanup
if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
    Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
}

# Check the exit code of the installation
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
if ($process.ExitCode -eq 0) {
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC: Installed successfully."
    Write-Host "*** AIB Customization - Install PostgreSQL ODBC: Time taken: $elapsedTime ***"
    exit $process.ExitCode
} else {
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC: Installation failed with exit code $($process.ExitCode)."
    Write-Host "*** AIB Customization - Install PostgreSQL ODBC: Time taken: $elapsedTime ***"
    exit $process.ExitCode
}