# Configurações e Variáveis Globais
$ErrorActionPreference = "SilentlyContinue"
$LogPath = "$env:TEMP\WindowsMaintenance_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$BackupPath = "C:\Backup_Sistema"

# Exportar variáveis para uso em outros módulos
Export-ModuleMember -Variable * 