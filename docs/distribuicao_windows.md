# Guia de Distribuição e Implantação no Windows — be EASY Print 🖨️

Este guia explica como compilar, gerar o pacote de distribuição executável (`.exe`) e configurar a operação do totem no Windows com inicialização automática e suporte a **IP dinâmico**.

---

## 🏗️ Como Funciona o Pacote Windows

O **be EASY Print** no Windows é distribuído como um único pacote executável autossuficiente (`be_easy_app.exe`) que reúne:
1. **Frontend do Totem**: Interface gráfica moderna para a mercearia/condomínio (conexão Wi-Fi, upload por pendrive/arrastar, tela de pagamento e status).
2. **Servidor HTTP Local Embutido**: Servidor Shelf executando em background na porta `8080` (recebimento de uploads do celular, geração de cobrança PIX, fila de impressão e spooler).
3. **Web App Mobile**: Arquivos estáticos HTML/JS hospedados pelo próprio servidor local para acesso dos clientes na rede Wi-Fi via celular (`http://<IP_DO_COMPUTADOR>:8080/app`).

---

## 🚀 Como Gerar o Executável (`dist_windows/`)

### Pré-requisitos na máquina Windows:
- **Flutter SDK** (`>= 3.0.0`) configurado nas variáveis de ambiente (`PATH`).
- **Visual Studio 2022** (ou 2019) com a carga de trabalho **"Desenvolvimento para desktop com C++"** (*Desktop development with C++*) instalada.
- **Git**.

### Passo a Passo em 1 Comando:

No computador Windows, abra o PowerShell ou Prompt de Comando na raiz do projeto e execute:

```cmd
scripts\build_windows.bat
```
*(ou no PowerShell: `.\scripts\build_windows.ps1`)*

O script executará automaticamente:
1. Compilação do Web App mobile (`flutter build web --release`).
2. Sincronização dos assets estáticos para a pasta do servidor.
3. Compilação nativa C++/Flutter do executável Windows (`flutter build windows --release`).
4. Montagem da pasta de produção final em:
   ```text
   dist_windows/
   ├── be_easy_app.exe          # Executável do Totem + Servidor integrado
   ├── flutter_windows.dll      # Biblioteca do Flutter Desktop
   ├── data/                    # Assets gráficos e fontes
   ├── web/                     # Web App mobile compilado servido para os celulares
   ├── config.json              # Chave PIX, preço por página e configurações
   ├── instalar_inicializacao.bat # Configura inicialização no boot com 1 clique
   └── remover_inicializacao.bat  # Remove da inicialização
   ```

Você pode copiar a pasta `dist_windows` inteira para qualquer computador com Windows 10 ou 11 (ex: `C:\be_easy_print\`).

---

## ⚡ Inicialização Automática no Boot do Windows (Modo Totem)

Para que o totem de autoatendimento e o servidor iniciem sozinhos assim que o computador ligar:

### Método 1: Pela Interface do Painel Administrativo
1. Abra o aplicativo `be_easy_app.exe`.
2. Acesse as **Configurações Administrativas** (ícone de engrenagem / senha padrão: `BeEasy@2026`).
3. Na seção **Inicialização do Sistema (Modo Totem)**, ative a chave **"Iniciar automaticamente com o Windows"**.
4. Pronto! O software registra o caminho do executável no Registro do Windows (`HKCU\Software\Microsoft\Windows\CurrentVersion\Run`).

### Método 2: Pelo Script de Instalação
Na pasta `dist_windows`, clique duas vezes em:
```cmd
instalar_inicializacao.bat
```

Para desativar a qualquer momento:
```cmd
remover_inicializacao.bat
```

---

## 🌐 Tratamento Inteligente de IP Dinâmico

Em redes residenciais e de condomínios, o roteador frequentemente atribui endereços IP dinâmicos via DHCP. O sistema possui inteligência nativa para lidar com isso:

1. **Filtro de Adaptadores Virtuais do Windows**:
   O Windows frequentemente cria placas de rede virtuais (como WSL, Hyper-V, VirtualBox, Docker, Bluetooth). O algoritmo do `NetworkHelper` descarta essas interfaces e seleciona automaticamente a placa física real de **Wi-Fi** ou **Ethernet** da loja.

2. **Tolerância a Atraso no Boot (Startup Latency)**:
   Quando o Windows inicia, o DHCP pode levar de 5 a 15 segundos para obter o endereço IP. O aplicativo realiza polling periódico nos primeiros segundos de inicialização até obter o IP real da rede, evitando que o totem mostre `127.0.0.1` ou `169.254.*`.

3. **Monitoramento Contínuo em Tempo Real (Heartbeat)**:
   A cada 20 segundos, o aplicativo verifica se houve mudança no endereço IP da máquina. Se o roteador atribuir um novo IP (ex: `192.168.1.45` para `192.168.1.80`), **o QR Code e os links na tela do totem são atualizados automaticamente** sem necessidade de reiniciar o sistema.

4. **Modo Manual Opcional**:
   Caso o estabelecimento utilize um roteador com reserva de IP fixo ou hostname estático (ex: `totem.local`), o administrador pode definir o modo como **IP Manual / Fixo** no painel administrativo.
