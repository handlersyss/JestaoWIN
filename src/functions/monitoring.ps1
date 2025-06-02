# Funções de Monitoramento do Sistema

function Monitor-SystemPerformance {
    Write-Log "Iniciando monitoramento de performance do sistema"
    
    # CPU Usage - Método alternativo usando WMI
    Write-Host "Coletando dados de CPU... aguarde alguns segundos..." -ForegroundColor Yellow

    # Coletar amostras de CPU usando WMI
    $CPUSamples = @()
    for ($i = 1; $i -le 5; $i++) {
        $CPU = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty LoadPercentage
        if ($CPU -ne $null) {
            $CPUSamples += $CPU
        }
        Start-Sleep -Seconds 1
        Write-Host "Amostra $i/5 coletada..." -ForegroundColor Gray
    }

    $AvgCPU = if ($CPUSamples.Count -gt 0) {
        ($CPUSamples | Measure-Object -Average).Average
    } else {
        # Método alternativo caso o primeiro falhe
        try {
            $CPU = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty LoadPercentage
            if ($CPU -ne $null) {
                $CPU
            } else {
                0
            }
        } catch {
            0
        }
    }
    
    # Memory Usage  
    $TotalRAM = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
    $AvailRAM = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory * 1024
    $UsedRAM = $TotalRAM - $AvailRAM
    $MemoryUsagePercent = ($UsedRAM / $TotalRAM) * 100
    
    # Disk Usage
    $DiskInfo = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    
    Write-Log "=== MONITORAMENTO DE PERFORMANCE ==="
    Write-Log "CPU Usage: $([math]::Round($AvgCPU, 2))%"
    Write-Log "Memory Usage: $([math]::Round($MemoryUsagePercent, 2))% ($([math]::Round($UsedRAM/1GB, 2)) GB / $([math]::Round($TotalRAM/1GB, 2)) GB)"
    
    foreach ($Disk in $DiskInfo) {
        $UsedSpace = $Disk.Size - $Disk.FreeSpace
        $UsagePercent = ($UsedSpace / $Disk.Size) * 100
        Write-Log "Disco $($Disk.DeviceID) Usage: $([math]::Round($UsagePercent, 2))% ($([math]::Round($UsedSpace/1GB, 2)) GB / $([math]::Round($Disk.Size/1GB, 2)) GB)"
    }
    
    # Processos com maior consumo
    $TopCPUProcesses = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5
    Write-Log "Top 5 processos por CPU:"
    foreach ($Process in $TopCPUProcesses) {
        Write-Log "  - $($Process.ProcessName): CPU Time = $($Process.CPU)"
    }
    
    # Alertas de performance
    if ($AvgCPU -gt 80) {
        Write-Log "ALERTA: Alto uso de CPU ($([math]::Round($AvgCPU, 2))%)" -Level "WARNING"
    }
    if ($MemoryUsagePercent -gt 85) {
        Write-Log "ALERTA: Alto uso de memória ($([math]::Round($MemoryUsagePercent, 2))%)" -Level "WARNING"
    }
}

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Monitor-SystemPerformance 