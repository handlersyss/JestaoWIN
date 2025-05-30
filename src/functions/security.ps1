# Funções de Segurança

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

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Configure-FirewallSecurity 