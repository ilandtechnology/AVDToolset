# Define variables
$Uri = "https://ftp.postgresql.org/pub/odbc/versions.old/msi/psqlodbc_13_02_0000-x64.zip"
$packageFile = "psqlodbc_13_02_0000-x64.zip"
$destinationFolder = "C:\Temp"
$LocalWVDpath = "C:\Temp\wvd\"


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install PostgreSQL ODBC ***"

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : Creating temp directory."
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
} else {
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : Temp directory already exists."
}
if( -not (Test-Path -Path $LocalWVDpath)) {
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : Creating directory: $LocalWVDpath."
    New-Item -ItemType Directory -Path $LocalWVDpath | Out-Null
}
else {
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : $LocalWVDpath already exists."
}

# Download the PostgreSQL ODBC package
Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : Downloading PostgreSQL ODBC installer from URI: $Uri."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $Uri -Headers @{"Accept-Encoding"="gzip,deflate"} -OutFile $(Join-Path $LocalWVDpath $packageFile)

# Check if the file was downloaded successfully
if (Test-Path -Path $(Join-Path $LocalWVDpath $packageFile)) {
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : Package downloaded successfully."
} else {
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : Package failed to download."
    exit 1
}

# Prepare the destination folder
Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : Expanding PostgreSQL ODBC package."
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$packageFile" `
    -DestinationPath "$LocalWVDpath\pgsqlodbc" `
    -Force
Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : Expanded PostgreSQL ODBC package."

# Install the PostgreSQL ODBC package
Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : Installing the PostgreSQL ODBC..."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/package $(Join-Path $LocalWVDpath "pgsqlodbc\psqlodbc_x64.msi") /qb /norestart" -Wait -PassThru | Out-Null

# Check the exit code of the installation and cleanup
if ($LASTEXITCODE -eq 0) {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : Installed successfully."
    Write-Host "*** AIB Customization - Install PostgreSQL ODBC - Time taken: $elapsedTime ***"
} else {
    #Cleanup
    if ((Test-Path -Path $LocalWVDpath -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $LocalWVDpath -Force -Recurse -ErrorAction Continue | Out-Null
    }
    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "AVD AIB Customization - Install PostgreSQL ODBC : Installation failed with exit code $LASTEXITCODE."
    Write-Host "*** AIB Customization - Install PostgreSQL ODBC - Time taken: $elapsedTime ***"
    exit $LASTEXITCODE
}