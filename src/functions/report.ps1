# Funções de Relatório

function Generate-SystemReport {
    Write-Log "Gerando relatório completo do sistema"
    
    $ReportPath = "$env:TEMP\SystemReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    
    $HTML = @"
<!DOCTYPE html>
<html>
<head>
    <title>Relatório do Sistema - $(Get-Date -Format 'dd/MM/yyyy HH:mm')</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #2c3e50; color: white; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .warning { background-color: #fff3cd; border-color: #ffeaa7; }
        .success { background-color: #d4edda; border-color: #c3e6cb; }
        .error { background-color: #f8d7da; border-color: #f5c6cb; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Relatório do Sistema Windows</h1>
        <p>Gerado em: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')</p>
        <p>Computador: $env:COMPUTERNAME</p>
        <p>Usuário: $env:USERNAME</p>
    </div>
"@
    
    # Informações do Sistema
    $SystemInfo = Get-CimInstance Win32_OperatingSystem
    $ComputerInfo = Get-CimInstance Win32_ComputerSystem
    
    $HTML += @"
    <div class="section success">
        <h2>Informações do Sistema</h2>
        <table>
            <tr><th>Sistema Operacional</th><td>$($SystemInfo.Caption) $($SystemInfo.Version)</td></tr>
            <tr><th>Arquitetura</th><td>$($SystemInfo.OSArchitecture)</td></tr>
            <tr><th>Fabricante</th><td>$($ComputerInfo.Manufacturer)</td></tr>
            <tr><th>Modelo</th><td>$($ComputerInfo.Model)</td></tr>
            <tr><th>Memória Total</th><td>$([math]::Round($ComputerInfo.TotalPhysicalMemory/1GB, 2)) GB</td></tr>
            <tr><th>Última Inicialização</th><td>$($SystemInfo.LastBootUpTime)</td></tr>
        </table>
    </div>
"@
    
    # Performance atual
    Get-Counter "\Processor(_Total)\% Processor Time" | Out-Null
    Start-Sleep -Seconds 1
    $CPUSamples = @()
    for ($i = 1; $i -le 3; $i++) {
        $Sample = Get-Counter "\Processor(_Total)\% Processor Time"
        $CPUSamples += $Sample.CounterSamples[0].CookedValue
        Start-Sleep -Seconds 1
    }
    $AvgCPU = ($CPUUsage.CounterSamples | Measure-Object CookedValue -Average).Average
    
    $TotalRAM = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
    $AvailRAM = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory * 1024
    $UsedRAM = $TotalRAM - $AvailRAM
    $MemoryUsagePercent = ($UsedRAM / $TotalRAM) * 100
    
    $PerfClass = if ($AvgCPU -gt 80 -or $MemoryUsagePercent -gt 85) { "warning" } else { "success" }
    
    $HTML += @"
    <div class="section $PerfClass">
        <h2>Performance Atual</h2>
        <table>
            <tr><th>Uso de CPU</th><td>$([math]::Round($AvgCPU, 2))%</td></tr>
            <tr><th>Uso de Memória</th><td>$([math]::Round($MemoryUsagePercent, 2))% ($([math]::Round($UsedRAM/1GB, 2)) GB / $([math]::Round($TotalRAM/1GB, 2)) GB)</td></tr>
        </table>
    </div>
"@
    
    # Informações de Disco
    $Disks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    $HTML += @"
    <div class="section">
        <h2>Informações de Disco</h2>
        <table>
            <tr><th>Drive</th><th>Total</th><th>Usado</th><th>Livre</th><th>% Livre</th></tr>
"@
    
    foreach ($Disk in $Disks) {
        $FreeSpacePercent = ($Disk.FreeSpace / $Disk.Size) * 100
        $UsedSpaceGB = [math]::Round(($Disk.Size - $Disk.FreeSpace) / 1GB, 2)
        $TotalSpaceGB = [math]::Round($Disk.Size / 1GB, 2)
        $FreeSpaceGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
        
        $HTML += "<tr><td>$($Disk.DeviceID)</td><td>$TotalSpaceGB GB</td><td>$UsedSpaceGB GB</td><td>$FreeSpaceGB GB</td><td>$([math]::Round($FreeSpacePercent, 2))%</td></tr>"
    }
    
    $HTML += @"
        </table>
    </div>
"@
    
    # Serviços Críticos
    $CriticalServices = @("Winmgmt", "EventLog", "Spooler", "BITS", "wuauserv", "MpsSvc")
    $HTML += @"
    <div class="section">
        <h2>Status de Serviços Críticos</h2>
        <table>
            <tr><th>Serviço</th><th>Status</th><th>Tipo de Inicialização</th></tr>
"@
    
    foreach ($ServiceName in $CriticalServices) {
        $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($Service) {
            $ServiceWMI = Get-CimInstance Win32_Service -Filter "Name='$ServiceName'"
            $HTML += "<tr><td>$($Service.DisplayName)</td><td>$($Service.Status)</td><td>$($ServiceWMI.StartMode)</td></tr>"
        }
    }
    
    $HTML += @"
        </table>
    </div>
"@
    
    # Processos com maior consumo
    $TopProcesses = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10
    $HTML += @"
    <div class="section">
        <h2>Top 10 Processos por Uso de Memória</h2>
        <table>
            <tr><th>Processo</th><th>PID</th><th>Memória (MB)</th><th>CPU Time</th></tr>
"@
    
    foreach ($Process in $TopProcesses) {
        $MemoryMB = [math]::Round($Process.WorkingSet / 1MB, 2)
        $HTML += "<tr><td>$($Process.ProcessName)</td><td>$($Process.Id)</td><td>$MemoryMB</td><td>$($Process.CPU)</td></tr>"
    }
    
    $HTML += @"
        </table>
    </div>
"@
    
    # Configuração de Rede
    $NetworkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    $HTML += @"
    <div class="section">
        <h2>Configuração de Rede</h2>
        <table>
            <tr><th>Adaptador</th><th>Status</th><th>Velocidade</th><th>Endereço IP</th></tr>
"@
    
    foreach ($Adapter in $NetworkAdapters) {
        $IPConfig = Get-NetIPAddress -InterfaceIndex $Adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
        $Speed = if ($Adapter.LinkSpeed -gt 1000000000) { "$([math]::Round($Adapter.LinkSpeed/1000000000, 1)) Gbps" } else { "$([math]::Round($Adapter.LinkSpeed/1000000, 0)) Mbps" }
        $HTML += "<tr><td>$($Adapter.Name)</td><td>$($Adapter.Status)</td><td>$Speed</td><td>$($IPConfig.IPAddress)</td></tr>"
    }
    
    $HTML += @"
        </table>
    </div>
"@
    
    # Eventos de Sistema Recentes
    try {
        $RecentErrors = Get-WinEvent -FilterHashtable @{LogName="System"; Level=2; StartTime=(Get-Date).AddDays(-7)} -MaxEvents 5 -ErrorAction SilentlyContinue
        if ($RecentErrors) {
            $HTML += @"
    <div class="section warning">
        <h2>Erros Recentes do Sistema (Últimos 7 dias)</h2>
        <table>
            <tr><th>Data/Hora</th><th>ID do Evento</th><th>Origem</th><th>Descrição</th></tr>
"@
            foreach ($Event in $RecentErrors) {
                $HTML += "<tr><td>$($Event.TimeCreated)</td><td>$($Event.Id)</td><td>$($Event.ProviderName)</td><td>$($Event.LevelDisplayName): $($Event.Message.Substring(0, [Math]::Min(100, $Event.Message.Length)))...</td></tr>"
            }
            $HTML += "</table></div>"
        }
    }
    catch {
        Write-Log "Erro ao obter eventos do sistema: $($_.Exception.Message)" -Level "ERROR"
    }
    
    # Finalizar HTML
    $HTML += @"
    <div class="section">
        <h2>Informações de Manutenção</h2>
        <p><strong>Log de Manutenção:</strong> $LogPath</p>
        <p><strong>Diretório de Backup:</strong> $BackupPath</p>
        <p><strong>Próxima Manutenção Recomendada:</strong> $((Get-Date).AddDays(7).ToString('dd/MM/yyyy'))</p>
    </div>
    
    <div class="section">
        <h2>Recomendações</h2>
        <ul>
"@
    
    # Adicionar recomendações baseadas na análise
    if ($AvgCPU -gt 80) {
        $HTML += "<li class='warning'>Alto uso de CPU detectado. Considere verificar processos em execução.</li>"
    }
    if ($MemoryUsagePercent -gt 85) {
        $HTML += "<li class='warning'>Alto uso de memória detectado. Considere adicionar mais RAM ou fechar programas desnecessários.</li>"
    }
    
    foreach ($Disk in $Disks) {
        $FreeSpacePercent = ($Disk.FreeSpace / $Disk.Size) * 100
        if ($FreeSpacePercent -lt 15) {
            $HTML += "<li class='warning'>Pouco espaço livre no disco $($Disk.DeviceID). Considere limpar arquivos ou expandir o armazenamento.</li>"
        }
    }
    
    $HTML += @"
        <li>Execute a manutenção completa semanalmente para manter o sistema otimizado.</li>
        <li>Mantenha o sistema sempre atualizado com as últimas atualizações de segurança.</li>
        <li>Realize backups regulares dos seus dados importantes.</li>
        </ul>
    </div>
    
    <footer style="text-align: center; margin-top: 30px; padding: 20px; background-color: #f8f9fa; border-radius: 5px;">
        <p><strong>Sistema de Manutenização e Otimização Windows v2.0</strong></p>
        <p>Relatório gerado automaticamente em $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')</p>
    </footer>
</body>
</html>
"@
    
    # Salvar o relatório
    $HTML | Out-File -FilePath $ReportPath -Encoding UTF8
    
    Write-Log "Relatório do sistema gerado: $ReportPath"
    Write-Host "Relatório salvo em: $ReportPath" -ForegroundColor Green
    
    # Abrir o relatório no navegador
    Start-Process $ReportPath
}

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Generate-SystemReport 