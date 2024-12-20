$libs = @(
    'MCI32.OCX'
    'MSADODC.OCX'
    'MSCAL.OCX'
    'MSCHRT20.OCX'
    'MSCOMCT2.OCX'
    'MSCOMCTL.OCX'
    'MSCOMM32.OCX'
    'MSDATLST.OCX'
    'MSDATREP.OCX'
    'MSDATGRD.OCX'
    'MSDATLST.OCX'
    'msdxm.ocx'
    'VSFLEX3.OCX'
    'tdc.ocx'
    'TABCTL32.OCX'
    'SYSINFO.OCX'
    'sysmon.ocx'
    'RICHTX32.OCX'
    'proctexe.ocx'
    'plugin.ocx'
    'PICCLP32.OCX'
    'MSWINSCK.OCX'
    'msscript.ocx'
    'MSRDC20.OCX'
    'MSOUTL32.OCX'
    'MSMASK32.OCX'
    'MSMAPI32.OCX'
    'MSINET.OCX'
    'MSHFLXGD.OCX'
    'msdxm.ocx'
    'MSDATREP.OCX'
    'MSDATLST.OCX'
    'actskin4.ocx'
    'asctrls.ocx'
    'COMCT232.OCX'
    'COMCT332.OCX'
    'COMCTL32.OCX'
    'daxctle.ocx'
    'DBGRID32.OCX'
    'DBLIST32.OCX'
    'dmview.ocx'
    'FOXHWND.OCX'
    'FOXTLIB.OCX'
    'hhctrl.ocx'
)

$letter = "S"

# $path = "\\stavdprdbrs04.privatelink.file.core.windows.net\ssplus-prd"
$path = "\\vm-ssplus-prd-1\sssistemas\ssplus"

if (Test-NetConnection -ComputerName $path.Split("\")[2] -Port 445 -InformationLevel Quiet) {
    if (-not(Get-PSDrive -Name $letter -PSProvider FileSystem -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $letter -PSProvider FileSystem -Root $path -ErrorAction SilentlyContinue | Out-Null
    } else {
        Write-Warning "A unidade de rede $($letter): já está mapeada."
    }

    foreach ($lib in $libs) {
        $networkPath = Join-Path "$($letter):\" $lib
        $localPath = Join-Path "$env:windir\System32" $lib
        
        if (Test-Path $networkPath) {
            if (Test-Path $localPath) {

                $fn = Get-FileHash -Path $networkPath -Algorithm MD5
                $fo = Get-FileHash -Path $localPath -Algorithm MD5

                if ($fo.Hash -eq $fn.Hash) {
                    Write-Warning "A biblioteca $lib já está registrada no sistema."
                    continue
                }

                try {
                    Copy-Item -Path $networkPath -Destination $env:windir\System32 -ErrorAction SilentlyContinue -Force
                    Write-Output "Registrando a biblioteca $lib..."
                    & regsvr32 /s $localPath
                } catch {
                    Write-Warning "Não foi possível copiar a biblioteca $lib para o sistema."
                    continue
                }
            } else {
                try {
                    Copy-Item -Path $networkPath -Destination $env:windir\System32 -ErrorAction SilentlyContinue
                    Write-Output "Registrando a biblioteca $lib..."
                    & regsvr32 /s $localPath
                } catch {
                    Write-Warning "Não foi possível copiar a biblioteca $lib para o sistema."
                    continue
                }
            }
        } else {
            Write-Warning "A biblioteca $lib não foi encontrada no servidor de arquivos."
            continue
        }
    }
} else {
    Write-Warning "Não foi possível conectar ao servidor de arquivos."
}

# Remove a unidade de rede
Remove-PSDrive -Name $letter
