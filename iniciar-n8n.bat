@echo off
chcp 65001 >nul
cls

echo.
echo   ╔══════════════════════════════════════╗
echo   ║        AndCode — n8n Launcher        ║
echo   ╚══════════════════════════════════════╝
echo.

:: 1. Cerrar instancia anterior en el puerto 5678
echo   Cerrando instancia anterior...
set "FOUND="
for /f "tokens=5" %%a in ('netstat -aon 2^>nul ^| findstr ":5678 "') do (
    set "FOUND=1"
    taskkill /f /pid %%a >nul 2>&1
)
if defined FOUND (
    echo   Instancia anterior cerrada.
) else (
    echo   No habia ninguna instancia activa.
)

timeout /t 1 /nobreak >nul

:: 2. Abrir el navegador tras 7 segundos (en segundo plano)
start "" /b cmd /c "timeout /t 7 /nobreak >nul && start http://localhost:5678"

echo.
echo   Iniciando n8n...
echo   El navegador se abrira en unos segundos...
echo.
echo   ┌─────────────────────────────────────────┐
echo   │  Para detener n8n: cierra esta ventana  │
echo   └─────────────────────────────────────────┘
echo.

:: 3. Arrancar n8n en primer plano (logs visibles en esta ventana)
set "N8N_RESTRICT_FILE_ACCESS_TO="
n8n start
