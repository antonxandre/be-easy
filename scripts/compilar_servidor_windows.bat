@echo off
chcp 65001 >nul
echo ======================================================================
echo    be EASY Print - Compilar Servidor para Windows (Sem Visual Studio)
echo ======================================================================
echo.

set ROOT_DIR=%~dp0..
cd /d "%ROOT_DIR%\be_easy_server"

echo [1/2] Obtendo dependencias do servidor...
call dart pub get

echo.
echo [2/2] Compilando binario server.exe nativo com Dart...
call dart compile exe bin/server.dart -o server.exe

if %errorlevel% equ 0 (
    echo.
    echo ======================================================================
    echo [SUCESSO] Servidor executavel gerado com sucesso!
    echo Arquivo: %ROOT_DIR%\be_easy_server\server.exe
    echo.
    echo Vantagens:
    echo - NAO precisa do Visual Studio instalado
    echo - Binario nativo super leve (~15 MB)
    echo - Pode ser iniciado com o script iniciar_totem_web.bat
    echo ======================================================================
) else (
    echo.
    echo [ERRO] Falha ao compilar com o comando dart compile exe.
)

echo.
pause
