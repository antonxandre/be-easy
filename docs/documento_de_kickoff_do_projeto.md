# Documento de Kickoff: Sistema de Impressão de Autoatendimento (be EASY)

## 1. Visão Geral do Projeto
O projeto consiste em um sistema de autoatendimento para impressão de documentos em formato PDF, voltado para uma mercearia de condomínio (micromarket). O grande diferencial arquitetural é operar **100% offline e sem infraestrutura em nuvem (Edge Computing)**. 

O computador da loja (um notebook) funcionará simultaneamente como:
1. **Interface de Autoatendimento:** Tela interativa operando no notebook para usuários que desejam inserir arquivos fisicamente via pendrive.
2. **Servidor Local (Backend):** Hospedeiro de uma API local na rede Wi-Fi da loja para processar uploads de arquivos vindos dos celulares dos clientes e gerenciar a fila de impressão.

O modelo de negócio baseia-se na confiança (honest market), onde a liberação da impressão ocorre em paralelo com a exibição do código PIX (BR Code / Payload) para pagamento via aplicativo do banco do usuário.

## 2. Arquitetura e Stack Tecnológico
O desenvolvimento deve seguir rigorosamente as melhores práticas do ecossistema Dart/Flutter, priorizando código limpo, testabilidade e separação de responsabilidades.

*   **Frontend (App Desktop e Cliente Web):** Flutter.
*   **Backend (Servidor Local):** Dart puro utilizando o pacote `shelf` para roteamento HTTP e tratamento de requisições `multipart/form-data`.
*   **Persistência de Dados Local:** Drift (SQLite) para manter o histórico de impressões, auditoria de caixa e logs de erros de forma robusta e tipada.
*   **Padrão Arquitetural:** MVVM (Model-View-ViewModel).
*   **Integração de Impressão:** Utilização de pacotes nativos (ex: `printing` ou chamadas de sistema) para enviar os binários do PDF diretamente para o spooler de impressão do sistema operacional.

## 3. Diretrizes de Arquitetura (MVVM)
O agente codificador deve estruturar o projeto separando claramente as camadas:

*   **Models:** Classes de dados puras e entidades do banco de dados (tabelas do Drift). Devem incluir os modelos para o Payload do PIX e itens da fila de impressão.
*   **Repositories:** Camada responsável pela comunicação com o banco de dados Drift e com os serviços de sistema (ex: leitura de diretórios, spooler de impressão).
*   **Services / Use Cases:** Lógica de negócio isolada, incluindo a **Fila de Impressão Assíncrona** (Print Queue) que impede o envio de múltiplos comandos simultâneos para a impressora, e a geração da string do PIX.
*   **ViewModels:** Gerenciamento de estado da UI. Nenhuma regra de negócio pesada ou acesso direto a banco/rede deve estar na View. A comunicação da View com o ViewModel deve ser reativa.
*   **Views:** Widgets Flutter focados exclusivamente na renderização da interface e captura de eventos do usuário, seguindo a paleta de cores definida no `DESIGN.md`.

## 4. Fluxos de Usuário e Funcionalidades Core

### 4.1. Fluxo do Servidor (Background)
*   Inicializar o servidor `shelf` na porta 8080 assim que o aplicativo desktop for aberto no notebook.
*   Escutar requisições de upload na rede local (ex: `/api/upload`).
*   Validar se o arquivo recebido possui a assinatura binária de um PDF (prevenção contra arquivos maliciosos).
*   Calcular o número de páginas utilizando um parser de PDF ou leitura de metadados.
*   Adicionar trabalhos recebidos a uma fila (Queue) FIFO para evitar sobrecarga da impressora física.

### 4.2. Fluxo Desktop (Notebook da Loja)
*   **Tela de Boas-Vindas:** Ponto de entrada amigável exibido na tela do notebook.
*   **Tela de Conexão / Captura:** Exibe as credenciais da rede Wi-Fi local e um QR Code dinâmico contendo o IP da máquina (ex: `http://192.168.1.100:8080/app`) para o usuário acessar via celular. Também oferece a área de Drop para inserção via pendrive diretamente no notebook.
*   **Processamento de Arquivo Local:** Se o arquivo for arrastado do pendrive, o sistema faz o cálculo de páginas e valor.
*   **Tela de Pagamento (PIX):** Exibe o QR Code gerado internamente (Payload do Banco Central) com o valor exato, enquanto aciona o serviço de impressão.

### 4.3. Fluxo Mobile (Web App na Rede Local)
*   Acessado via navegador do celular ao escanear o QR Code exibido na tela do notebook ou de um adesivo físico afixado na loja.
*   Permite o upload seguro do PDF através do `file_picker` e requisição `multipart`.
*   Retorna a quantidade de páginas, o valor total e exibe o QR Code PIX (Copia e Cola) diretamente no celular do cliente.
*   Envia o sinal de confirmação ("Já paguei") para o servidor `shelf` inserir o documento na fila física.

## 5. Requisitos Não Funcionais e Segurança
*   **Isolamento de Rede:** O servidor deve estar preparado para rodar em uma VLAN ou rede Guest isolada. O agente deve prever tratamento de erros de CORS (`shelf_cors_headers`) para a comunicação entre a interface web servida pelo cliente e o backend local.
*   **Tratamento de Exceções:** Implementar blocos `try-catch` robustos nas operações de I/O (leitura de arquivos, comunicação com a porta de impressão).
*   **Logs:** Utilizar o Drift para salvar logs de execução, permitindo rastrear o status de cada trabalho (Recebido, Na Fila, Impresso, Erro) para fins de conferência no final do dia.