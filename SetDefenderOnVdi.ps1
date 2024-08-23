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
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
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
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
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
    "\\server-name\share-name\*\*.VHD",
    "\\server-name\share-name\*\*.VHD.lock",
    "\\server-name\share-name\*\*.VHD.meta",
    "\\server-name\share-name\*\*.VHD.metadata",
    "\\server-name\share-name\*\*.VHDX",
    "\\server-name\share-name\*\*.VHDX.lock",
    "\\server-name\share-name\*\*.VHDX.meta",
    "\\server-name\share-name\*\*.VHDX.metadata",
    "%ProgramData%\FSLogix\Cache\*",
    "%ProgramData%\FSLogix\Proxy\*"
)

foreach ($exclusion in $exclusions) {
    $existingExclusions += ";$exclusion"
}

Set-ItemProperty -Path $registryPath -Name "Exclusions" -Value $existingExclusions


# Scan files only on wtrite (revisado)

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
$valueName = "RealtimeScanDirection"
$valueData = 1

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
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
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
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
        Set-ItemProperty -Path $keyPath -Name $severity -Value $threatActions[$severity]
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
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
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
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
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
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
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
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
}


######### Enable tamper protection to prevent Microsoft Defender being disabled: Enable

$keyPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender"
$valueName = "TamperProtection"
$valueData = 1  # 1 = Enabled

if (!(Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}

$currentValue = (Get-ItemProperty -Path $keyPath).$valueName

if ($currentValue -ne $valueData) {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
}