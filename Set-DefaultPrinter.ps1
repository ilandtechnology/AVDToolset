# Mapeamento de grupos para nomes de impressoras
$PrinterMapping = @{
    "GG_LJ01_CAIXAS_PRN_USERS" = "A4LJ1"
    "GG_LJ03_CAIXAS_PRN_USERS" = "A4LJ3"
    "GG_LJ04_CAIXAS_PRN_USERS" = "A4LJ4"
    "GG_LJ05_CAIXAS_PRN_USERS" = "A4LJ5"
    "GG_LJ01_VENDAS_PRN_USERS" = "ORC01"
    "GG_LJ03_VENDAS_PRN_USERS" = "ORC03"
    "GG_LJ04_VENDAS_PRN_USERS" = "ORC04"
    "GG_LJ05_VENDAS_PRN_USERS" = "ORC05"
    "GG_LJ01_SEPARACAO_PRN_USERS" = "SEPLJ01"
    "GG_LJ03_SEPARACAO_PRN_USERS" = "SEPLJ03"
    "GG_LJ04_SEPARACAO_PRN_USERS" = "SEPLJ04"
    "GG_LJ05_SEPARACAO_PRN_USERS" = "SEPLJ05"
    "GG_LJ01_ENTRADAS_PRN_USERS" = "ZEBRA_MATRIZ"
    "GG_LJ03_ENTRADAS_PRN_USERS" = "ZEBRA_OLINDA"
    "GG_LJ04_ENTRADAS_PRN_USERS" = "ZEBRA_JABOATAO"
    "GG_LJ05_ENTRADAS_PRN_USERS" = "ZEBRA_CAMARAGIBE" 
    "GG_LJ01_DEPOSITO_PRN_USERS" = "SEPLJ02"
    "GG_LJ01_RETAGUARDA_PRN_USERS" = "HP Neverstop Laser MFP 120x PCLm-S"
}

# Obtenha os grupos do usuário
$UserGroups = [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups |
    ForEach-Object {
        $_.Translate([System.Security.Principal.NTAccount]).Value.Split('\')[-1]
    }

# Verifique os grupos e defina a impressora padrão
foreach ($Group in $UserGroups) {
    if ($PrinterMapping.ContainsKey($Group)) {
        $PrinterName = $PrinterMapping[$Group]

        # Verifique se a impressora existe no sistema
        if (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue) {
            # Defina a impressora como padrão
            (New-Object -ComObject WScript.Network).SetDefaultPrinter($PrinterName)
            #Output para debug
            Write-Output "Impressora padrão definida como '$PrinterName' para o grupo '$Group'."
        } else {
            Write-Output "A impressora '$PrinterName' não foi encontrada no sistema."
        }

        # Saia do loop após encontrar o primeiro grupo correspondente
        break
    }
}