# JestaoWIN - Sistema de Manutenção e Otimização Windows

Um sistema completo de manutenção e otimização para Windows, desenvolvido em PowerShell.

## 📋 Descrição

O JestaoWIN é uma ferramenta abrangente que automatiza várias tarefas de manutenção e otimização do Windows, incluindo:

- Limpeza de arquivos temporários
- Otimização de serviços
- Gerenciamento de atualizações
- Monitoramento de sistema
- Reparo de arquivos do sistema
- Gerenciamento de logs
- Configuração de firewall e segurança
- Análise de rede
- Backup automatizado
- Análise de disco
- Gerenciamento de programas via Winget
- Geração de relatórios

## 🚀 Requisitos

- Windows 10 ou superior
- PowerShell 7 (PowerShell Core) - [Download PowerShell 7](https://aka.ms/powershell-release?tag=stable)
- Privilégios de administrador
- Conexão com a internet (para algumas funcionalidades)

## 📦 Instalação

1. Instale o PowerShell 7 (se ainda não tiver instalado)
2. Clone ou baixe este repositório
3. Navegue até a pasta do projeto
4. Execute o script principal como administrador:
   - Clique com o botão direito no PowerShell 7
   - Selecione "Executar como administrador"
   - Execute o comando:
   ```powershell
   .\jestao_win.ps1
   ```

## ⚠️ Importante

- O script DEVE ser executado no PowerShell 7 (PowerShell Core)
- O script DEVE ser executado como administrador
- Não use o Windows PowerShell (PowerShell 5.1) para executar este script
- Para verificar se está usando o PowerShell 7, execute:
  ```powershell
  $PSVersionTable.PSVersion
  ```
  A versão deve começar com 7.x.x

## 🛠️ Estrutura do Projeto

```
JestaoWIN/
├── src/
│   ├── config/
│   │   └── config.ps1
│   ├── utils/
│   │   └── logger.ps1
│   └── functions/
│       ├── cleanup.ps1
│       ├── services.ps1
│       ├── updates.ps1
│       ├── monitoring.ps1
│       ├── repair.ps1
│       ├── logs.ps1
│       ├── security.ps1
│       ├── network.ps1
│       ├── backup.ps1
│       ├── disk.ps1
│       ├── programs.ps1
│       └── report.ps1
├── jestao_win.ps1
└── README.md
```

## 📝 Funcionalidades

### 1. Limpeza de Arquivos Temporários
- Remove arquivos temporários do sistema
- Limpa cache de navegadores
- Remove arquivos temporários de usuários

### 2. Otimização de Serviços
- Desabilita serviços desnecessários
- Otimiza configurações de serviços essenciais

### 3. Gerenciamento de Atualizações
- Verifica e instala atualizações do Windows
- Gerencia atualizações de programas via Winget

### 4. Monitoramento de Sistema
- Monitora uso de CPU e memória
- Analisa processos em execução
- Gera alertas de performance

### 5. Reparo de Arquivos do Sistema
- Executa SFC /scannow
- Realiza verificação DISM
- Executa chkdsk

### 6. Gerenciamento de Logs
- Gerencia logs do sistema
- Arquivamento de logs antigos
- Monitoramento de eventos críticos

### 7. Segurança
- Configuração do Windows Firewall
- Verificação do Windows Defender
- Implementação de regras de segurança

### 8. Rede
- Análise de configuração de rede
- Testes de conectividade
- Verificação de DNS

### 9. Backup
- Backup de arquivos críticos
- Backup de perfis de usuário
- Backup do registro

### 10. Disco
- Análise de saúde dos discos
- Verificação de espaço livre
- Desfragmentação (HDDs)

### 11. Programas
- Gerenciamento via Winget
- Atualização de programas
- Listagem de programas instalados

### 12. Relatórios
- Geração de relatórios HTML
- Análise completa do sistema
- Recomendações de manutenção

## ⚠️ Avisos

- Sempre execute o script como administrador
- Faça backup dos seus dados antes de executar manutenções
- Algumas funções podem requerer reinicialização do sistema

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
