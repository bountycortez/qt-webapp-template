#!/bin/bash

# Qt WebApp - Mac ARM Setup Script
# Automatisiert Installation und Start auf Mac (Apple Silicon)
# Baut Qt für WebAssembly automatisch aus Source wenn nötig.

set -e  # Bei Fehler abbrechen

# Projektverzeichnis merken
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Qt WebApp Setup für Mac ARM ==="
echo ""

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Hilfsfunktionen
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

function step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

function check_command() {
    if command -v $1 &> /dev/null; then
        info "$1 ist installiert ✓"
        return 0
    else
        warn "$1 ist NICHT installiert"
        return 1
    fi
}

echo "Schritt 1: Voraussetzungen prüfen"
echo "=================================="

# Homebrew
if ! check_command brew; then
    error "Homebrew fehlt! Installiere mit: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
fi

# Docker
if ! check_command docker; then
    error "Docker Desktop fehlt! Download: https://www.docker.com/products/docker-desktop"
fi

# Qt6 (nativ, für Backend)
if ! check_command qmake6; then
    warn "Qt6 wird installiert..."
    brew install qt@6
    brew link qt@6 --force
fi

# cmake + ninja (für Qt Source Build)
if ! check_command cmake; then
    warn "cmake wird installiert..."
    brew install cmake
fi

if ! check_command ninja; then
    warn "ninja wird installiert..."
    brew install ninja
fi

# libpq (PostgreSQL Client-Library, für QPSQL-Plugin)
if ! brew list libpq &> /dev/null; then
    warn "libpq wird installiert..."
    brew install libpq
fi

info "Alle Voraussetzungen erfüllt!"
echo ""

echo "Schritt 2: Qt Umgebung konfigurieren"
echo "====================================="

# Qt6 Pfade setzen (für Backend - native Kompilierung)
export PATH="/opt/homebrew/opt/qt@6/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/qt@6/lib"
export CPPFLAGS="-I/opt/homebrew/opt/qt@6/include"

QT_VERSION=$(qmake6 -query QT_VERSION)
QT_HOST_PREFIX=$(qmake6 -query QT_HOST_PREFIX)
info "Qt Version (nativ): $QT_VERSION"

# -------------------------------------------------------
# Qt WASM Build aus Source
# Homebrew Qt enthält keine WebAssembly-Binaries.
# Wir bauen qtbase + qtdeclarative für WASM aus Source.
# -------------------------------------------------------
QT_WASM_DIR="$HOME/Qt-wasm"
QT_WASM_PREFIX="$QT_WASM_DIR/$QT_VERSION/wasm_multithread"
WASM_QMAKE="$QT_WASM_PREFIX/bin/qmake6"
QT_SRC_DIR="$HOME/Qt-src"

# Prüfe ob WASM Build bereits existiert
if [ -x "$WASM_QMAKE" ]; then
    info "Qt WASM Build bereits vorhanden ✓"
