@echo off
chcp 65001 >nul
echo ======================================================================
echo           be EASY Print - Iniciando Totem Web & Servidor
echo ======================================================================
echo.

set ROOT_DIR=%~dp0..
cd /d "%ROOT_DIR%"

:: 1. Inicia o servidor local Shelf (minimizado em segundo plano)
if exist "%ROOT_DIR%\be_easy_server\server.exe" (
    echo [1/2] Iniciando Servidor be EASY Print (server.exe)...
    start "be EASY Print Server" /min "%ROOT_DIR%\be_easy_server\server.exe"
) else (
    echo [1/2] Iniciando Servidor be EASY Print via Dart...
    cd /d "%ROOT_DIR%\be_easy_server"
    start "be EASY Print Server" /min dart run bin/server.dart
)

echo Aguardando servidor inicializar na porta 8080...
timeout /t 3 /nobreak >nul

:: 2. Abre a interface do Totem no navegador em modo Kiosk / Tela Cheia
echo [2/2] Abrindo Totem no navegador em tela cheia (Modo Kiosk)...

set TOTEM_URL=http://localhost:8080/#/desktop

:: Tenta abrir com Microsoft Edge (padrao em todo Windows 10/11)
where msedge >nul 2>nul
if %errorlevel% equ 0 (
    start msedge --app=%TOTEM_URL% --start-fullscreen
    goto FIM
)

:: Caso contrario, tenta Google Chrome
where chrome >nul 2>nul
if %errorlevel% equ 0 (
    start chrome --app=%TOTEM_URL% --start-fullscreen
    goto FIM
)

:: Se nao estiver no PATH, tenta caminhos padrao do Edge
if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
    start "" "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --app=%TOTEM_URL% --start-fullscreen
    goto FIM
)
if exist "C:\Program Files\Microsoft\Edge\Application\msedge.exe" (
    start "" "C:\Program Files\Microsoft\Edge\Application\msedge.exe" --app=%TOTEM_URL% --start-fullscreen
    goto FIM
)

:: Fallback para navegador padrao do sistema
start %TOTEM_URL%

:FIM
echo.
echo ======================================================================
echo Totem be EASY Print iniciado com sucesso!
echo - Totem da loja: tela cheia no navegador
echo - Clientes mobile: conectam no Wi-Fi e escaneiam o QR Code
echo ======================================================================
