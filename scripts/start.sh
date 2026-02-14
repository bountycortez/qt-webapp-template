#!/bin/bash

# Qt WebApp - Start Script
# Startet alle Services: Docker (PostgreSQL + NGINX) und Backend

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo "=== Qt WebApp starten ==="
echo ""

# 1) Docker prüfen
if ! docker info &> /dev/null; then
    error "Docker läuft nicht! Bitte Docker Desktop starten."
fi

# 2) Self-signed Zertifikat erzeugen (falls nicht vorhanden)
SSL_DIR="$PROJECT_DIR/nginx/ssl"
if [ ! -f "$SSL_DIR/server.crt" ] || [ ! -f "$SSL_DIR/server.key" ]; then
    info "Erzeuge Self-Signed TLS-Zertifikat..."
    mkdir -p "$SSL_DIR"
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$SSL_DIR/server.key" \
        -out "$SSL_DIR/server.crt" \
        -subj "/C=AT/ST=Dev/L=Local/O=QtWebApp/CN=localhost" \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" \
        2>/dev/null
    info "TLS-Zertifikat erzeugt (365 Tage gültig) ✓"
else
    info "TLS-Zertifikat vorhanden ✓"
fi

# 3) Alte Backend-Instanz killen (falls vorhanden)
BACKEND_PID=$(lsof -ti :3000 2>/dev/null || true)
if [ -n "$BACKEND_PID" ]; then
    warn "Port 3000 belegt (PID $BACKEND_PID) – beende alten Prozess..."
    kill "$BACKEND_PID" 2>/dev/null || true
    sleep 1
fi

# 4) Docker Container starten
info "Starte Docker Container (PostgreSQL + NGINX)..."
cd "$PROJECT_DIR"
docker compose up -d

# Warte auf PostgreSQL
info "Warte auf Datenbank..."
for i in $(seq 1 15); do
    if docker exec webapp-postgres pg_isready -U webapp_user &> /dev/null; then
        break
    fi
    sleep 1
done

if docker exec webapp-postgres pg_isready -U webapp_user &> /dev/null; then
    info "PostgreSQL bereit ✓"
else
    warn "PostgreSQL antwortet noch nicht – Backend startet trotzdem..."
fi

# NGINX prüfen
if docker ps --format '{{.Names}}' | grep -q webapp-nginx; then
    info "NGINX läuft (HTTPS) ✓"
else
    warn "NGINX Container nicht gestartet"
fi

# 5) Backend starten (im Hintergrund)
BACKEND_BIN="$PROJECT_DIR/backend/backend"
if [ ! -x "$BACKEND_BIN" ]; then
    error "Backend nicht gefunden! Bitte zuerst 'scripts/setup-mac.sh' ausführen."
fi

info "Starte Backend auf Port 3000..."
cd "$PROJECT_DIR/backend"
./backend &
BACKEND_PID=$!

# Kurz warten und prüfen ob es läuft
sleep 2
if kill -0 "$BACKEND_PID" 2>/dev/null; then
    info "Backend gestartet (PID $BACKEND_PID) ✓"
    # PID speichern für stop.sh
    echo "$BACKEND_PID" > "$PROJECT_DIR/.backend.pid"
else
    error "Backend konnte nicht gestartet werden!"
fi

echo ""
echo "========================================="
echo -e "${GREEN}  Alles läuft!${NC}"
echo "========================================="
echo ""
echo "  Frontend:  https://localhost:8443"
echo "  (HTTP→HTTPS Redirect: http://localhost:8080)"
echo ""
echo "  API Login: POST https://localhost:8443/api/login"
echo "  API:       GET  https://localhost:8443/api/greeting"
echo ""
echo "  Stoppen:   ./scripts/stop.sh"
echo ""
echo -e "  ${YELLOW}Hinweis: Browser zeigt Zertifikatswarnung (self-signed)${NC}"
echo -e "  ${YELLOW}→ 'Advanced' → 'Proceed to localhost' klicken${NC}"
echo ""
