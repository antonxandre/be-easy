# Design System - be EASY Print

Este documento define as diretrizes visuais e de interface para o software de autoatendimento de impressão da mercearia "be EASY", garantindo consistência entre o Totem (Flutter Desktop) e o Mobile (Flutter Web).

## 🎨 Paleta de Cores

As cores foram extraídas diretamente da logo oficial para manter a identidade da marca.

### Cores Principais da Marca
*   **Primary Tan (Corpo da sacola):** `#BD8561` 
    *   *Uso:* Elementos secundários, bordas de cartões, fundos de destaque suaves.
*   **Brand Brick (Alça do carrinho / Texto EASY):** `#912A18`
    *   *Uso:* Cabeçalhos, títulos principais, ícones de destaque e botões de ação secundária.
*   **Accent Green (Alça da sacola):** `#709A28`
    *   *Uso:* Cor de Sucesso. Botões de ação principal (Avançar, Confirmar, Já Paguei), ícones de confirmação.

### Cores de Superfície e Texto (Neutras)
*   **Background (Fundo da tela):** `#FAFAFA` (Branco levemente off-white para reduzir o cansaço visual em telas grandes).
*   **Surface (Cartões / Cards):** `#FFFFFF` (Branco puro para destacar o QR Code e as áreas de drag & drop).
*   **Text Primary:** `#2C2C2C` (Cinza muito escuro para textos principais, melhor contraste que preto puro).
*   **Text Secondary:** `#666666` (Cinza médio para subtítulos e instruções).

---

## 🔤 Tipografia

Para um sistema de autoatendimento de leitura rápida, recomenda-se uma fonte Sans-Serif moderna, arredondada e legível à distância.
*   **Fonte Principal:** `Nunito`, `Poppins` ou `Quicksand`. (Combinam com o estilo arredondado da fonte "be" da logo).
*   **Pesos:**
    *   Títulos (H1, H2): Bold (700)
    *   Subtítulos e Botões: SemiBold (600)
    *   Corpo de texto e instruções: Regular (400)

---

## 🧱 Componentes de UI (Flutter)

### 1. Botões (ElevatedButton)
Como é um sistema de Kiosk (totem), os botões devem ser grandes e amigáveis ao toque (Touch-friendly).
*   **Primary Button (Avançar / Imprimir):**
    *   Cor de fundo: `Accent Green` (#709A28)
    *   Cor do texto: Branco (#FFFFFF)
    *   Border Radius: `16px` (Bordas bem arredondadas, combinando com a logo).
    *   Padding: Mínimo de `24px` vertical para facilitar o clique.
*   **Secondary Button (Voltar / Cancelar):**
    *   Cor de fundo: Transparente ou Branco
    *   Border: `2px solid #BD8561` (Primary Tan) ou `#912A18` (Brand Brick)
    *   Cor do texto: `#912A18`

### 2. Cartões (Cards / Containers)
Usados para agrupar informações (ex: Área do QR Code, Área do Pendrive).
*   **Fundo:** `#FFFFFF`
*   **Sombra (Elevation):** Sombra suave e difusa (ex: `BoxShadow(color: Colors.black12, blurRadius: 10)`).
*   **Border Radius:** `24px`

### 3. Drag & Drop Area (Pendrive)
*   **Borda:** Tracejada (Dashed border) usando a cor `Primary Tan` (#BD8561).
*   **Fundo:** `#BD8561` com 10% de opacidade.
*   **Ícone Central:** Um ícone de documento ou pendrive grande na cor `Brand Brick` (#912A18).

---

## 📱 Aplicação nas Telas (UI Flow)

1.  **Tela de Boas-Vindas:**
    *   Fundo `#FAFAFA`. Logo centralizada grande.
    *   Botão gigante "Começar" em `Accent Green`.
2.  **Tela de Conexão Wi-Fi:**
    *   Card branco centralizado contendo o Nome e Senha da rede em destaque (fonte grande, `Brand Brick`).
3.  **Tela de Captação (QR Code / Pendrive):**
    *   Split-screen visual (tela dividida em duas colunas).
    *   *Esquerda:* Card com QR Code (preto no branco para leitura impecável). Instruções em `Text Secondary`.
    *   *Direita:* Área de Drag & Drop tracejada.
4.  **Tela Core (Cálculo):**
    *   Resumo do arquivo (Ícone de PDF, Nome, Nº de Páginas).
    *   Valor total em destaque enorme (ex: R$ 5,00) na cor `Accent Green`.
5.  **Tela de Pagamento (PIX):**
    *   Layout limpo. QR Code do PIX no centro.
    *   Mensagem de agradecimento ("A impressora já está trabalhando!").