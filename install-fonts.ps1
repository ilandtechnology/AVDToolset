# Define variables
$packageFile = "fonts.zip"
$baseUri = "https://stgavdprdbrs01-microsoftrouting.blob.core.windows.net/misc/"
$sas = "sv=2022-11-02&ss=b&srt=co&sp=r&se=2028-01-01T02:59:59Z&st=2025-02-21T03:00:00Z&spr=https&sig=qkDCJAUaSucfOdDYTkmIryQOayzu3oLMGtNXYluzfwE%3D"
$Uri = $baseUri + $packageFile + "?" + $sas
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

function Install-Font {  
    param
    (  
        [System.IO.FileInfo]$fontFile  
    )
          
    try {
        #get font name
        [System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework").GetTypes() | Out-Null
        $gt = [Windows.Media.GlyphTypeface]::new($fontFile.FullName)
        $family = $gt.Win32FamilyNames['en-us']
        if ($null -eq $family) { $family = $gt.Win32FamilyNames.Values.Item(0) }
        $face = $gt.Win32FaceNames['en-us']
        if ($null -eq $face) { $face = $gt.Win32FaceNames.Values.Item(0) }
        $fontName = ("$family $face").Trim() 
            
        switch ($fontFile.Extension) {  
            ".ttf" {$fontName = "$fontName (TrueType)"}  
            ".otf" {$fontName = "$fontName (OpenType)"}  
        }  

        write-host "Installing font: $fontFile with font name '$fontName'"

        If (!(Test-Path ("$($env:windir)\Fonts\" + $fontFile.Name))) {  
            write-host "Copying font: $fontFile"
            Copy-Item -Path $fontFile.FullName -Destination ("$($env:windir)\Fonts\" + $fontFile.Name) -Force 
        } else {  write-host "Font already exists: $fontFile" }

        If (!(Get-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue)) {  
            write-host "Registering font: $fontFile"
            New-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $fontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null  
        } else {  write-host "Font already registered: $fontFile" }

    } catch {            
        write-host "Error installing font: $fontFile. " $_.exception.message
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
    Unblock-File -Path $(Join-Path $LocalWVDpath $packageFile) -Confirm:$false
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
foreach ($file in Get-ChildItem $(Join-Path $LocalWVDpath "\fonts\*.ttf"),$(Join-Path $LocalWVDpath "\fonts\*.otf") )
{
    $fileName = $file.Name
    if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
        Install-Font -fontFile $file.FullName  
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