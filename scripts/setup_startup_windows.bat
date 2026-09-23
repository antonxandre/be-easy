@echo off
chcp 65001 >nul
echo ======================================================================
echo       be EASY Print - Configurador de Inicializacao no Windows
echo ======================================================================
echo.

set SCRIPT_DIR=%~dp0

:: Procura o executavel be_easy_app.exe no diretorio atual ou em dist_windows
if exist "%SCRIPT_DIR%be_easy_app.exe" (
    set TARGET_EXE=%SCRIPT_DIR%be_easy_app.exe
) else if exist "%SCRIPT_DIR%..\dist_windows\be_easy_app.exe" (
    set TARGET_EXE=%SCRIPT_DIR%..\dist_windows\be_easy_app.exe
) else if exist "%SCRIPT_DIR%..\be_easy_app\build\windows\x64\runner\Release\be_easy_app.exe" (
    set TARGET_EXE=%SCRIPT_DIR%..\be_easy_app\build\windows\x64\runner\Release\be_easy_app.exe
) else (
    echo [ERRO] Nao foi possivel encontrar o executavel be_easy_app.exe.
    echo Certifique-se de executar o script de build primeiro (build_windows.bat).
    pause
    exit /b 1
)

for %%I in ("%TARGET_EXE%") do set ABS_TARGET_EXE=%%~fI

echo Registrando no Registro do Windows (HKCU\Software\Microsoft\Windows\CurrentVersion\Run)...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "BeEasyPrint" /t REG_SZ /d "\"%ABS_TARGET_EXE%\"" /f

if %errorlevel% equ 0 (
    echo.
    echo ======================================================================
    echo [SUCESSO] Inicializacao automatica configurada com sucesso!
    echo O be EASY Print sera iniciado automaticamente ao ligar o computador:
    echo "%ABS_TARGET_EXE%"
    echo ======================================================================
) else (
    echo.
    echo [ERRO] Falha ao registrar no Registro do Windows.
)

echo.
pause
