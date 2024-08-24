$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AIB Customization - Install Printer ***"

$hostname = [System.Net.Dns]::GetHostName()

function Install-Printer {
    param (
        [string]$Name,
        [string]$IPAddress,
        [string]$Queue,
        [string]$Model
    )
    if ($Model -match "^EPSON") {
        $Tag = "EPSON"
    } elseif ($Model -match "^ZDesigner") {
        $Tag = "ZEBRA"
    } elseif (($Model -match "^HP")) {
        $Tag = "HP"
    } elseif (($Model -match "^Samsung")) {
        $Tag = "SAMSUNG"
    }
    if (-not($null -ne $Queue)) {
        Write-Host "Registring: " $Name", "$IPAddress", "$Model
        Add-PrinterPort -Name $("LAN_"+$TAG+"_"+$IPADDRESS) -LprHostAddress $IPADDRESS -LprQueueName $Queue -LprByteCounting
        Add-Printer -Name $NAME -DriverName $MODEL -PortName $("LAN_"+$TAG+"_"+$IPADDRESS)
    } else {
        Write-Host "Registring: " $Name", "$IPAddress", "$Model
        Add-PrinterPort -Name $("LAN_"+$TAG+$IPADDRESS) -PrinterHostAddress $IPADDRESS -PortNumber 9100
        Add-Printer -Name $NAME -DriverName $MODEL -PortName $("LAN_"+$TAG+"_"+$IPADDRESS)
    }
}

if ($hostname -match "^vm-apvd") {
    Install-Printer -Name "CX01LJ01" -IPAddress "192.168.50.147" -Queue "CX01LJ01" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "CX02LJ01" -IPAddress "192.168.50.247" -Queue "CX02LJ01" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "CX01LJ03" -IPAddress "192.168.100.108" -Queue "CX01LJ03" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "CX02LJ03" -IPAddress "192.168.100.115" -Queue "CX02LJ03" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "CX01LJ04" -IPAddress "192.168.0.188" -Queue "CX01LJ04" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "CX02LJ04" -IPAddress "192.168.0.163" -Queue "CX02LJ04" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "CX01LJ05" -IPAddress "192.168.10.194" -Queue "CX01LJ05" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "CX02LJ05" -IPAddress "192.168.10.177" -Queue "CX02LJ05" -Model "EPSON TM-T(203dpi) Receipt6"

    Install-Printer -Name "A4LJ01" -IPAddress "192.168.50.147" -Queue "M2020" -Model "Samsung M2020 Series"
    Install-Printer -Name "A4LJ03" -IPAddress "192.168.100.177" -Queue $null -Model "EPSON M2120 Series"
    Install-Printer -Name "A4LJ04" -IPAddress "192.168.0.125" -Queue $null -Model "EPSON M2120 Series"
    Install-Printer -Name "A4LJ05" -IPAddress "192.168.10.182" -Queue $null -Model "EPSON M2120 Series"

 } elseif ($hostname -match "^vm-asvd") {
    Install-Printer -Name "SEPLJ01" -IPAddress "192.168.50.157" -Queue "SEPLJ01" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "SEPLJ02" -IPAddress "192.168.50.170" -Queue "SEPLJ02" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "SEPLJ03" -IPAddress "192.168.100.175" -Queue "SEPLJ03" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "SEPLJ04" -IPAddress "192.168.0.199" -Queue "SEPLJ04" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "SEPLJ05" -IPAddress "192.168.10.119" -Queue "SEPLJ05" -Model "EPSON TM-T(203dpi) Receipt6"

    Install-Printer -Name "ORC01" -IPAddress "192.168.50.33" -Queue "ORC01" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "ORC03" -IPAddress "192.168.100.106" -Queue "ORC03" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "ORC04" -IPAddress "192.168.0.131" -Queue "ORC04" -Model "EPSON TM-T(203dpi) Receipt6"
    Install-Printer -Name "ORC05" -IPAddress "192.168.10.157" -Queue "ORC05" -Model "EPSON TM-T(203dpi) Receipt6"

    Install-Printer -Name "A4LJ01" -IPAddress "192.168.50.147" -Queue "M2020" -Model "Samsung M2020 Series"
    Install-Printer -Name "A4LJ03" -IPAddress "192.168.100.177" -Queue $null -Model "EPSON M2120 Series"
    Install-Printer -Name "A4LJ04" -IPAddress "192.168.0.125" -Queue $null -Model "EPSON M2120 Series"
    Install-Printer -Name "A4LJ05" -IPAddress "192.168.10.182" -Queue $null -Model "EPSON M2120 Series"

    Install-Printer -Name "ZEBRA_MATRIZ" -IPAddress "192.168.50.27" -Queue "ZEBRA" -Model "ZDesigner ZD220-203dpi ZPL"
    Install-Printer -Name "ZEBRA_OLINDA" -IPAddress "192.168.100.185" -Queue "ZEBRA" -Model "ZDesigner ZD220-203dpi ZPL"
    Install-Printer -Name "ZEBRA_JABOATAO" -IPAddress "192.168.0.142" -Queue "ZEBRA" -Model "ZDesigner ZD220-203dpi ZPL"
    Install-Printer -Name "ZEBRA_CAMARAGIBE" -IPAddress "192.168.10.196" -Queue "ZEBRA" -Model "ZDesigner ZD220-203dpi ZPL"

    Install-Printer -Name "HP Neverstop Laser 100x PCLm-S" -IPAddress "192.168.50.190" -Queue $null -Model "HP Neverstop Laser 100x PCLm-S"
}

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "AVD AIB Customization - Install Printer: Setup successfully."
Write-Host "*** AIB Customization - Install Printer: Time taken: $elapsedTime ***"