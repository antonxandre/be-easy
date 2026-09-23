# be EASY Print 🖨️

Sistema de autoatendimento para impressão de documentos em PDF projetado para micromarkets e mercearias de condomínio (honest market). 

O sistema opera **100% offline (Edge Computing)** na rede local da loja, permitindo que clientes imprimam documentos via **Pendrive** diretamente no totem ou via **Celular (Web App)** conectado ao Wi-Fi local, com pagamento instantâneo via **PIX**.

---

## 🏗️ Arquitetura do Projeto

O projeto é dividido em dois módulos principais Dart / Flutter:

```text
be_easy_print/
├── be_easy_server/    # Backend HTTP Shelf em Dart, Drift (SQLite), Spooler e PIX EMVCo
├── be_easy_app/       # Frontend Flutter (Totem Desktop e Web App Mobile)
├── config.json        # Arquivo de configuração global (PIX, preços e dados da loja)
└── docs/              # Documentações de kickoff, design e protótipos
```

1. **`be_easy_server`**:
   - Servidor HTTP leve em Dart utilizando `shelf`.
   - Banco de dados local tipado com `Drift` (SQLite).
   - Gerador estático de payloads PIX Copia e Cola / QR Code (norma BACEN / EMVCo com CRC16-CCITT).
   - Gerenciador de fila de impressão FIFO assíncrona (com suporte a spooler de sistema e mock para testes).
   - Hospeda e serve os assets do Web App diretamente na rede local.

2. **`be_easy_app`**:
   - **Totem Desktop (macOS / Windows / Linux)**: Interface para o computador da mercearia. Inicializa o servidor Shelf em segundo plano, exibe QR Code de conexão Wi-Fi, aceita arquivos arrastados de pendrive e exibe a tela de pagamento e status da impressão.
   - **Web App Mobile**: Acessado pelos clientes via celular na rede local (`http://<IP_DO_TOTEM>:8080/app`) para envio de arquivos via Wi-Fi e pagamento PIX.

---

## 📋 Pré-requisitos

- **Flutter SDK**: `>= 3.0.0`
- **Dart SDK**: `>= 3.0.0` (incluído no Flutter)
- Para rodar nativamente no Desktop:
  - macOS: Xcode / CocoaPods instalados
  - Windows: Visual Studio com suporte a C++ Desktop
  - Linux: dependências de desenvolvimento do Flutter

---

## ⚙️ Configurações (`config.json`)

Tanto o servidor quanto o app leem as configurações a partir do arquivo `config.json` localizado na raiz ou dentro de cada pacote:

```json
{
  "pixKey": "65717703000180",
  "merchantName": "BE EASY PRINT",
  "merchantCity": "SAO PAULO",
  "unitPrice": 2.0
}
```

- **`pixKey`**: Chave PIX recebedora (CNPJ `65717703000180`, CPF, e-mail, telefone ou EVP).
- **`merchantName`**: Nome do estabelecimento que aparecerá no aplicativo bancário (até 25 caracteres ASCII).
- **`merchantCity`**: Cidade do recebedor (até 15 caracteres ASCII).
- **`unitPrice`**: Preço padrão por página impressa em reais (R$).

---

## 🚀 Como Executar

### Opção 1: Executar o Aplicativo Completo no Totem (Desktop)

Esta é a forma recomendada para operação na mercearia. Ao abrir o aplicativo desktop, ele **automaticamente inicializa o servidor local em background na porta 8080**.

```bash
# 1. Acesse o diretório do app
cd be_easy_app

# 2. Obtenha as dependências
flutter pub get

# 3. Execute na sua plataforma desktop
flutter run -d macos    # No macOS
# ou
flutter run -d windows  # No Windows
# ou
flutter run -d linux    # No Linux
```

---

### Opção 2: Executar Apenas o Servidor Local (`be_easy_server`)

Você pode rodar o servidor isoladamente no terminal (ideal para desenvolvimento, servidores dedicados ou testes):

