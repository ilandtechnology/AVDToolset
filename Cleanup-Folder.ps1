param (
    [parameter(Mandatory = $true)]
    [ValidatePattern('^([a-zA-Z]:\\|\\\\)')]
    [string]$FolderPath,
    [parameter(Mandatory = $false)]
    [ValidateRange(1, 365)]
    [int]$DaysOld = 7
)

if (-Not (Test-Path -Path $FolderPath)) {
    Write-Host "O caminho especificado não existe." -ForegroundColor Red
    exit 1
}

$files = Get-ChildItem -Path $FolderPath -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$DaysOld) }

foreach ($file in $files) {
    try {
        Remove-Item -Path $file.FullName -Force
        Write-Host "Arquivo removido: $($file.FullName)" -ForegroundColor Green
    } catch {
        Write-Host "Erro ao remover o arquivo: $($file.FullName)" -ForegroundColor Red
    }
}

Write-Host "Limpeza concluída." -ForegroundColor Yellow