# Funções de Limpeza do Sistema

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

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Start-TempFileCleanup, Clear-BrowserCache, Clear-UserTempFiles 