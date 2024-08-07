Import-Csv -Path ".\printer.csv" -Delimiter ";" | % {
    Add-PrinterPort -Name $("LAN_"+$_.IPADDRESS) -LprHostAddress $_.IPADDRESS -LprQueueName $_.QUEUE -LprByteCounting
    Add-Printer -Name $_.NAME -DriverName $(switch ($_.MODEL) { "EPSON" { "EPSON TM-T(203dpi) Receipt6" }; "ZEBRA" { "ZDesigner ZD220-203dpi ZPL" } }) -PortName $("LAN_"+$_.IPADDRESS)
}