#!/bin/bash

# Qt WebApp - Stop Script
# Stoppt alle Services: Backend und Docker Container

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo "=== Qt WebApp stoppen ==="
echo ""

# 1) Backend stoppen
PID_FILE="$PROJECT_DIR/.backend.pid"
STOPPED=false

if [ -f "$PID_FILE" ]; then
    BACKEND_PID=$(cat "$PID_FILE")
    if kill -0 "$BACKEND_PID" 2>/dev/null; then
        info "Stoppe Backend (PID $BACKEND_PID)..."
        kill "$BACKEND_PID" 2>/dev/null
        STOPPED=true
    fi
    rm -f "$PID_FILE"
fi

# Fallback: Prüfe ob noch was auf Port 3000 läuft
PORT_PID=$(lsof -ti :3000 2>/dev/null || true)
if [ -n "$PORT_PID" ]; then
    info "Stoppe Prozess auf Port 3000 (PID $PORT_PID)..."
    kill "$PORT_PID" 2>/dev/null || true
    STOPPED=true
fi

if [ "$STOPPED" = true ]; then
    info "Backend gestoppt ✓"
else
    warn "Kein laufendes Backend gefunden"
fi

# 2) Docker Container stoppen
info "Stoppe Docker Container..."
cd "$PROJECT_DIR"
docker compose down

info "Docker Container gestoppt ✓"

echo ""
echo "========================================="
echo -e "${GREEN}  Alles gestoppt.${NC}"
echo "========================================="
echo ""
