#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Script Completo de Manutenção e Otimização do Windows
.DESCRIPTION
    Realiza limpeza, otimização, monitoramento e manutenção completa do sistema Windows
.AUTHOR
    Sistema de Administração Windows
.VERSION
    2.0
#>

# Configurações e Variáveis Globais
$ErrorActionPreference = "SilentlyContinue"
$LogPath = "$env:TEMP\WindowsMaintenance_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$BackupPath = "C:\Backup_Sistema"

# Função para Logging
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value $LogEntry
    Write-Host $LogEntry -ForegroundColor $(if($Level -eq "ERROR") {"Red"} elseif($Level -eq "WARNING") {"Yellow"} else {"Green"})
}

# Função Principal de Menu
function Show-MainMenu {
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "           SISTEMA DE MANUTENÇÃO E OTIMIZAÇÃO WINDOWS           " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1.  🧹 Limpeza Completa de Arquivos Temporários" -ForegroundColor Green
    Write-Host "2.  ⚡ Otimização de Serviços do Windows" -ForegroundColor Green
    Write-Host "3.  🔄 Gerenciamento de Atualizações" -ForegroundColor Green
    Write-Host "4.  📊 Monitoramento de CPU e Memória" -ForegroundColor Green
    Write-Host "5.  🔧 Reparo de Arquivos do Sistema" -ForegroundColor Green
    Write-Host "6.  📋 Gerenciamento de Logs" -ForegroundColor Green
    Write-Host "7.  🛡️ Configuração de Firewall e Segurança" -ForegroundColor Green
    Write-Host "8.  🌐 Configuração e Análise de Rede" -ForegroundColor Green
    Write-Host "9.  💾 Automação de Backup" -ForegroundColor Green
    Write-Host "10. 💿 Análise e Reparo de Disco" -ForegroundColor Green
    Write-Host "11. 🚀 Executar Manutenção Completa" -ForegroundColor Yellow
    Write-Host "12. 📊 Relatório do Sistema" -ForegroundColor Cyan
    Write-Host "0.  ❌ Sair" -ForegroundColor Red
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

# 1. LIMPEZA DE ARQUIVOS TEMPORÁRIOS
function Start-TempFileCleanup {
    Write-Log "Iniciando limpeza de arquivos temporários"
    
    $CleanupPaths = @(
        "$env:TEMP\*",
        "$env:WINDIR\Temp\*",
        "$env:WINDIR\Prefetch\*",
        "$env:LOCALAPPDATA\Temp\*",
        "$env:WINDIR\SoftwareDistribution\Download\*"
    )
    
    $TotalFreed = 0
    
    foreach ($Path in $CleanupPaths) {
        try {
            $SizeBefore = (Get-ChildItem -Path (Split-Path $Path) -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
            $SizeAfter = (Get-ChildItem -Path (Split-Path $Path) -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            $Freed = $SizeBefore - $SizeAfter
            $TotalFreed += $Freed
            Write-Log "Limpeza em $(Split-Path $Path): $([math]::Round($Freed/1MB, 2)) MB liberados"
        }
        catch {
            Write-Log "Erro na limpeza de $Path : $($_.Exception.Message)" -Level "ERROR"
        }
    }
    
    # Limpeza de Cache de Navegadores
    Clear-BrowserCache
    
    # Limpeza de arquivos de usuários
    Clear-UserTempFiles
    
    Write-Log "Limpeza concluída. Total liberado: $([math]::Round($TotalFreed/1MB, 2)) MB"
}

function Clear-BrowserCache {
    Write-Log "Limpando cache de navegadores"
    
    # Chrome
    $ChromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*"
    if (Test-Path (Split-Path $ChromePath)) {
        Remove-Item -Path $ChromePath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Cache do Chrome limpo"
    }
    
    # Edge
    $EdgePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*"
    if (Test-Path (Split-Path $EdgePath)) {
        Remove-Item -Path $EdgePath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Cache do Edge limpo"
    }
    
    # Internet Explorer
    RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
    Write-Log "Cache do Internet Explorer limpo"
}

function Clear-UserTempFiles {
    Write-Log "Limpando arquivos temporários de usuários"
    
    $Users = Get-ChildItem -Path "C:\Users" -Directory
    foreach ($User in $Users) {
        $UserTempPath = "$($User.FullName)\AppData\Local\Temp\*"
        if (Test-Path (Split-Path $UserTempPath)) {
            Remove-Item -Path $UserTempPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Arquivos temporários do usuário $($User.Name) limpos"
        }
    }
}

# 2. OTIMIZAÇÃO DE SERVIÇOS
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

# 3. GERENCIAMENTO DE ATUALIZAÇÕES
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

# 4. MONITORAMENTO DE SISTEMA
function Monitor-SystemPerformance {
    Write-Log "Iniciando monitoramento de performance do sistema"
    
    # CPU Usage
    $CPUUsage = Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 5
    $AvgCPU = ($CPUUsage.CounterSamples | Measure-Object CookedValue -Average).Average
    
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

# 5. REPARO DE ARQUIVOS DO SISTEMA
function Repair-SystemFiles {
    Write-Log "Iniciando reparo de arquivos do sistema"
    
    # SFC Scan
    Write-Log "Executando SFC /scannow..."
    $SFCResult = Start-Process -FilePath "sfc" -ArgumentList "/scannow" -Wait -PassThru -WindowStyle Hidden
    if ($SFCResult.ExitCode -eq 0) {
        Write-Log "SFC scan concluído com sucesso"
    } else {
        Write-Log "SFC scan encontrou problemas" -Level "WARNING"
    }
    
    # DISM Health Check
    Write-Log "Executando DISM health check..."
    $DISMScan = Start-Process -FilePath "DISM" -ArgumentList "/Online /Cleanup-Image /ScanHealth" -Wait -PassThru -WindowStyle Hidden
    if ($DISMScan.ExitCode -eq 0) {
        Write-Log "DISM scan health concluído"
        
        # DISM Restore Health se necessário
        $DISMRestore = Start-Process -FilePath "DISM" -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -PassThru -WindowStyle Hidden
        if ($DISMRestore.ExitCode -eq 0) {
            Write-Log "DISM restore health concluído com sucesso"
        }
    }
    
    # Check Disk
    Write-Log "Executando verificação de disco..."
    $Drives = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    foreach ($Drive in $Drives) {
        $ChkDskResult = Start-Process -FilePath "chkdsk" -ArgumentList "$($Drive.DeviceID) /f /r" -Wait -PassThru -WindowStyle Hidden
        Write-Log "Check disk $($Drive.DeviceID) - Exit Code: $($ChkDskResult.ExitCode)"
    }
}

# 6. GERENCIAMENTO DE LOGS
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

# 7. FIREWALL E SEGURANÇA
function Configure-FirewallSecurity {
    Write-Log "Configurando Firewall e Segurança"
    
    # Verificar status do Windows Firewall
    $FirewallProfiles = Get-NetFirewallProfile
    foreach ($Profile in $FirewallProfiles) {
        if ($Profile.Enabled -eq $false) {
            Set-NetFirewallProfile -Profile $Profile.Name -Enabled True
            Write-Log "Firewall habilitado para perfil $($Profile.Name)"
        } else {
            Write-Log "Firewall já ativo para perfil $($Profile.Name)"
        }
    }
    
    # Configurar regras básicas de segurança
    $SecurityRules = @(
        @{DisplayName="Block Suspicious Ports"; Direction="Inbound"; Action="Block"; LocalPort="135,139,445,1433,3389"},
        @{DisplayName="Allow HTTPS"; Direction="Inbound"; Action="Allow"; LocalPort="443"},
        @{DisplayName="Allow HTTP"; Direction="Inbound"; Action="Allow"; LocalPort="80"}
    )
    
    foreach ($Rule in $SecurityRules) {
        try {
            if (!(Get-NetFirewallRule -DisplayName $Rule.DisplayName -ErrorAction SilentlyContinue)) {
                New-NetFirewallRule @Rule -Protocol TCP
                Write-Log "Regra de firewall criada: $($Rule.DisplayName)"
            }
        }
        catch {
            Write-Log "Erro ao criar regra $($Rule.DisplayName) : $($_.Exception.Message)" -Level "ERROR"
        }
    }
    
    # Verificar Windows Defender
    $DefenderStatus = Get-MpComputerStatus
    Write-Log "Windows Defender - Antivirus: $($DefenderStatus.AntivirusEnabled), Real-time: $($DefenderStatus.RealTimeProtectionEnabled)"
    
    if (!$DefenderStatus.AntivirusEnabled) {
        Write-Log "ALERTA: Windows Defender Antivirus desabilitado!" -Level "WARNING"
    }
}

# 8. CONFIGURAÇÃO DE REDE
function Analyze-NetworkConfiguration {
    Write-Log "Analisando configuração de rede"
    
    # Informações de adaptadores de rede
    $NetworkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($Adapter in $NetworkAdapters) {
        $IPConfig = Get-NetIPAddress -InterfaceIndex $Adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
        Write-Log "Adaptador: $($Adapter.Name) - IP: $($IPConfig.IPAddress) - Status: $($Adapter.Status)"
    }
    
    # Teste de conectividade
    $TestHosts = @("8.8.8.8", "1.1.1.1", "google.com")
    foreach ($Host in $TestHosts) {
        $PingResult = Test-Connection -ComputerName $Host -Count 2 -Quiet
        Write-Log "Conectividade para $Host : $(if($PingResult){"OK"}else{"FALHA"})"
    }
    
    # Verificar configurações DNS
    $DNSServers = Get-DnsClientServerAddress -AddressFamily IPv4
    foreach ($DNS in $DNSServers) {
        if ($DNS.ServerAddresses) {
            Write-Log "Interface $($DNS.InterfaceAlias) - DNS: $($DNS.ServerAddresses -join ', ')"
        }
    }
    
    # Flush DNS Cache
    Clear-DnsClientCache
    Write-Log "Cache DNS limpo"
    
    # Resetar Winsock se necessário
    netsh winsock reset | Out-Null
    Write-Log "Winsock reset executado"
}

# 9. AUTOMAÇÃO DE BACKUP
function Start-AutomatedBackup {
    Write-Log "Iniciando backup automatizado"
    
    if (!(Test-Path $BackupPath)) {
        New-Item -Path $BackupPath -ItemType Directory -Force
        Write-Log "Diretório de backup criado: $BackupPath"
    }
    
    # Backup de arquivos críticos do sistema
    $BackupItems = @(
        @{Source="C:\Windows\System32\drivers\etc\hosts"; Destination="$BackupPath\hosts_$(Get-Date -Format 'yyyyMMdd').bak"},
        @{Source="HKLM:\SOFTWARE"; Destination="$BackupPath\registry_software_$(Get-Date -Format 'yyyyMMdd').reg"},
        @{Source="HKLM:\SYSTEM"; Destination="$BackupPath\registry_system_$(Get-Date -Format 'yyyyMMdd').reg"}
    )
    
    foreach ($Item in $BackupItems) {
        try {
            if ($Item.Source.StartsWith("HKLM:")) {
                # Backup de registro
                $RegPath = $Item.Source.Replace("HKLM:\", "HKEY_LOCAL_MACHINE\")
                reg export $RegPath $Item.Destination /y | Out-Null
                Write-Log "Backup do registro criado: $($Item.Destination)"
            } else {
                # Backup de arquivo
                if (Test-Path $Item.Source) {
                    Copy-Item -Path $Item.Source -Destination $Item.Destination -Force
                    Write-Log "Backup criado: $($Item.Destination)"
                }
            }
        }
        catch {
            Write-Log "Erro no backup de $($Item.Source) : $($_.Exception.Message)" -Level "ERROR"
        }
    }
    
    # Backup de perfis de usuário críticos
    $ImportantFolders = @("Desktop", "Documents", "Downloads")
    $Users = Get-ChildItem -Path "C:\Users" -Directory | Where-Object { $_.Name -notin @("Public", "Default", "Default User") }
    
    foreach ($User in $Users) {
        $UserBackupPath = "$BackupPath\Users\$($User.Name)"
        if (!(Test-Path $UserBackupPath)) {
            New-Item -Path $UserBackupPath -ItemType Directory -Force
        }
        
        foreach ($Folder in $ImportantFolders) {
            $SourcePath = "$($User.FullName)\$Folder"
            $DestPath = "$UserBackupPath\$Folder"
            
            if (Test-Path $SourcePath) {
                try {
                    robocopy $SourcePath $DestPath /MIR /R:3 /W:1 /LOG+:$LogPath | Out-Null
                    Write-Log "Backup da pasta $Folder do usuário $($User.Name) concluído"
                }
                catch {
                    Write-Log "Erro no backup da pasta $Folder do usuário $($User.Name) : $($_.Exception.Message)" -Level "ERROR"
                }
            }
        }
    }
    
    Write-Log "Backup automatizado concluído"
}

# 10. ANÁLISE DE DISCO
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

# 11. MANUTENÇÃO COMPLETA
function Start-CompleteMaintenance {
    Write-Log "=== INICIANDO MANUTENÇÃO COMPLETA DO SISTEMA ===" -Level "INFO"
    Write-Host "Executando manutenção completa... Isso pode levar alguns minutos." -ForegroundColor Yellow
    
    $StartTime = Get-Date
    
    # Executar todas as funções
    Start-TempFileCleanup
    Write-Host "✓ Limpeza de arquivos concluída" -ForegroundColor Green
    
    Optimize-WindowsServices
    Write-Host "✓ Otimização de serviços concluída" -ForegroundColor Green
    
    Repair-SystemFiles
    Write-Host "✓ Reparo de arquivos do sistema concluído" -ForegroundColor Green
    
    Manage-SystemLogs
    Write-Host "✓ Gerenciamento de logs concluído" -ForegroundColor Green
    
    Configure-FirewallSecurity
    Write-Host "✓ Configuração de segurança concluída" -ForegroundColor Green
    
    Analyze-NetworkConfiguration
    Write-Host "✓ Análise de rede concluída" -ForegroundColor Green
    
    Analyze-DiskHealth
    Write-Host "✓ Análise de disco concluída" -ForegroundColor Green
    
    Start-AutomatedBackup
    Write-Host "✓ Backup automatizado concluído" -ForegroundColor Green
    
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    Write-Log "=== MANUTENÇÃO COMPLETA FINALIZADA ===" -Level "INFO"
    Write-Log "Tempo total: $($Duration.Minutes) minutos e $($Duration.Seconds) segundos"
    Write-Host "Manutenção completa finalizada em $($Duration.Minutes)m $($Duration.Seconds)s" -ForegroundColor Green
}

# 12. RELATÓRIO DO SISTEMA
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
    $CPUUsage = Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 3
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

# MENU PRINCIPAL E LOOP DE EXECUÇÃO
function Start-MaintenanceSystem {
    Write-Log "Sistema de Manutenção Windows iniciado"
    
    do {
        Show-MainMenu
        $Choice = Read-Host "Selecione uma opção (0-12)"
        
        switch ($Choice) {
            "1" { Start-TempFileCleanup; Read-Host "Pressione Enter para continuar" }
            "2" { Optimize-WindowsServices; Read-Host "Pressione Enter para continuar" }
            "3" { Manage-WindowsUpdates; Read-Host "Pressione Enter para continuar" }
            "4" { Monitor-SystemPerformance; Read-Host "Pressione Enter para continuar" }
            "5" { Repair-SystemFiles; Read-Host "Pressione Enter para continuar" }
            "6" { Manage-SystemLogs; Read-Host "Pressione Enter para continuar" }
            "7" { Configure-FirewallSecurity; Read-Host "Pressione Enter para continuar" }
            "8" { Analyze-NetworkConfiguration; Read-Host "Pressione Enter para continuar" }
            "9" { Start-AutomatedBackup; Read-Host "Pressione Enter para continuar" }
            "10" { Analyze-DiskHealth; Read-Host "Pressione Enter para continuar" }
            "11" { Start-CompleteMaintenance; Read-Host "Pressione Enter para continuar" }
            "12" { Generate-SystemReport; Read-Host "Pressione Enter para continuar" }
            "0" { 
                Write-Log "Sistema de Manutenção Windows finalizado"
                Write-Host "Sistema finalizado. Log salvo em: $LogPath" -ForegroundColor Green
                break 
            }
            default { 
                Write-Host "Opção inválida! Selecione uma opção entre 0 e 12." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    } while ($Choice -ne "0")
}

# VERIFICAÇÃO DE PRIVILÉGIOS E INICIALIZAÇÃO
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERRO: Este script requer privilégios de administrador!" -ForegroundColor Red
    Write-Host "Clique com o botão direito no PowerShell e selecione 'Executar como administrador'" -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Verificar versão do PowerShell
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "AVISO: PowerShell 5.0 ou superior é recomendado para melhor compatibilidade" -ForegroundColor Yellow
}

# Criar diretório de logs se não existir
$LogDir = Split-Path $LogPath
if (!(Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}

# Inicializar o sistema
Clear-Host
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "    INICIALIZANDO SISTEMA DE MANUTENÇÃO E OTIMIZAÇÃO WINDOWS    " -ForegroundColor Cyan  
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "✓ Privilégios de administrador verificados" -ForegroundColor Green
Write-Host "✓ Sistema de log inicializado: $LogPath" -ForegroundColor Green
Write-Host "✓ Diretório de backup configurado: $BackupPath" -ForegroundColor Green
Write-Host ""
Write-Host "Pressione Enter para continuar..." -ForegroundColor Yellow
Read-Host

# Iniciar o sistema principal
Start-MaintenanceSystem