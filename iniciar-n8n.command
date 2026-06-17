#!/bin/bash
# ============================================
#  AndCode — Lanzador de n8n para Mac
#  Doble clic en Finder para ejecutar
# ============================================

clear
echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║        AndCode — n8n Launcher        ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# 1. Cerrar instancia anterior si existe
echo "  🔄 Cerrando instancia anterior..."
PIDS=$(lsof -ti :5678 2>/dev/null)
if [ -n "$PIDS" ]; then
    echo "$PIDS" | xargs kill -9 2>/dev/null
    echo "  ✅ Instancia anterior cerrada."
else
    echo "  ℹ️  No había ninguna instancia activa."
fi

sleep 1

# 2. Abrir el navegador en 6 segundos (en segundo plano)
(sleep 6 && open http://localhost:5678) &

echo ""
echo "  🚀 Iniciando n8n..."
echo "  🌐 El navegador se abrirá en unos segundos..."
echo ""
echo "  ┌─────────────────────────────────────────┐"
echo "  │  Para detener n8n: pulsa  Ctrl + C      │"
echo "  └─────────────────────────────────────────┘"
echo ""

# 3. Arrancar n8n en primer plano (logs visibles aquí)
export N8N_RESTRICT_FILE_ACCESS_TO=""
n8n start
