#!/bin/bash

# Qt WebApp - Rebuild Script
# Kompiliert Backend + Frontend neu (ohne Setup-Schritte)
# Voraussetzung: setup-mac.sh wurde bereits erfolgreich ausgeführt

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Qt-Version ermitteln
QT_VERSION=$(qmake6 -query QT_VERSION 2>/dev/null || echo "")
if [ -z "$QT_VERSION" ]; then
    error "Qt6 nicht gefunden! Bitte zuerst setup-mac.sh ausführen."
fi

WASM_QMAKE="$HOME/Qt-wasm/$QT_VERSION/wasm_multithread/bin/qmake6"
if [ ! -x "$WASM_QMAKE" ]; then
    error "Qt WASM Build nicht gefunden ($WASM_QMAKE). Bitte zuerst setup-mac.sh ausführen."
fi

echo "=== Qt WebApp Rebuild ==="
echo "  Qt Version: $QT_VERSION"
echo ""

# ---- Backend ----
echo "1) Backend kompilieren"
echo "======================"

cd "$PROJECT_DIR/backend"

if [ -f "Makefile" ]; then
    make clean &> /dev/null || true
fi

qmake6 backend.pro
make -j$(sysctl -n hw.ncpu)

if [ -f "backend" ]; then
    info "Backend OK ✓"
else
    error "Backend Kompilierung fehlgeschlagen!"
fi

# ---- Übersetzungen ----
echo ""
echo "2) Übersetzungen kompilieren"
echo "============================"

cd "$PROJECT_DIR/frontend"

LRELEASE_CMD=""
if command -v lrelease6 &> /dev/null; then
    LRELEASE_CMD="lrelease6"
elif command -v lrelease &> /dev/null; then
    LRELEASE_CMD="lrelease"
elif [ -x "/opt/homebrew/opt/qt@6/bin/lrelease" ]; then
    LRELEASE_CMD="/opt/homebrew/opt/qt@6/bin/lrelease"
fi

if [ -n "$LRELEASE_CMD" ]; then
    for ts_file in translations/*.ts; do
        if [ -f "$ts_file" ]; then
            "$LRELEASE_CMD" "$ts_file"
            info "$(basename "$ts_file") → $(basename "${ts_file%.ts}.qm")"
        fi
    done
else
    warn "lrelease nicht gefunden - Übersetzungen übersprungen"
fi

# ---- Frontend (WASM) ----
echo ""
echo "3) Frontend kompilieren (WebAssembly)"
echo "======================================"

# Emscripten laden
if ! command -v emcc &> /dev/null; then
    if [ -f "$HOME/emsdk/emsdk_env.sh" ]; then
        source "$HOME/emsdk/emsdk_env.sh" &> /dev/null || true
    fi
fi
if ! command -v emcc &> /dev/null; then
    error "Emscripten (emcc) nicht im PATH! Bitte 'source ~/emsdk/emsdk_env.sh'."
fi

if [ -f "Makefile" ]; then
    make clean &> /dev/null || true
fi

"$WASM_QMAKE" frontend.pro
make -j$(sysctl -n hw.ncpu)

if [ -f "frontend.html" ]; then
    info "Frontend OK ✓"
else
    error "Frontend Kompilierung fehlgeschlagen!"
fi

echo ""
echo "========================================="
echo -e "${GREEN}  Rebuild fertig!${NC}"
echo "========================================="
echo ""
echo "  Starten:  ./scripts/start.sh"
echo ""
