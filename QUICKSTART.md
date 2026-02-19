# Quick Start Guide

## 1. Voraussetzungen installieren

**Vor dem Setup-Script manuell installieren:**

| Was | Woher |
|-----|-------|
| **Xcode** (vollständig, nicht nur CommandLineTools) | [Mac App Store](https://apps.apple.com/app/xcode/id497799835) |
| **Docker Desktop** | [docker.com](https://www.docker.com/products/docker-desktop) |

Xcode mindestens einmal öffnen, damit die Installation abgeschlossen wird.

**Homebrew** wird ebenfalls benötigt (falls noch nicht vorhanden):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Alles andere (Qt, cmake, ninja, libpq, Emscripten, QPSQL-Treiber) erledigt `setup-mac.sh` automatisch.

## 2. Projekt Setup

```bash
cd qt-webapp-template
chmod +x scripts/*.sh
./scripts/setup-mac.sh
```

Das Script baut Qt für WASM aus Source, kompiliert Backend + Frontend, und richtet alles ein.

## 3. Starten

```bash
./scripts/start.sh
```

Das Script:
- Erzeugt Self-Signed TLS-Zertifikat (beim ersten Mal)
- Startet PostgreSQL + NGINX (Docker)
- Startet Backend auf Port 3000

## 4. Browser öffnen

```
https://localhost:8443
```

Zertifikatswarnung akzeptieren → Login-Dialog erscheint.

**Default-Credentials:** `admin` / `admin123`

## 5. Stoppen

```bash
./scripts/stop.sh
```

## Nach Code-Änderungen

```bash
./scripts/rebuild.sh
./scripts/stop.sh && ./scripts/start.sh
```

## Troubleshooting

**`fatal error: 'type_traits' file not found`**
`xcode-select` zeigt auf CommandLineTools statt Xcode.app — `setup-mac.sh` korrigiert das automatisch. Manuell:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

**`ld: library 'pq' not found`**
libpq fehlt oder wurde nicht gefunden:
```bash
brew install libpq
```
`backend.pro` erkennt den Pfad automatisch via `brew --prefix libpq`.

**"Qt not found"**
```bash
export PATH="/opt/homebrew/opt/qt@6/bin:$PATH"
```

**"Docker not running"** → Docker Desktop öffnen und starten

**"emcc not found"**
```bash
source ~/emsdk/emsdk_env.sh
```

**Xcode Lizenz-Fehler beim Build**
```bash
sudo xcodebuild -license accept
```

**Zertifikatswarnung im Browser** → "Advanced" → "Proceed to localhost" (normal bei Self-Signed)

**Port belegt**
```bash
./scripts/stop.sh   # Alles stoppen
./scripts/start.sh  # Neu starten
```

## URLs

| URL | Beschreibung |
|-----|-------------|
| `https://localhost:8443` | Frontend (HTTPS) |
| `http://localhost:8080` | Redirect auf HTTPS |
| `https://localhost:8443/api/login` | Login-API |
| `https://localhost:8443/health` | Health Check |

## Nächste Schritte

- **Oracle Migration**: Siehe `MIGRATION.md`
- **NGINX-Auth (LDAP/Kerberos)**: Configs in `nginx/`
- **Production Credentials**: Env-Variablen `API_USER`, `API_PASSWORD`, `API_SECRET` setzen
- **QML Referenz**: Siehe `QML-GUIDE.md`
