# Funções de Rede

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

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Analyze-NetworkConfiguration 