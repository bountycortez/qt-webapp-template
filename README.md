# Qt WebApp Template

Template für eine Qt6 WebAssembly Applikation mit Backend, Datenbank, JWT-Authentifizierung und HTTPS.

## Überblick

- **Frontend**: QML + WebAssembly (läuft im Browser)
- **Backend**: Qt6 C++ mit QtHttpServer + QtSQL + JWT-Auth
- **Datenbank**: PostgreSQL (Development) / Oracle (Production)
- **Webserver**: NGINX mit HTTPS (Self-Signed) und Reverse Proxy
- **i18n**: Deutsch (Default) + Englisch
- **Development**: Mac ARM (Apple Silicon)
- **Production**: Linux x86_64

## Architektur

```
Browser (WASM)  →  NGINX (HTTPS:8443)  →  Backend (HTTP:3000)  →  PostgreSQL (5432)
                   TLS-Terminierung         JWT-Auth + REST API      Datenbank
```

## Voraussetzungen (Mac ARM)

### 1. Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Qt6 + Build-Tools
```bash
brew install qt@6 cmake ninja
brew link qt@6
```

### 3. Emscripten SDK
```bash
cd ~
git clone https://github.com/nicholasgasior/emsdk.git
cd emsdk
./emsdk install 4.0.7
./emsdk activate 4.0.7
```

### 4. Docker Desktop
Download von https://www.docker.com/products/docker-desktop
(Für PostgreSQL und NGINX)

### 5. Qt für WebAssembly aus Source bauen
Das Setup-Script (`scripts/setup-mac.sh`) erledigt dies automatisch.

## Quick Start

```bash
# 1. Setup (einmalig) — baut Qt WASM, QPSQL Plugin, Backend, Frontend
chmod +x scripts/*.sh
./scripts/setup-mac.sh

# 2. Starten — erzeugt TLS-Zertifikat, startet Docker + Backend
./scripts/start.sh

# 3. Browser öffnen
open https://localhost:8443
# Zertifikatswarnung akzeptieren → Login: admin / admin123
```

## Scripts

| Script | Beschreibung |
|--------|-------------|
| `scripts/setup-mac.sh` | Vollständiges Setup (Qt WASM Build, QPSQL, Backend, Translations, Frontend) |
| `scripts/rebuild.sh` | Quick-Rebuild (Backend + Translations + Frontend WASM) |
| `scripts/start.sh` | SSL-Zertifikat generieren, Docker + Backend starten |
| `scripts/stop.sh` | Backend + Docker stoppen |

## Projekt-Struktur

```
qt-webapp-template/
├── README.md                    # Diese Datei
├── QUICKSTART.md                # Kurzanleitung
├── MIGRATION.md                 # Oracle-Migration für Produktion
├── QML-GUIDE.md                 # QML GUI-Elemente Referenz
├── docker-compose.yml           # PostgreSQL + NGINX Container
├── backend/                     # Qt C++ Backend
│   ├── backend.pro             # qmake Projektdatei
│   ├── main.cpp                # Entry Point
│   ├── server.h/cpp            # HTTP Server + Route-Auth
│   ├── database.h/cpp          # PostgreSQL-Layer
│   └── authmanager.h/cpp       # JWT Token-Auth (HMAC-SHA256)
├── frontend/                    # QML WebAssembly Client
│   ├── frontend.pro            # qmake Projektdatei
│   ├── main.qml                # UI (6 Tabs + Login-Dialog)
│   ├── main.cpp                # WASM Entry Point (Style/Lang URL-Params)
│   ├── stylehelper.h           # Emscripten JS-Interop
│   ├── qtquickcontrols2.conf   # Material/Fusion/Universal Styling
│   ├── qml.qrc                 # Ressourcen inkl. Translations
│   └── translations/
│       └── en.ts               # Englische Übersetzung
├── nginx/
│   ├── nginx.conf              # HTTPS + HTTP→HTTPS Redirect
│   ├── nginx-ldap.conf         # Active Directory LDAPS
│   ├── nginx-kerberos.conf     # Kerberos SSO
│   ├── nginx-m365.conf         # Microsoft 365 OAuth
│   └── ssl/                    # TLS-Zertifikate (auto-generiert)
├── sql/
│   ├── init-postgres.sql       # PostgreSQL Schema
│   └── init-oracle.sql         # Oracle Schema (für Migration)
└── scripts/
    ├── setup-mac.sh            # Automatisches Mac Setup
    ├── rebuild.sh              # Quick-Rebuild
    ├── start.sh                # Start mit SSL
    └── stop.sh                 # Stop
```

## API Endpoints

| Methode | Endpoint | Auth | Beschreibung |
|---------|----------|------|-------------|
| `GET` | `/health` | — | Health Check |
| `POST` | `/api/login` | — | Login (gibt JWT Token zurück) |
| `GET` | `/api/greeting?lang=X` | Bearer | Greeting aus DB |
| `GET` | `/api/styles` | Bearer | Verfügbare GUI-Styles |
| `GET` | `/api/tables` | Bearer | PostgreSQL-Tabellenliste |
| `GET` | `/api/table?name=X` | Bearer | Tabelleninhalt (max 200 Zeilen) |
| `POST` | `/api/shutdown` | Bearer | Server beenden (nur Dev) |
| `GET` | `/api/products` | Bearer | Alle Produkte laden |
| `POST` | `/api/products` | Bearer | Neues Produkt anlegen |
| `PUT` | `/api/products/{id}` | Bearer | Produkt aktualisieren |
| `DELETE` | `/api/products/{id}` | Bearer | Produkt löschen |

