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

# Importar módulos
$ModulePath = Join-Path $PSScriptRoot "src"
Import-Module (Join-Path $ModulePath "config\config.ps1")
Import-Module (Join-Path $ModulePath "utils\logger.ps1")
Import-Module (Join-Path $ModulePath "functions\cleanup.ps1")
Import-Module (Join-Path $ModulePath "functions\services.ps1")
Import-Module (Join-Path $ModulePath "functions\updates.ps1")
Import-Module (Join-Path $ModulePath "functions\monitoring.ps1")
Import-Module (Join-Path $ModulePath "functions\repair.ps1")
Import-Module (Join-Path $ModulePath "functions\logs.ps1")
Import-Module (Join-Path $ModulePath "functions\security.ps1")
Import-Module (Join-Path $ModulePath "functions\network.ps1")
Import-Module (Join-Path $ModulePath "functions\backup.ps1")
Import-Module (Join-Path $ModulePath "functions\disk.ps1")
Import-Module (Join-Path $ModulePath "functions\programs.ps1")
Import-Module (Join-Path $ModulePath "functions\report.ps1")

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
    Write-Host "13. 📦 Gerenciar Programas (Winget)" -ForegroundColor Magenta
    Write-Host "0.  ❌ Sair" -ForegroundColor Red
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

# Função de Manutenção Completa
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

    Manage-ProgramsWithWinget
    Write-Host "✓ Atualização de programas concluída" -ForegroundColor Green
    
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    Write-Log "=== MANUTENÇÃO COMPLETA FINALIZADA ===" -Level "INFO"
    Write-Log "Tempo total: $($Duration.Minutes) minutos e $($Duration.Seconds) segundos"
    Write-Host "Manutenção completa finalizada em $($Duration.Minutes)m $($Duration.Seconds)s" -ForegroundColor Green
}

# MENU PRINCIPAL E LOOP DE EXECUÇÃO
function Start-MaintenanceSystem {
    Write-Log "Sistema de Manutenção Windows iniciado"
    
    do {
        Show-MainMenu
        $Choice = Read-Host "Selecione uma opção (0-13)"
        
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
            "13" { Manage-ProgramsWithWinget; Read-Host "Pressione Enter para continuar" }
            "0" { 
                Write-Log "Sistema de Manutenção Windows finalizado"
                Write-Host "Sistema finalizado. Log salvo em: $LogPath" -ForegroundColor Green
                break 
            }
            default { 
                Write-Host "Opção inválida! Selecione uma opção entre 0 e 13." -ForegroundColor Red
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