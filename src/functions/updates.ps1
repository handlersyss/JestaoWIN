# Funções de Gerenciamento de Atualizações

function Manage-WindowsUpdates {
    Write-Log "Verificando atualizações do Windows"
    
    try {
        # Instalar PSWindowsUpdate se não estiver instalado
        if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
        }
        
        Import-Module PSWindowsUpdate
        
        # Verificar atualizações disponíveis
        $Updates = Get-WUList
        
        if ($Updates.Count -gt 0) {
            Write-Log "Encontradas $($Updates.Count) atualizações disponíveis"
            
            # Instalar atualizações críticas automaticamente
            $CriticalUpdates = $Updates | Where-Object { $_.MsrcSeverity -eq "Critical" }
            if ($CriticalUpdates) {
                Write-Log "Instalando $($CriticalUpdates.Count) atualizações críticas"
                Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot:$false
            }
        } else {
            Write-Log "Sistema atualizado - nenhuma atualização disponível"
        }
    }
    catch {
        Write-Log "Erro no gerenciamento de atualizações: $($_.Exception.Message)" -Level "ERROR"
    }
}

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Manage-WindowsUpdates 