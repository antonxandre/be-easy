# ======================================================================
#           be EASY Print - Compilador de Producao Windows (PowerShell)
# ======================================================================

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "          be EASY Print - Compilador de Producao Windows" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Checa Flutter
Write-Host "[1/4] Verificando ambiente Flutter..." -ForegroundColor Yellow
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    $CommonPaths = @(
        "$env:FLUTTER_ROOT\bin",
        "C:\src\flutter\bin",
        "C:\flutter\bin",
        "$env:USERPROFILE\flutter\bin",
        "$env:LOCALAPPDATA\flutter\bin",
        "$env:USERPROFILE\development\flutter\bin"
    )
    foreach ($path in $CommonPaths) {
        if ($path -and (Test-Path "$path\flutter.bat")) {
            $env:PATH = "$path;$env:PATH"
            break
        }
    }
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[ERRO] Flutter nao encontrado no PATH do sistema." -ForegroundColor Red
    Write-Host "Por favor, instale o Flutter SDK em https://docs.flutter.dev/get-started/install/windows/desktop" -ForegroundColor Red
    Write-Host "e adicione a pasta 'bin' a variavel de ambiente PATH." -ForegroundColor Red
    Exit 1
}
Write-Host "[OK] Flutter detectado com sucesso." -ForegroundColor Green
Write-Host ""

# 2. Compila Web App
Write-Host "[2/4] Compilando Web App Mobile (Flutter Web)..." -ForegroundColor Yellow
Set-Location "$RootDir\be_easy_app"
flutter build web --release
Write-Host "[OK] Web App compilado com sucesso." -ForegroundColor Green
Write-Host ""

# 3. Sincroniza Web App no servidor
Write-Host "[3/4] Sincronizando arquivos Web para o Servidor Local..." -ForegroundColor Yellow
$ServerWebDir = "$RootDir\be_easy_server\web"
if (-not (Test-Path $ServerWebDir)) {
    New-Item -ItemType Directory -Path $ServerWebDir -Force | Out-Null
}
Copy-Item -Path "$RootDir\be_easy_app\build\web\*" -Destination $ServerWebDir -Recurse -Force
Write-Host "[OK] Assets sincronizados em be_easy_server/web." -ForegroundColor Green
Write-Host ""

# 4. Compila Windows App
Write-Host "[4/4] Compilando Aplicativo Desktop Windows (Totem + Servidor Embutido)..." -ForegroundColor Yellow
Set-Location "$RootDir\be_easy_app"
flutter build windows --release
Write-Host "[OK] Aplicativo Windows compilado com sucesso." -ForegroundColor Green
Write-Host ""

# 5. Monta pacote de distribuição
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "               Montando Pacote de Distribuicao" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

$DistDir = "$RootDir\dist_windows"
if (Test-Path $DistDir) {
    Remove-Item -Path $DistDir -Recurse -Force
}
New-Item -ItemType Directory -Path $DistDir -Force | Out-Null

$ReleaseDir = "$RootDir\be_easy_app\build\windows\x64\runner\Release"
if (-not (Test-Path $ReleaseDir)) {
    $ReleaseDir = "$RootDir\be_easy_app\build\windows\runner\Release"
}

Write-Host "Copiando binarios executaveis e bibliotecas..." -ForegroundColor Gray
Copy-Item -Path "$ReleaseDir\*" -Destination $DistDir -Recurse -Force

Write-Host "Copiando Web App para servir aos celulares..." -ForegroundColor Gray
$DistWebDir = "$DistDir\web"
New-Item -ItemType Directory -Path $DistWebDir -Force | Out-Null
Copy-Item -Path "$RootDir\be_easy_app\build\web\*" -Destination $DistWebDir -Recurse -Force

Write-Host "Copiando arquivo de configuracao..." -ForegroundColor Gray
if (Test-Path "$RootDir\config.json") {
    Copy-Item -Path "$RootDir\config.json" -Destination "$DistDir\config.json" -Force
}

Write-Host "Copiando scripts de inicializacao automatica..." -ForegroundColor Gray
Copy-Item -Path "$ScriptDir\setup_startup_windows.bat" -Destination "$DistDir\instalar_inicializacao.bat" -Force
Copy-Item -Path "$ScriptDir\remove_startup_windows.bat" -Destination "$DistDir\remover_inicializacao.bat" -Force

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "[SUCESSO] Pacote Windows gerado com sucesso!" -ForegroundColor Green
Write-Host "Pasta de distribuicao: $DistDir" -ForegroundColor Green
Write-Host ""
Write-Host "Arquivos incluidos:" -ForegroundColor White
Write-Host "  - be_easy_app.exe (Totem + Servidor embutido)" -ForegroundColor White
Write-Host "  - web/ (Web App servido para celulares via Wi-Fi)" -ForegroundColor White
Write-Host "  - config.json (Chave PIX, precos e configuracoes)" -ForegroundColor White
Write-Host "  - instalar_inicializacao.bat (Ativa inicializacao no boot do Windows)" -ForegroundColor White
Write-Host "  - remover_inicializacao.bat (Remove da inicializacao)" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor Green
