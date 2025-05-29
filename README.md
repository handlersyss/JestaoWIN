# 🛠️ Script de Manutenção Automática do Windows

Um script PowerShell completo para otimização, limpeza e manutenção automática de sistemas Windows.

## 📋 Índice

- [Funcionalidades](#-funcionalidades)
- [Funcionalidades Especiais](#-funcionalidades-especiais)
- [Requisitos](#️-requisitos)
- [Como Usar](#-como-usar)
- [Estrutura do Menu](#-estrutura-do-menu)
- [Logs e Relatórios](#-logs-e-relatórios)
- [Precauções](#️-precauções)
- [Suporte](#-suporte)

## 🔧 Funcionalidades

### 1. **Limpeza de Arquivos Temporários**
- Remove arquivos das pastas Temp, Prefetch, Downloads do Windows Update
- Limpa cache de navegadores (Chrome, Edge, Internet Explorer)
- Limpa arquivos temporários de todos os usuários

### 2. **Otimização de Serviços**
- Desabilita serviços desnecessários
- Otimiza configurações de serviços críticos
- Melhora a performance geral do sistema

### 3. **Gerenciamento de Atualizações**
- Verifica e instala atualizações críticas automaticamente
- Usa o módulo PSWindowsUpdate para controle avançado

### 4. **Monitoramento de Performance**
- Monitora CPU, memória e uso de disco em tempo real
- Identifica processos com maior consumo
- Gera alertas para problemas de performance

### 5. **Reparo de Sistema**
- Executa SFC /scannow para verificar arquivos do sistema
- Usa DISM para reparar imagens corrompidas
- Verifica integridade dos discos

### 6. **Gerenciamento de Logs**
- Arquiva logs grandes automaticamente
- Identifica eventos críticos recentes
- Mantém histórico de auditoria

### 7. **Firewall e Segurança**
- Configura regras de firewall automaticamente
- Verifica status do Windows Defender
- Implementa regras de segurança básicas

### 8. **Configuração de Rede**
- Analisa adaptadores de rede e configurações IP
- Testa conectividade com servidores externos
- Limpa cache DNS e reseta Winsock

### 9. **Backup Automatizado**
- Cria backup de arquivos críticos do sistema
- Backup de registros importantes
- Backup de pastas de usuários (Desktop, Documentos, Downloads)

### 10. **Análise de Disco**
- Verifica saúde física dos discos (S.M.A.R.T.)
- Analisa uso de espaço e fragmentação
- Gera alertas para discos com problemas

## 🚀 Funcionalidades Especiais

- **Interface de Menu Intuitiva**: Menu colorido e organizado
- **Manutenção Completa**: Executa todas as funções automaticamente
- **Relatório HTML Detalhado**: Gera relatório completo em HTML
- **Sistema de Logs Avançado**: Registra todas as operações
- **Verificação de Privilégios**: Garante execução como administrador

## ⚠️ Requisitos

- **Sistema Operacional**: Windows 10/11 ou Windows Server
- **PowerShell**: Versão 5.0 ou superior
- **Privilégios**: Administrador necessário
- **Conectividade**: Conexão com internet (para atualizações)

## 📋 Como Usar

### Instalação e Execução

1. **Salve o script** em um arquivo `.ps1` (exemplo: `ManutencaoWindows.ps1`)

2. **Abra o PowerShell como Administrador**
   - Clique com botão direito no menu Iniciar
   - Selecione "Windows PowerShell (Admin)" ou "Terminal (Admin)"

3. **Navegue até o diretório do script**
   ```powershell
   cd "C:\caminho\para\o\script"
   ```

4. **Execute o script**
   ```powershell
   .\ManutencaoWindows.ps1
   ```

5. **Escolha a opção desejada** no menu interativo

### Execução Rápida (Manutenção Completa)

Para executar todas as funções automaticamente, use a **opção 11** no menu principal.

## 🔢 Estrutura do Menu

```
1.  Limpeza de Arquivos Temporários
2.  Otimização de Serviços
3.  Gerenciamento de Atualizações
4.  Monitoramento de Performance
5.  Reparo de Sistema
6.  Gerenciamento de Logs
7.  Firewall e Segurança
8.  Configuração de Rede
9.  Backup Automatizado
10. Análise de Disco
11. Manutenção Completa (Executa tudo)
0.  Sair
```

## 📄 Logs e Relatórios

O script gera automaticamente:

- **Logs detalhados** de todas as operações
- **Relatório HTML** com resumo completo das ações executadas
- **Histórico de auditoria** para acompanhamento das manutenções

Os arquivos são salvos no mesmo diretório do script com timestamp para organização.

## ⚠️ Precauções

- **Sempre execute como Administrador** para garantir funcionamento completo
- **Faça backup** de dados importantes antes de executar
- **Teste em ambiente controlado** antes de usar em produção
- **Verifique as configurações** de serviços antes de aplicar otimizações
- **Mantenha conexão com internet** ativa durante atualizações

## 🆘 Suporte

Para questões técnicas ou problemas:

1. Verifique os logs gerados pelo script
2. Consulte o relatório HTML para detalhes das operações
3. Execute novamente com privilégios administrativos
4. Verifique conectividade de rede se houver falhas em atualizações

---

**⚡ Dica**: Para manutenção regular, agende a execução da "Manutenção Completa" semanalmente usando o Agendador de Tarefas do Windows.

**🔒 Segurança**: O script inclui verificações de integridade e não modifica arquivos críticos do sistema sem backup prévio.