```bash
# 1. Acesse o diretório do servidor
cd be_easy_server

# 2. Obtenha as dependências
dart pub get

# 3. Inicie o servidor
dart run
# ou
dart run bin/server.dart
```

#### Opções de Linha de Comando (CLI):

```bash
dart run bin/server.dart [opções]

Opções disponíveis:
-p, --port=<porta>           Porta HTTP do servidor (padrão: 8080)
    --unit-price=<valor>     Preço padrão por página em R$ (padrão: 2.0)
    --mock-printer           Usar spooler simulado para testes offline (padrão: ativado)
    --no-mock-printer        Enviar trabalhos reais para o spooler do sistema operacional
    --pix-key=<chave>        Chave PIX da loja (padrão: 65717703000180)
    --merchant-name=<nome>   Nome do recebedor PIX (padrão: BE EASY PRINT)
    --merchant-city=<cidade> Cidade do recebedor PIX (padrão: SAO PAULO)
-h, --help                   Exibe a ajuda e opções
```

Exemplo:
```bash
dart run bin/server.dart --port=8080 --unit-price=2.0 --mock-printer=true
```

Uma vez iniciado, o servidor estará escutando em:
- **API REST**: `http://localhost:8080/api/`
- **Web App de Autoatendimento**: `http://localhost:8080/app` ou `http://localhost:8080/`
- **Banco de Dados SQLite**: Arquivo local persistido em `be_easy_server/data/be_easy_print.sqlite`
- **Arquivos Temporários**: Diretório `be_easy_server/uploads/`

---

### Opção 3: Executar o Web App Mobile no Navegador (Cliente)

Para testar ou debugar a interface mobile do cliente no navegador (Chrome):

```bash
cd be_easy_app
flutter pub get
flutter run -d chrome
```

O navegador abrirá automaticamente em `http://localhost:<porta>/#/app`.

---

## 📦 Compilação do Web App para o Servidor

O `be_easy_server` já possui em `be_easy_server/web` uma versão compilada do aplicativo web. Se você fizer modificações na interface Flutter e desejar atualizar o pacote servido:

```bash
# 1. Compile o web app em modo de produção
cd be_easy_app
flutter build web --release

# 2. O servidor detecta automaticamente o diretório be_easy_app/build/web,
# mas você também pode copiar para be_easy_server/web se preferir:
cp -R build/web/* ../be_easy_server/web/
---

## 🪟 Distribuição e Executável para Windows (Totem + Servidor Embutido)

Para gerar o executável de produção para Windows (`be_easy_app.exe`) com o servidor Shelf e o Web App mobile integrados:

1. No computador Windows (com Visual Studio C++ Desktop e Flutter instalados), execute na raiz do projeto:
   ```cmd
   scripts\build_windows.bat
   ```
   *(ou no PowerShell: `.\scripts\build_windows.ps1`)*

2. O pacote final será montado na pasta `dist_windows/` contendo:
   - `be_easy_app.exe` (Totem com servidor HTTP Shelf em background)
   - Pasta `web/` (Arquivos estáticos do Web App mobile servidos pelo próprio executável)
   - `config.json` (Chave PIX, preços e dados da loja)
   - `instalar_inicializacao.bat` (Ativa inicialização no boot do Windows com 1 clique)
   - `remover_inicializacao.bat` (Desativa inicialização no boot)

Consulte o guia completo em [docs/distribuicao_windows.md](docs/distribuicao_windows.md) para detalhes sobre inicialização automática e tratamento inteligente de IP dinâmico.

---

## 🧪 Testes e Qualidade de Código

### Testes do Servidor (`be_easy_server`):
Valida o gerador PIX EMVCo / CRC16, validação de cabeçalho PDF, e fila de impressão:
```bash
cd be_easy_server
dart test
dart analyze
```

### Testes do Aplicativo (`be_easy_app`):
Valida o fluxo do totem desktop, fluxo mobile e ViewModels:
```bash
cd be_easy_app
flutter test
flutter analyze
```

---

## 📄 Licença

Este projeto é de uso proprietário para a solução **be EASY Print**.
# be-easy
