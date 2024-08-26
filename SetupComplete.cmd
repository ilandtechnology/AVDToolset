@ECHO OFF

echo %DATE%-%TIME% Install Printer
powershell.exe -ExecutionPolicy ByPass -WindowsStyle hidden -NonInteractive -NoLogo -File C:\Windows\Setup\Scripts\Install-Printer.ps1