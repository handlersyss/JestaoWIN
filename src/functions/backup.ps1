# Funções de Backup

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

# Exportar funções para uso em outros módulos
Export-ModuleMember -Function Start-AutomatedBackup 