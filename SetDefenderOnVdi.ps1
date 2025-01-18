$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Setup Microsoft Antimalware ***"

$keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates"

if (-not (Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan"

if (-not (Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions"

if (-not (Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}


# Change update source to MMPC

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates"
$valueName = "UpdateSource"
$valueData = 1  # 1 = Microsoft Malware Protection Center (MMPC)

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -PassThru
}


# Defender Cloud Extended Timeout In Seconds: 20

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender\Scan"
$valueName = "CloudExtendedTimeout"
$valueData = 20

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -PassThru
}


# FXLogix exclusions

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions"

if (-not (Test-Path $registryPath)) { 
    New-Item -Path $registryPath -Force 
}

# Initialize or retrieve existing exclusions
if (-not (Get-ItemProperty -Path $registryPath -Name "Exclusions" -ErrorAction SilentlyContinue)) {
    $existingExclusions = ""
} else {
    $existingExclusions = Get-ItemProperty -Path $registryPath -Name "Exclusions" | Select-Object -ExpandProperty Exclusions
}

$exclusions = @(
    "%TEMP%\*\*.VHD",
    "%TEMP%\*\*.VHDX",
    "%Windir%\TEMP\*\*.VHD",
    "%Windir%\TEMP\*\*.VHDX",
    "\\stavdprdbrs02.privatelink.file.core.windows.net\profiles\*\*.VHD",
    "\\stavdprdbrs02.privatelink.file.core.windows.net\profiles\*\*.VHD.lock",
    "\\stavdprdbrs02.privatelink.file.core.windows.net\profiles\*\*.VHD.meta",
    "\\stavdprdbrs02.privatelink.file.core.windows.net\profiles\*\*.VHD.metadata",
    "\\stavdprdbrs02.privatelink.file.core.windows.net\profiles\*\*.VHDX",
    "\\stavdprdbrs02.privatelink.file.core.windows.net\profiles\*\*.VHDX.lock",
    "\\stavdprdbrs02.privatelink.file.core.windows.net\profiles\*\*.VHDX.meta",
    "\\stavdprdbrs02.privatelink.file.core.windows.net\profiles\*\*.VHDX.metadata",
    "%ProgramData%\FSLogix\Cache\*",
    "%ProgramData%\FSLogix\Proxy\*",
    "%SystemDrive%\TMP\*"
)

foreach ($exclusion in $exclusions) {
    $existingExclusions += ";$exclusion"
}

Set-ItemProperty -Path $registryPath -Name "Exclusions" -Value $existingExclusions -PassThru


# Scan files only on wtrite (revisado)

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
$valueName = "RealtimeScanDirection"
$valueData = 1

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -PassThru
}


# Action to take on potentially unwanted apps: Enable

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender"
$valueName = "PUAProtection"
$valueData = 1

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -PassThru
}

# Actions for detected threats: Low threat: Clean | Moderate threat, High threat, Severe threat: DELETE

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender\Threats\ThreatSeverityDefaultAction"

# Actions for each threat level
$threatActions = @{
    "LowSeverity"      = 1  # 1 = Clean
    "ModerateSeverity" = 3  # 3 = Delete
    "HighSeverity"     = 3  # 3 = Delete
    "SevereSeverity"   = 3  # 3 = Delete
}

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

foreach ($severity in $threatActions.Keys) {
    $currentValue = (Get-ItemProperty -Path $keyPath).$severity
    if ($currentValue -ne $threatActions[$severity]) {
        Set-ItemProperty -Path $keyPath -Name $severity -Value $threatActions[$severity] -PassThru
    }
}


# Scan archived files: Yes

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender\Scan"
$valueName = "DisableArchiveScanning"
$valueData = 0

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -PassThru
}


# CPU usage limit per scan: 50

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender\Scan"
$valueName = "CpuThrottleDropPercent"
$valueData = 50

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -PassThru
}


# Check for signature updates before running scan: Yes

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender\Scan"
$valueName = "CheckForSignaturesBeforeScan"
$valueData = 1

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -PassThru
}


# Enter how often to check for security intelligence updates: 8

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates"
$valueName = "SignatureUpdateInterval"
$valueData = 1

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -PassThru
}


# Memory Integrity

$keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
$valueName = "Enabled"
$valueData = 1

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -PassThru
}


######### Enable tamper protection to prevent Microsoft Defender being disabled: Enable

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender"
$valueName = "TamperProtection"
$valueData = 0  # 1 = Enabled

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -PassThru
}


# Define registry key path
$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender"

# Ensure the registry key exists
if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

# Set DisableEmailScanning to false (0)
$valueName = "DisableEmailScanning"
$valueData = 0
$currentValue = (Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue).$valueName
if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
}

# Set DisableNetworkProtectionPerfTelemetry to true (1)
$valueName = "DisableNetworkProtectionPerfTelemetry"
$valueData = 1
$currentValue = (Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue).$valueName
if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
}

# Set DisableRdpParsing to true (1)
$valueName = "DisableRdpParsing"
$valueData = 1
$currentValue = (Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue).$valueName
if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
}


$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "AVD AIB Customization - Setup Microsoft Antimalware: Setup successfully."
Write-Host "*** AIB Customization - Setup Microsoft Antimalware: Time taken: $elapsedTime ***"