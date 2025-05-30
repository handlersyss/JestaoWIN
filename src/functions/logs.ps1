# Funções de Gerenciamento de Logs

function Manage-SystemLogs {
    Write-Log "Gerenciando logs do sistema"
    
    # Limpar logs antigos
    $LogNames = @("Application", "System", "Security", "Setup")
    
    foreach ($LogName in $LogNames) {
        try {
            $LogSize = (Get-WinEvent -ListLog $LogName).FileSize
            $LogSizeMB = [math]::Round($LogSize / 1MB, 2)
            
            Write-Log "Log $LogName : $LogSizeMB MB"
            
            # Arquivar logs grandes
            if ($LogSizeMB -gt 50) {
                $ArchivePath = "$env:TEMP\$LogName`_$(Get-Date -Format 'yyyyMMdd').evtx"
                wevtutil epl $LogName $ArchivePath
                wevtutil cl $LogName
                Write-Log "Log $LogName arquivado e limpo"
            }
            
            # Verificar eventos críticos recentes
            $CriticalEvents = Get-WinEvent -FilterHashtable @{LogName=$LogName; Level=1,2; StartTime=(Get-Date).AddDays(-7)} -MaxEvents 10 -ErrorAction SilentlyContinue
            if ($CriticalEvents) {
                Write-Log "Encontrados $($CriticalEvents.Count) eventos críticos em $LogName nos últimos 7 dias" -Level "WARNING"
            }
        }
        catch {
            Write-Log "Erro ao processar log $LogName : $($_.Exception.Message)" -Level "ERROR"
        }
    }
}

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Manage-SystemLogs 