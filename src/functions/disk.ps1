# Funções de Análise de Disco

function Analyze-DiskHealth {
    Write-Log "Analisando saúde dos discos"
    
    # Informações básicas dos discos
    $Disks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    
    foreach ($Disk in $Disks) {
        $FreeSpacePercent = ($Disk.FreeSpace / $Disk.Size) * 100
        $UsedSpaceGB = [math]::Round(($Disk.Size - $Disk.FreeSpace) / 1GB, 2)
        $TotalSpaceGB = [math]::Round($Disk.Size / 1GB, 2)
        $FreeSpaceGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
        
        Write-Log "Disco $($Disk.DeviceID)"
        Write-Log "  Total: $TotalSpaceGB GB | Usado: $UsedSpaceGB GB | Livre: $FreeSpaceGB GB ($([math]::Round($FreeSpacePercent, 2))%)"
        
        if ($FreeSpacePercent -lt 10) {
            Write-Log "  ALERTA: Pouco espaço livre no disco $($Disk.DeviceID)!" -Level "WARNING"
        }
    }
    
    # Verificar saúde física dos discos (S.M.A.R.T.)
    try {
        $PhysicalDisks = Get-PhysicalDisk
        foreach ($PhysDisk in $PhysicalDisks) {
            Write-Log "Disco Físico $($PhysDisk.DeviceID): Saúde = $($PhysDisk.HealthStatus), Tipo = $($PhysDisk.MediaType)"
            
            if ($PhysDisk.HealthStatus -ne "Healthy") {
                Write-Log "ALERTA: Disco físico $($PhysDisk.DeviceID) com problemas de saúde!" -Level "WARNING"
            }
        }
    }
    catch {
        Write-Log "Erro na verificação de discos físicos: $($_.Exception.Message)" -Level "ERROR"
    }
    
    # Desfragmentação (apenas para HDDs)
    foreach ($Disk in $Disks) {
        try {
            $DefragAnalysis = Optimize-Volume -DriveLetter $Disk.DeviceID.Replace(":", "") -Analyze -Verbose
            Write-Log "Análise de fragmentação do disco $($Disk.DeviceID) concluída"
        }
        catch {
            Write-Log "Erro na análise de fragmentação do disco $($Disk.DeviceID) : $($_.Exception.Message)" -Level "ERROR"
        }
    }
}

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Analyze-DiskHealth 