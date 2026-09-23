@echo off
chcp 65001 >nul
echo ======================================================================
echo           be EASY Print - Compilador de Producao Windows
echo ======================================================================
echo.

set ROOT_DIR=%~dp0..
cd /d "%ROOT_DIR%"

echo [1/4] Verificando ambiente Flutter...
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    if defined FLUTTER_ROOT (
        if exist "%FLUTTER_ROOT%\bin\flutter.bat" set "PATH=%FLUTTER_ROOT%\bin;%PATH%"
    )
    if exist "C:\src\flutter\bin\flutter.bat" (
        set "PATH=C:\src\flutter\bin;%PATH%"
    ) else if exist "C:\flutter\bin\flutter.bat" (
        set "PATH=C:\flutter\bin;%PATH%"
    ) else if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
        set "PATH=%USERPROFILE%\flutter\bin;%PATH%"
    ) else if exist "%LOCALAPPDATA%\flutter\bin\flutter.bat" (
        set "PATH=%LOCALAPPDATA%\flutter\bin;%PATH%"
    ) else if exist "%USERPROFILE%\development\flutter\bin\flutter.bat" (
        set "PATH=%USERPROFILE%\development\flutter\bin;%PATH%"
    )
)

where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERRO] O comando 'flutter' nao foi encontrado no PATH do sistema.
    echo.
    echo Para resolver:
    echo 1. Baixe o Flutter SDK em: https://docs.flutter.dev/get-started/install/windows/desktop
    echo 2. Extraia (ex: em C:\src\flutter)
    echo 3. Adicione a pasta 'bin' (ex: C:\src\flutter\bin) a variavel de ambiente PATH do Windows.
    echo 4. Feche e reabra esta janela do terminal.
    echo.
    if not "%CI%"=="true" pause
    exit /b 1
)

echo [OK] Flutter detectado com sucesso.
echo.

echo [2/4] Compilando Web App Mobile (Flutter Web)...
cd /d "%ROOT_DIR%\be_easy_app"
call flutter build web --release
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao compilar o Web App.
    if not "%CI%"=="true" pause
    exit /b 1
)

echo [OK] Web App compilado com sucesso.
echo.

echo [3/4] Sincronizando arquivos Web para o Servidor Local...
if not exist "%ROOT_DIR%\be_easy_server\web" mkdir "%ROOT_DIR%\be_easy_server\web"
xcopy /E /Y /I "%ROOT_DIR%\be_easy_app\build\web\*" "%ROOT_DIR%\be_easy_server\web\" >nul
echo [OK] Assets sincronizados em be_easy_server/web.
echo.

echo [4/4] Compilando Aplicativo Desktop Windows (Totem + Servidor Embutido)...
cd /d "%ROOT_DIR%\be_easy_app"
call flutter build windows --release
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao compilar o executavel Windows.
    echo Certifique-se de que o Visual Studio com suporte a C++ Desktop esta instalado.
    if not "%CI%"=="true" pause
    exit /b 1
)

echo.
echo ======================================================================
echo               Montando Pacote de Distribuicao
echo ======================================================================

set DIST_DIR=%ROOT_DIR%\dist_windows
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"
mkdir "%DIST_DIR%"

set RELEASE_DIR=%ROOT_DIR%\be_easy_app\build\windows\x64\runner\Release
if not exist "%RELEASE_DIR%" (
    set RELEASE_DIR=%ROOT_DIR%\be_easy_app\build\windows\runner\Release
)

echo Copiando binarios executaveis e bibliotecas...
xcopy /E /Y /I "%RELEASE_DIR%\*" "%DIST_DIR%\" >nul

echo Copiando biblioteca nativa sqlite3.dll...
if exist "%ROOT_DIR%\sqlite3.dll" (
    copy /Y "%ROOT_DIR%\sqlite3.dll" "%DIST_DIR%\sqlite3.dll" >nul
) else if exist "%ROOT_DIR%\be_easy_server\sqlite3.dll" (
    copy /Y "%ROOT_DIR%\be_easy_server\sqlite3.dll" "%DIST_DIR%\sqlite3.dll" >nul
)

echo Copiando Web App para servir aos celulares...
mkdir "%DIST_DIR%\web"
xcopy /E /Y /I "%ROOT_DIR%\be_easy_app\build\web\*" "%DIST_DIR%\web\" >nul

echo Copiando arquivo de configuracao inicial...
if exist "%ROOT_DIR%\config.json" (
    copy /Y "%ROOT_DIR%\config.json" "%DIST_DIR%\config.json" >nul
)

echo Copiando scripts de inicializacao automatica...
copy /Y "%ROOT_DIR%\scripts\setup_startup_windows.bat" "%DIST_DIR%\instalar_inicializacao.bat" >nul
copy /Y "%ROOT_DIR%\scripts\remove_startup_windows.bat" "%DIST_DIR%\remover_inicializacao.bat" >nul

echo.
echo ======================================================================
echo [SUCESSO] Pacote Windows gerado com sucesso!
echo Pasta de distribuicao: %DIST_DIR%
echo.
echo Arquivos incluidos:
echo  - be_easy_app.exe (Totem + Servidor embutido)
echo  - web/ (Web App servido para celulares via Wi-Fi)
echo  - config.json (Chave PIX, precos e configuracoes)
echo  - instalar_inicializacao.bat (Ativa inicializacao no boot do Windows)
echo  - remover_inicializacao.bat (Remove da inicializacao)
echo ======================================================================
echo.
if not "%CI%"=="true" pause