### Login-Beispiel
```bash
# Token holen
curl -k -X POST https://localhost:8443/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# API mit Token aufrufen
curl -k https://localhost:8443/api/greeting \
  -H "Authorization: Bearer <token>"
```

## Authentifizierung

### API-Auth (JWT Token)

Das Backend nutzt HMAC-SHA256 signierte Tokens. Konfiguration über Umgebungsvariablen:

| Variable | Default | Beschreibung |
|----------|---------|-------------|
| `API_USER` | `admin` | Login-Benutzername |
| `API_PASSWORD` | `admin123` | Login-Passwort |
| `API_SECRET` | (zufällig) | HMAC Secret Key |

Token-Lebensdauer: 8 Stunden.

### NGINX-Auth (zusätzlich, optional)

Für Firmennetzwerke stehen alternative NGINX-Configs bereit:

- **nginx-ldap.conf**: Active Directory über LDAPS
- **nginx-kerberos.conf**: Kerberos SSO (Windows-Integration)
- **nginx-m365.conf**: Microsoft 365 OAuth2

## Frontend Features

### 6 Tabs

**Tab 1: Basics** — Buttons, CheckBox, RadioButton, Switch, Slider, RangeSlider

**Tab 2: Input** — TextField, TextArea, SpinBox, Integer/Double Input mit Validierung, Dial (0°–360°), Datum/Zeit SpinBoxes, Kalender-Widget

**Tab 3: Selection** — ComboBox (Standard + Editierbar), Tumbler, ListView

**Tab 4: Display** — ProgressBar, BusyIndicator (mit Switch), Labels, Tooltips, TabBar

**Tab 5: Database** — Greeting laden (DE/EN/ES), DB-Browser (Tabellenliste + Daten + Detail-Popup), Server-Kontrolle, API-Info

**Tab 6: Produkte** — Vollständiges CRUD für die `product`-Tabelle: Tabellen-Ansicht mit Klick-Selektion, Doppelklick zum Bearbeiten, Dialoge für Neu/Bearbeiten/Löschen. Felder: Art.-Nr., GTIN, Name, Einheit, EK-/VK-Preis, MwSt.-Code, Kategorie, Lieferant, Beschreibung, Aktiv-Flag. Beim ersten Start werden 5 Lebensmittel-Beispielsätze angelegt (Mineralwasser, Chips, Reis, Schokolade, Brot).

### Weitere Features

- Login-Dialog beim Start (modal)
- Output Console für alle Interaktionen
- Style-Switching (Material, Fusion, Basic, Universal) im Footer
- Sprach-Switching (Deutsch/English) im Footer
- Benutzeranzeige im Footer (grün wenn eingeloggt)
- Custom Shutdown-Dialog mit Ja/Nein Buttons
- Material Design Farbschema (Rot/Rose)

## HTTPS

NGINX nutzt TLS 1.2/1.3 mit Self-Signed Zertifikat. Das Zertifikat wird automatisch beim ersten `start.sh` generiert (365 Tage gültig, localhost + 127.0.0.1).

- `https://localhost:8443` — Frontend + API
- `http://localhost:8080` — Redirect auf HTTPS
- Browser zeigt Zertifikatswarnung → "Advanced" → "Proceed to localhost"

Für Production: Let's Encrypt oder Firmen-Zertifikat einsetzen (siehe `MIGRATION.md`).

## Ports

| Service | Port | Beschreibung |
|---------|------|-------------|
| NGINX HTTPS | 8443 | Frontend + API Reverse Proxy |
| NGINX HTTP | 8080 | Redirect auf HTTPS |
| Backend | 3000 | Qt HttpServer (intern) |
| PostgreSQL | 5432 | Datenbank (intern) |

## Entwicklung

### Rebuild nach Code-Änderungen
```bash
./scripts/rebuild.sh
./scripts/stop.sh && ./scripts/start.sh
```

### Logs
```bash
# Backend (Terminal-Output)
# NGINX
docker logs -f webapp-nginx
# PostgreSQL
docker logs -f webapp-postgres
```

## Production Deployment

Siehe **MIGRATION.md** für Oracle-Migration, Linux Server Setup, SSL-Zertifikate, systemd Services und Monitoring.

## Lizenz

Open Source — frei verwendbar für kommerzielle und private Projekte.
Qt6 unter LGPL v3 (Open Source) oder kommerzieller Lizenz.

## Ressourcen

- Qt Dokumentation: https://doc.qt.io/qt-6/
- NGINX Dokumentation: https://nginx.org/en/docs/
- Qt Quick Controls: https://doc.qt.io/qt-6/qtquickcontrols-index.html
