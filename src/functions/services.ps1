# Funções de Otimização de Serviços

function Optimize-WindowsServices {
    Write-Log "Iniciando otimização de serviços"
    
    $ServicesToDisable = @(
        "Fax", "dmwappushservice", "MapsBroker", "lfsvc", "SharedAccess", 
        "TrkWks", "WbioSrvc", "WMPNetworkSvc", "XblAuthManager", "XblGameSave"
    )
    
    $ServicesToOptimize = @(
        @{Name="BITS"; StartupType="Manual"},
        @{Name="Themes"; StartupType="Automatic"},
        @{Name="Spooler"; StartupType="Automatic"},
        @{Name="AudioSrv"; StartupType="Automatic"}
    )
    
    foreach ($ServiceName in $ServicesToDisable) {
        try {
            $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
            if ($Service -and $Service.Status -eq "Running") {
                Stop-Service -Name $ServiceName -Force
                Set-Service -Name $ServiceName -StartupType Disabled
                Write-Log "Serviço $ServiceName desabilitado"
            }
        }
        catch {
            Write-Log "Erro ao otimizar serviço $ServiceName : $($_.Exception.Message)" -Level "ERROR"
        }
    }
    
    foreach ($Service in $ServicesToOptimize) {
        try {
            Set-Service -Name $Service.Name -StartupType $Service.StartupType
            Write-Log "Serviço $($Service.Name) configurado para $($Service.StartupType)"
        }
        catch {
            Write-Log "Erro ao configurar serviço $($Service.Name) : $($_.Exception.Message)" -Level "ERROR"
        }
    }
}

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Optimize-WindowsServices 