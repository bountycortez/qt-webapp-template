# SSL Zertifikate

## Development (Self-Signed)

Das Zertifikat wird automatisch beim ersten `./scripts/start.sh` generiert:

```
nginx/ssl/server.crt   — Zertifikat (365 Tage, localhost + 127.0.0.1)
nginx/ssl/server.key   — Private Key (RSA 2048)
```

Manuell neu generieren:
```bash
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout nginx/ssl/server.key \
  -out nginx/ssl/server.crt \
  -subj "/C=AT/ST=Dev/L=Local/O=QtWebApp/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
```

Browser zeigt Sicherheitswarnung → "Advanced" → "Proceed to localhost".

## Production

Echte Zertifikate verwenden:

### Option 1: Let's Encrypt (kostenlos)
```bash
sudo certbot --nginx -d webapp.firma.local
```

### Option 2: Firmen-Zertifikat
Zertifikat und Key von Ihrer IT-Abteilung hier ablegen:
- `server.crt` — Zertifikat
- `server.key` — Private Key

### Permissions
```bash
chmod 644 server.crt
chmod 600 server.key
```

## Hinweis

Die Dateien `*.crt` und `*.key` sind in `.gitignore` und werden nicht ins Repository committed.
