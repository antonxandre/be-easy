@echo off
chcp 65001 >nul
echo ======================================================================
echo    be EASY Print - Remocao da Inicializacao Automatica no Windows
echo ======================================================================
echo.

echo Removendo entrada do Registro do Windows...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "BeEasyPrint" /f >nul 2>nul

echo.
echo ======================================================================
echo [OK] O be EASY Print nao sera mais inicializado automaticamente no boot.
echo ======================================================================
echo.
pause
