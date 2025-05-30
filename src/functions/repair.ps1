# Funções de Reparo do Sistema

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

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Repair-SystemFiles 