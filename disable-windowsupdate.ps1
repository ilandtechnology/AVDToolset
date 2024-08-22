$WindowsUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
$AutoUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

If(-not(Test-Path -Path $WindowsUpdatePath)) {
    New-Item -Path $WindowsUpdatePath
    New-Item -Path $AutoUpdatePath
}

Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1


New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" -Name BackInfo -Type String -Value "C:\Windows\Backinfo.exe"