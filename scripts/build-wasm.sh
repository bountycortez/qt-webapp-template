#!/bin/bash

# Qt WebAssembly Build Script
# Kompiliert das QML Frontend für WebAssembly

set -e

echo "=== Qt WebAssembly Build ==="
echo ""

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

function info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

function warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

function error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Prüfe ob wir im frontend Verzeichnis sind
if [ ! -f "frontend.pro" ]; then
    if [ -d "frontend" ]; then
        cd frontend
    else
        error "frontend.pro nicht gefunden! Script aus Projekt-Root oder frontend/ ausführen."
    fi
fi

# Prüfe Voraussetzungen
info "Prüfe Voraussetzungen..."

if ! command -v qmake6 &> /dev/null; then
    error "qmake6 nicht gefunden! Qt6 installieren."
fi

if ! command -v emcc &> /dev/null; then
    error "emcc nicht gefunden! Emscripten installieren und aktivieren."
fi

# Qt Version
QT_VERSION=$(qmake6 --version | grep "Using Qt version" | cut -d' ' -f4)
info "Qt Version: $QT_VERSION"

# Emscripten Version
EMCC_VERSION=$(emcc --version | head -n 1)
info "Emscripten: $EMCC_VERSION"

# Clean vorheriger Build
if [ -f "Makefile" ]; then
    info "Bereinige vorherigen Build..."
    make clean &> /dev/null || true
    rm -f Makefile
fi

# Temporäre Dateien entfernen
rm -f frontend.html frontend.js frontend.wasm qtloader.js 2>/dev/null || true
rm -rf obj moc 2>/dev/null || true

# qmake für WebAssembly
info "Führe qmake für WebAssembly aus..."
qmake6 -spec wasm-emscripten frontend.pro

if [ ! -f "Makefile" ]; then
    error "qmake fehlgeschlagen - kein Makefile generiert!"
fi

# Kompilieren
info "Kompiliere Frontend..."
CPU_COUNT=$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)
info "Nutze $CPU_COUNT Threads"

if make -j$CPU_COUNT; then
    info "Kompilierung erfolgreich ✓"
else
    error "Kompilierung fehlgeschlagen!"
fi

# Prüfe Output-Dateien
echo ""
info "Prüfe generierte Dateien:"

FILES_OK=true

if [ -f "frontend.html" ]; then
    SIZE=$(du -h frontend.html | cut -f1)
    info "✓ frontend.html ($SIZE)"
else
    warn "✗ frontend.html fehlt!"
    FILES_OK=false
fi

if [ -f "frontend.js" ]; then
    SIZE=$(du -h frontend.js | cut -f1)
    info "✓ frontend.js ($SIZE)"
else
    warn "✗ frontend.js fehlt!"
    FILES_OK=false
fi

if [ -f "frontend.wasm" ]; then
    SIZE=$(du -h frontend.wasm | cut -f1)
    info "✓ frontend.wasm ($SIZE)"
else
    warn "✗ frontend.wasm fehlt!"
    FILES_OK=false
fi

if [ -f "qtloader.js" ]; then
    SIZE=$(du -h qtloader.js | cut -f1)
    info "✓ qtloader.js ($SIZE)"
else
    info "  qtloader.js (optional, nicht immer generiert)"
fi

if [ "$FILES_OK" = false ]; then
    error "Nicht alle benötigten Dateien wurden generiert!"
fi

echo ""
info "Build erfolgreich abgeschlossen!"
echo ""

# Optional: In NGINX kopieren
if command -v docker &> /dev/null && docker ps | grep -q webapp-nginx; then
    read -p "Dateien zu NGINX Container kopieren? (j/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]]; then
        info "Kopiere zu NGINX..."
        docker cp frontend.html webapp-nginx:/usr/share/nginx/html/
        docker cp frontend.js webapp-nginx:/usr/share/nginx/html/
        docker cp frontend.wasm webapp-nginx:/usr/share/nginx/html/
        [ -f "qtloader.js" ] && docker cp qtloader.js webapp-nginx:/usr/share/nginx/html/
        info "Dateien kopiert ✓"
        info "Öffne http://localhost:8080 im Browser"
    fi
else
    info "Starte NGINX Container mit: docker-compose up -d"
    info "Dann Dateien kopieren und http://localhost:8080 öffnen"
fi

echo ""
info "Lokales Testen (ohne NGINX):"
echo "  python3 -m http.server 8000"
echo "  Dann http://localhost:8000/frontend.html öffnen"