else
    echo ""
    echo "=============================================="
    echo "  Qt für WebAssembly wird aus Source gebaut"
    echo "  (einmalig, dauert ca. 20-40 Minuten)"
    echo "=============================================="
    echo ""

    # --- Emscripten zuerst installieren (Qt braucht es zum Bauen) ---

    # Ermittle benötigte Emscripten-Version aus Qt Source oder mkspecs
    # Nutze die empfohlene Version aus dem nativen Qt mkspec
    REQUIRED_EM_VERSION=""

    # Methode 1: Aus den WASM-Konfigurationsdateien
    QT_MKSPEC_DIR=$(qmake6 -query QT_HOST_DATA)/mkspecs/wasm-emscripten
    if [ -d "$QT_MKSPEC_DIR" ]; then
        REQUIRED_EM_VERSION=$(grep -rh "QT_EMSCRIPTEN_RECOMMENDED_VERSION" "$QT_MKSPEC_DIR" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
    fi

    # Methode 2: Testbuild-Fehlermeldung parsen
    if [ -z "$REQUIRED_EM_VERSION" ]; then
        TMPDIR_EM=$(mktemp -d)
        EM_ERROR=$(cd "$TMPDIR_EM" && echo "TEMPLATE=app" > test.pro && qmake6 -spec wasm-emscripten test.pro 2>&1 || true)
        REQUIRED_EM_VERSION=$(echo "$EM_ERROR" | tr -d '*' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
        rm -rf "$TMPDIR_EM"
    fi

    # Methode 3: Fallback
    if [ -z "$REQUIRED_EM_VERSION" ] || ! echo "$REQUIRED_EM_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        REQUIRED_EM_VERSION="4.0.7"
        warn "Emscripten-Version nicht ermittelbar, verwende Fallback $REQUIRED_EM_VERSION"
    fi

    info "Benötigte Emscripten-Version: $REQUIRED_EM_VERSION"

    # Emscripten via emsdk installieren
    EMSDK_DIR="$HOME/emsdk"
    NEED_EMSDK_INSTALL=true

    if [ -f "$EMSDK_DIR/emsdk_env.sh" ]; then
        source "$EMSDK_DIR/emsdk_env.sh" &> /dev/null || true
        CURRENT_EM_VERSION=$(emcc --version 2>/dev/null | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "")
        if [ "$CURRENT_EM_VERSION" = "$REQUIRED_EM_VERSION" ]; then
            info "Emscripten $REQUIRED_EM_VERSION bereits installiert ✓"
            NEED_EMSDK_INSTALL=false
        else
            warn "Emscripten $CURRENT_EM_VERSION vorhanden, benötigt $REQUIRED_EM_VERSION"
        fi
    fi

    if [ "$NEED_EMSDK_INSTALL" = true ]; then
        step "Installiere Emscripten $REQUIRED_EM_VERSION..."
        brew unlink emscripten &> /dev/null || true

        if [ ! -d "$EMSDK_DIR" ]; then
            git clone https://github.com/emscripten-core/emsdk.git "$EMSDK_DIR"
        fi

        cd "$EMSDK_DIR"
        git pull &> /dev/null || true
        ./emsdk install "$REQUIRED_EM_VERSION"
        ./emsdk activate "$REQUIRED_EM_VERSION"
        source ./emsdk_env.sh
        cd "$PROJECT_DIR"

        info "Emscripten $REQUIRED_EM_VERSION installiert ✓"
    fi

    # --- Qt Source herunterladen ---
    mkdir -p "$QT_SRC_DIR"

    # qtbase
    QTBASE_SRC="$QT_SRC_DIR/qtbase-$QT_VERSION"
    if [ ! -d "$QTBASE_SRC" ]; then
        step "Lade qtbase $QT_VERSION Source herunter..."
        cd "$QT_SRC_DIR"
        QT_MAJOR_MINOR=$(echo "$QT_VERSION" | grep -oE '^[0-9]+\.[0-9]+')

        # Versuche offizielles Qt Archive
        QTBASE_URL="https://download.qt.io/official_releases/qt/$QT_MAJOR_MINOR/$QT_VERSION/submodules/qtbase-everywhere-src-$QT_VERSION.tar.xz"
        QTBASE_ARCHIVE="qtbase-$QT_VERSION.tar.xz"

        if ! curl -fSL -o "$QTBASE_ARCHIVE" "$QTBASE_URL" 2>/dev/null; then
            # Fallback: Entwicklungs-Snapshots
            QTBASE_URL="https://download.qt.io/development_releases/qt/$QT_MAJOR_MINOR/$QT_VERSION/submodules/qtbase-everywhere-src-$QT_VERSION.tar.xz"
            if ! curl -fSL -o "$QTBASE_ARCHIVE" "$QTBASE_URL" 2>/dev/null; then
                # Fallback: Git
                warn "Download fehlgeschlagen, klone aus Git..."
                git clone --depth 1 --branch "v$QT_VERSION" https://code.qt.io/qt/qtbase.git "$QTBASE_SRC" || \
                git clone --depth 1 --branch "$QT_VERSION" https://code.qt.io/qt/qtbase.git "$QTBASE_SRC"
            fi
        fi

        if [ -f "$QTBASE_ARCHIVE" ]; then
            step "Entpacke qtbase..."
            tar xf "$QTBASE_ARCHIVE"
            # Qt benennt den Ordner meist qtbase-everywhere-src-X.Y.Z
            EXTRACTED=$(find . -maxdepth 1 -type d -name "qtbase-everywhere*" | head -n 1)
            if [ -n "$EXTRACTED" ] && [ "$EXTRACTED" != "$QTBASE_SRC" ]; then
                mv "$EXTRACTED" "$QTBASE_SRC"
            fi
            rm -f "$QTBASE_ARCHIVE"
        fi

        cd "$PROJECT_DIR"
    fi

    if [ ! -d "$QTBASE_SRC" ]; then
        error "qtbase Source nicht gefunden unter $QTBASE_SRC"
    fi
    info "qtbase Source bereit ✓"

    # qtdeclarative (für QML)
    QTDECL_SRC="$QT_SRC_DIR/qtdeclarative-$QT_VERSION"
    if [ ! -d "$QTDECL_SRC" ]; then
        step "Lade qtdeclarative $QT_VERSION Source herunter..."
        cd "$QT_SRC_DIR"
        QT_MAJOR_MINOR=$(echo "$QT_VERSION" | grep -oE '^[0-9]+\.[0-9]+')

        QTDECL_URL="https://download.qt.io/official_releases/qt/$QT_MAJOR_MINOR/$QT_VERSION/submodules/qtdeclarative-everywhere-src-$QT_VERSION.tar.xz"
        QTDECL_ARCHIVE="qtdeclarative-$QT_VERSION.tar.xz"

        if ! curl -fSL -o "$QTDECL_ARCHIVE" "$QTDECL_URL" 2>/dev/null; then
            QTDECL_URL="https://download.qt.io/development_releases/qt/$QT_MAJOR_MINOR/$QT_VERSION/submodules/qtdeclarative-everywhere-src-$QT_VERSION.tar.xz"
            if ! curl -fSL -o "$QTDECL_ARCHIVE" "$QTDECL_URL" 2>/dev/null; then
                warn "Download fehlgeschlagen, klone aus Git..."
                git clone --depth 1 --branch "v$QT_VERSION" https://code.qt.io/qt/qtdeclarative.git "$QTDECL_SRC" || \
                git clone --depth 1 --branch "$QT_VERSION" https://code.qt.io/qt/qtdeclarative.git "$QTDECL_SRC"
            fi
        fi

        if [ -f "$QTDECL_ARCHIVE" ]; then
            step "Entpacke qtdeclarative..."
            tar xf "$QTDECL_ARCHIVE"
            EXTRACTED=$(find . -maxdepth 1 -type d -name "qtdeclarative-everywhere*" | head -n 1)
            if [ -n "$EXTRACTED" ] && [ "$EXTRACTED" != "$QTDECL_SRC" ]; then
                mv "$EXTRACTED" "$QTDECL_SRC"
            fi
            rm -f "$QTDECL_ARCHIVE"
        fi

        cd "$PROJECT_DIR"
    fi

    if [ ! -d "$QTDECL_SRC" ]; then
        error "qtdeclarative Source nicht gefunden unter $QTDECL_SRC"
    fi
    info "qtdeclarative Source bereit ✓"

    # --- qtbase für WASM bauen ---
    QTBASE_BUILD="$QT_SRC_DIR/build-qtbase-wasm"
    if [ ! -f "$QT_WASM_PREFIX/bin/qmake6" ]; then
        step "Konfiguriere qtbase für WebAssembly..."
        rm -rf "$QTBASE_BUILD"
        mkdir -p "$QTBASE_BUILD"
        cd "$QTBASE_BUILD"

        "$QTBASE_SRC/configure" \
            -platform wasm-emscripten \
            -prefix "$QT_WASM_PREFIX" \
            -qt-host-path "$QT_HOST_PREFIX" \
            -feature-thread \
            -release \
            -nomake tests \
            -nomake examples \
            -- -DQT_BUILD_TESTS=OFF -DQT_BUILD_EXAMPLES=OFF

        step "Baue qtbase für WASM (das dauert eine Weile)..."
        cmake --build . --parallel $(sysctl -n hw.ncpu)

        step "Installiere qtbase WASM..."
        cmake --install .

        cd "$PROJECT_DIR"
        info "qtbase WASM Build erfolgreich ✓"
    else
        info "qtbase WASM bereits gebaut ✓"
    fi

    # --- qtdeclarative für WASM bauen ---
    QTDECL_BUILD="$QT_SRC_DIR/build-qtdeclarative-wasm"
    if [ ! -d "$QT_WASM_PREFIX/qml" ]; then
        step "Konfiguriere qtdeclarative für WebAssembly..."
        rm -rf "$QTDECL_BUILD"
        mkdir -p "$QTDECL_BUILD"
        cd "$QTDECL_BUILD"

        "$QT_WASM_PREFIX/bin/qt-configure-module" "$QTDECL_SRC"

        step "Baue qtdeclarative für WASM (das dauert eine Weile)..."
        cmake --build . --parallel $(sysctl -n hw.ncpu)

        step "Installiere qtdeclarative WASM..."
        cmake --install .

        cd "$PROJECT_DIR"
        info "qtdeclarative WASM Build erfolgreich ✓"
    else
        info "qtdeclarative WASM bereits gebaut ✓"
    fi

    # Verifiziere WASM qmake
    if [ ! -x "$WASM_QMAKE" ]; then
        error "WASM qmake nicht gefunden nach Build: $WASM_QMAKE"
    fi

    echo ""
    echo "=============================================="
    echo "  Qt WASM Build erfolgreich abgeschlossen!"
    echo "=============================================="
    echo ""
fi

# Emscripten aktivieren (falls noch nicht im PATH)
EMSDK_DIR="$HOME/emsdk"
if [ -f "$EMSDK_DIR/emsdk_env.sh" ]; then
    source "$EMSDK_DIR/emsdk_env.sh" &> /dev/null || true
fi

info "Qt Version (nativ): $(qmake6 --version | grep 'Using Qt version')"
info "Qt WASM qmake: $WASM_QMAKE"
if command -v emcc &> /dev/null; then
    info "Emscripten Version: $(emcc --version | head -n 1)"
fi
echo ""

echo "Schritt 3: Docker Container starten"
echo "===================================="

# Prüfe ob Docker läuft
if ! docker info &> /dev/null; then
    error "Docker läuft nicht! Bitte Docker Desktop starten."
fi

# Container starten
info "Starte PostgreSQL + NGINX..."
docker compose up -d

# Warte auf PostgreSQL
info "Warte auf Datenbank..."
sleep 5

# Prüfe PostgreSQL
if docker exec webapp-postgres pg_isready -U webapp_user &> /dev/null; then
    info "PostgreSQL ist bereit ✓"
else
    warn "PostgreSQL antwortet nicht - versuche weiter..."
    sleep 5
fi

echo ""

echo "Schritt 4: QPSQL-Treiber prüfen"
echo "================================="

# Prüfe ob QPSQL-Plugin vorhanden ist
QPSQL_PLUGIN=$(find /opt/homebrew/opt/qt@6 -name "libqsqlpsql*" -o -name "qsqlpsql*" 2>/dev/null | head -n 1)
if [ -n "$QPSQL_PLUGIN" ]; then
    info "QPSQL-Treiber bereits vorhanden ✓"
else
    info "QPSQL-Treiber fehlt - wird aus Qt Source gebaut..."

    SQLDRIVERS_BUILD="$QT_SRC_DIR/build-sqldrivers"
    rm -rf "$SQLDRIVERS_BUILD"
    mkdir -p "$SQLDRIVERS_BUILD"
    cd "$SQLDRIVERS_BUILD"

    /opt/homebrew/bin/qt-cmake "$QT_SRC_DIR/qtbase-$QT_VERSION/src/plugins/sqldrivers" \
        -G Ninja \
        -DPostgreSQL_ROOT=/opt/homebrew/opt/libpq \
        -DCMAKE_INSTALL_PREFIX=/opt/homebrew/opt/qt@6

    cmake --build .
    cmake --install .

    cd "$PROJECT_DIR"
    info "QPSQL-Treiber installiert ✓"
fi

echo ""

echo "Schritt 5: Backend kompilieren"
echo "==============================="

cd "$PROJECT_DIR/backend"

# Clean build
if [ -f "Makefile" ]; then
    info "Bereinige alte Builds..."
    make clean &> /dev/null || true
fi

info "Führe qmake aus..."
qmake6 backend.pro

info "Kompiliere Backend..."
make -j$(sysctl -n hw.ncpu)

if [ -f "backend" ]; then
    info "Backend erfolgreich kompiliert ✓"
else
    error "Backend Kompilierung fehlgeschlagen!"
fi

cd "$PROJECT_DIR"
echo ""

echo "Schritt 6: Frontend kompilieren (WebAssembly)"
echo "==============================================="

# Emscripten sicherstellen (muss im PATH sein für WASM-Build)
if ! command -v emcc &> /dev/null; then
    if [ -f "$HOME/emsdk/emsdk_env.sh" ]; then
        source "$HOME/emsdk/emsdk_env.sh" &> /dev/null || true
    fi
fi
if ! command -v emcc &> /dev/null; then
    error "Emscripten (emcc) nicht im PATH! Bitte 'source ~/emsdk/emsdk_env.sh' ausführen."
fi

cd "$PROJECT_DIR/frontend"

# Übersetzungen kompilieren (.ts → .qm)
step "Kompiliere Übersetzungsdateien..."
if command -v lrelease6 &> /dev/null; then
    LRELEASE_CMD="lrelease6"
elif command -v lrelease &> /dev/null; then
    LRELEASE_CMD="lrelease"
elif [ -x "/opt/homebrew/opt/qt@6/bin/lrelease" ]; then
    LRELEASE_CMD="/opt/homebrew/opt/qt@6/bin/lrelease"
else
    warn "lrelease nicht gefunden - Übersetzungen werden übersprungen"
    LRELEASE_CMD=""
fi

if [ -n "$LRELEASE_CMD" ]; then
    for ts_file in translations/*.ts; do
        if [ -f "$ts_file" ]; then
            "$LRELEASE_CMD" "$ts_file"
            info "Übersetzung kompiliert: $ts_file"
        fi
    done
fi

# Clean build
if [ -f "Makefile" ]; then
    info "Bereinige alte Builds..."
    make clean &> /dev/null || true
fi

info "WebAssembly Build wird vorbereitet..."

# WASM qmake verwenden (nicht das native Homebrew qmake!)
"$WASM_QMAKE" frontend.pro

info "Kompiliere Frontend (kann einige Minuten dauern)..."
make -j$(sysctl -n hw.ncpu)

# Prüfe Output
if [ -f "frontend.html" ]; then
    info "Frontend erfolgreich kompiliert ✓"
    info "WASM-Files liegen in ./frontend/ und sind via Docker-Volume direkt in NGINX verfügbar"
else
    error "Frontend Kompilierung fehlgeschlagen!"
fi

cd "$PROJECT_DIR"
echo ""

echo "Schritt 7: Datenbank prüfen"
echo "============================"

# Prüfe ob Daten vorhanden
GREETING_COUNT=$(docker exec webapp-postgres psql -U webapp_user -d webapp -t -c "SELECT COUNT(*) FROM greetings;" 2>/dev/null | tr -d ' ')

if [ "$GREETING_COUNT" -gt 0 ] 2>/dev/null; then
    info "Datenbank enthält $GREETING_COUNT Greetings ✓"
else
    warn "Datenbank ist leer - initialisiere..."
    docker exec webapp-postgres psql -U webapp_user -d webapp -f /docker-entrypoint-initdb.d/init.sql
fi

echo ""

echo "========================================="
echo "Setup erfolgreich abgeschlossen!"
echo "========================================="
echo ""
info "Backend starten mit:"
echo "  cd backend && ./backend"
echo ""
info "Frontend im Browser öffnen:"
echo "  http://localhost:8080"
echo ""
info "Verfügbare Endpoints:"
echo "  GET  http://localhost:8080/api/greeting"
echo "  POST http://localhost:8080/api/shutdown"
echo ""
info "Docker Container stoppen:"
echo "  docker compose down"
echo ""
info "Logs anzeigen:"
echo "  docker logs -f webapp-postgres"
echo "  docker logs -f webapp-nginx"
echo ""

# Optional: Backend direkt starten
read -p "Backend jetzt starten? (j/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Jj]$ ]]; then
    info "Starte Backend..."
    cd "$PROJECT_DIR/backend"
    ./backend
fi
