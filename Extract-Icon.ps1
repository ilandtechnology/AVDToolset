# Extract-Icon.ps1
# Inspired by Josh Duffney's code on Spiceworks

# Parameters
param (
    [Parameter(Position = 0, Mandatory, HelpMessage = "Specify the path to the file.")]
    [ValidateScript({Test-Path $_})]
    [string]$Path,

    [Parameter(HelpMessage = "Specify the folder to save the file.")]
    [ValidateScript({Test-Path $_})]
    [string]$Destination = ".",

    [parameter(HelpMessage = "Specify an alternate base name for the new image file. Otherwise, the source name will be used.")]
    [ValidateNotNullOrEmpty()]
    [string]$Name,

    [Parameter(HelpMessage = "What format do you want to use? The default is png.")]
    [ValidateSet("ico", "bmp", "png", "jpg", "gif")]
    [string]$Format = "png"
)

# Load System.Drawing assembly
Add-Type -AssemblyName System.Drawing -ErrorAction Stop

# Determine image format based on user input
switch ($format) {
    "ico" { $ImageFormat = "icon" }
    "bmp" { $ImageFormat = "Bmp" }
    "png" { $ImageFormat = "Png" }
    "jpg" { $ImageFormat = "Jpeg" }
    "gif" { $ImageFormat = "Gif" }
}

$file = Get-Item $path

# Convert destination to file system path
$Destination = Convert-Path -Path $Destination

if ($Name) {
    $base = $Name
} else {
    $base = $file.BaseName
}

# Construct the image file name
$out = Join-Path -Path $Destination -ChildPath "$base.$format"

$ico = [System.Drawing.Icon]::ExtractAssociatedIcon($file.FullName)

if ($ico) {
    # Save the icon image
    $ico.ToBitmap().Save($Out, $Imageformat)
    Get-Item -Path $out
} else {
    Write-Warning "No associated icon image found in $($file.fullname)"
}
