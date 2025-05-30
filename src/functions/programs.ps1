# Funções de Gerenciamento de Programas

function Manage-ProgramsWithWinget {
    Write-Log "Iniciando gerenciamento de programas com Winget"
    
    # Verificar se winget está disponível
    try {
        $WingetVersion = winget --version
        Write-Log "Winget encontrado: $WingetVersion"
    }
    catch {
        Write-Log "Winget não encontrado. Tentando instalar..." -Level "WARNING"
        try {
            # Tentar instalar App Installer (inclui winget)
            Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
            Write-Log "Winget instalado com sucesso"
        }
        catch {
            Write-Log "Erro ao instalar Winget: $($_.Exception.Message)" -Level "ERROR"
            return
        }
    }
    
    Write-Host "Verificando programas que podem ser atualizados..." -ForegroundColor Yellow
    
    # Listar programas que podem ser atualizados
    try {
        $UpgradeList = winget upgrade
        Write-Log "Lista de atualizações obtida"
        
        # Mostrar lista para o usuário
        Write-Host "`nProgramas disponíveis para atualização:" -ForegroundColor Cyan
        Write-Host $UpgradeList -ForegroundColor White
        
        # Perguntar se deseja atualizar todos
        $UpdateChoice = Read-Host "`nDeseja atualizar todos os programas automaticamente? (S/N)"
        
        if ($UpdateChoice -eq "S" -or $UpdateChoice -eq "s") {
            Write-Host "Atualizando todos os programas... Isso pode levar alguns minutos." -ForegroundColor Yellow
            
            # Atualizar todos os programas
            $UpdateResult = winget upgrade --all --accept-package-agreements --accept-source-agreements --silent
            
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Todos os programas foram atualizados com sucesso"
                Write-Host "✓ Atualizações concluídas com sucesso!" -ForegroundColor Green
            } else {
                Write-Log "Algumas atualizações podem ter falhado. Código de saída: $LASTEXITCODE" -Level "WARNING"
                Write-Host "⚠ Algumas atualizações podem ter falhado. Verifique o log." -ForegroundColor Yellow
            }
        }
        else {
            # Atualização manual/seletiva
            Write-Host "Você pode atualizar programas individualmente usando:" -ForegroundColor Cyan
            Write-Host "winget upgrade <nome-do-programa>" -ForegroundColor White
        }
        
    }
    catch {
        Write-Log "Erro ao verificar atualizações: $($_.Exception.Message)" -Level "ERROR"
        Write-Host "Erro ao verificar atualizações. Verifique se o Winget está funcionando corretamente." -ForegroundColor Red
    }
    
    # Mostrar programas instalados (opcional)
    $ShowInstalled = Read-Host "`nDeseja ver a lista de programas instalados? (S/N)"
    if ($ShowInstalled -eq "S" -or $ShowInstalled -eq "s") {
        Write-Host "`nProgramas instalados via Winget:" -ForegroundColor Cyan
        try {
            $InstalledPrograms = winget list
            Write-Host $InstalledPrograms -ForegroundColor White
        }
        catch {
            Write-Log "Erro ao listar programas instalados: $($_.Exception.Message)" -Level "ERROR"
        }
    }
}

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Manage-ProgramsWithWinget 