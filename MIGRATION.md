# Migration zu Oracle Production Environment

Anleitung zur Migration von PostgreSQL (Development) zu Oracle (Production) auf Linux.

## Überblick

Diese Anleitung zeigt:
1. Oracle-Verbindung in Qt konfigurieren
2. Schema auf Oracle übertragen
3. Linux Server Setup
4. SSL/TLS Konfiguration (HTTPS mit echtem Zertifikat)
5. Produktions-Authentifizierung (JWT + NGINX-Auth)
6. API-Credentials sicher konfigurieren

## Voraussetzungen

### Oracle-Instanz in Ihrer Firmenumgebung

- Oracle Database 11g oder höher (empfohlen: 19c, 21c)
- Netzwerkzugriff vom Applikationsserver
- Datenbank-User mit CREATE TABLE Rechten
- TNS-Namen oder Connection String

### Linux Server

- RHEL/CentOS 8+ oder Ubuntu 20.04+
- Root-Zugriff oder sudo
- Mindestens 2GB RAM, 20GB Disk

## 1. Oracle Instant Client installieren

### RHEL/CentOS
```bash
# Oracle Instant Client Repository
cd /tmp
wget https://download.oracle.com/otn_software/linux/instantclient/219000/oracle-instantclient-basic-21.9.0.0.0-1.el8.x86_64.rpm
wget https://download.oracle.com/otn_software/linux/instantclient/219000/oracle-instantclient-devel-21.9.0.0.0-1.el8.x86_64.rpm
wget https://download.oracle.com/otn_software/linux/instantclient/219000/oracle-instantclient-sqlplus-21.9.0.0.0-1.el8.x86_64.rpm

sudo dnf install -y oracle-instantclient*.rpm

# Umgebungsvariablen setzen
echo 'export LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

### Ubuntu
```bash
# Dependencies
sudo apt-get install -y libaio1 alien

# Instant Client konvertieren und installieren
cd /tmp
wget https://download.oracle.com/otn_software/linux/instantclient/219000/oracle-instantclient-basic-21.9.0.0.0-1.x86_64.rpm
sudo alien -i oracle-instantclient-basic-21.9.0.0.0-1.x86_64.rpm

echo 'export LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

## 2. Qt6 auf Linux installieren

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y qt6-base-dev qt6-declarative-dev libqt6sql6 libqt6sql6-odbc

# RHEL/CentOS
sudo dnf install -y qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtbase-odbc
```

## 3. Oracle Schema erstellen

### Verbindung testen
```bash
sqlplus username/password@//oracle-host:1521/SERVICE_NAME
```

### Schema anlegen
```sql
-- sql/init-oracle.sql ausführen
sqlplus username/password@//oracle-host:1521/SERVICE_NAME @sql/init-oracle.sql
```

Das Script erstellt:
- Tabelle `GREETINGS`
- Initialen Datensatz "Hello World!"

## 4. Backend für Oracle konfigurieren

### backend/database.cpp anpassen

**Von PostgreSQL:**
```cpp
db = QSqlDatabase::addDatabase("QPSQL");
db.setHostName("localhost");
db.setPort(5432);
db.setDatabaseName("webapp");
db.setUserName("webapp_user");
db.setPassword("webapp_pass");
```

**Zu Oracle:**
```cpp
db = QSqlDatabase::addDatabase("QOCI");  // Oracle Call Interface

// Variante 1: TNS-Name
db.setDatabaseName("ORCL");  // TNS-Name aus tnsnames.ora

// Variante 2: Easy Connect String (empfohlen)
db.setDatabaseName("//oracle-host.firma.local:1521/XEPDB1");

// Variante 3: Full Connection Descriptor
db.setDatabaseName("(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-host)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XEPDB1)))");

db.setUserName("webapp_user");
db.setPassword("secure_password");  // Aus Umgebungsvariable oder Vault lesen!
```

### Sichere Passwort-Speicherung

**NICHT hardcoden!** Nutze Umgebungsvariablen:

```cpp
// backend/database.cpp
QString dbPassword = qEnvironmentVariable("DB_PASSWORD");
if (dbPassword.isEmpty()) {
    qCritical() << "DB_PASSWORD nicht gesetzt!";
    return false;
}
db.setPassword(dbPassword);
```

```bash
# /etc/environment oder systemd service
export DB_PASSWORD="secure_oracle_password"
```

## 5. Backend kompilieren (Linux)

```bash
cd backend
qmake6 backend.pro
make -j$(nproc)

# Binary testen
export DB_PASSWORD="your_password"
./backend
```

## 6. Frontend für Production bauen

```bash
cd frontend
qmake6 -spec wasm-emscripten
make -j$(nproc)

# Ausgabe nach NGINX Webroot kopieren
sudo cp -r frontend/* /var/www/webapp/
```

## 7. NGINX Production Setup

### SSL-Zertifikat erstellen/installieren

Im Development wird automatisch ein Self-Signed Zertifikat generiert (`start.sh`).
Für Production ein echtes Zertifikat verwenden:

**Option A: Let's Encrypt (kostenlos)**
```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d webapp.firma.local
```

**Option B: Firmen-Zertifikat**
```bash
# Zertifikat und Key nach /etc/nginx/ssl/ kopieren
sudo mkdir -p /etc/nginx/ssl
sudo cp firma-cert.crt /etc/nginx/ssl/server.crt
sudo cp firma-key.key /etc/nginx/ssl/server.key
sudo chmod 600 /etc/nginx/ssl/server.key
```

Die NGINX-Config (`nginx/nginx.conf`) ist bereits für HTTPS konfiguriert:
- TLS 1.2/1.3, HSTS, X-Content-Type-Options, X-Frame-Options
- HTTP→HTTPS Redirect
- Reverse Proxy zu Backend mit Authorization-Header Forwarding

### NGINX installieren
```bash
# Ubuntu
sudo apt-get install -y nginx

# RHEL
sudo dnf install -y nginx

sudo systemctl enable nginx
sudo systemctl start nginx
```

### Produktions-Config kopieren

**Für Active Directory LDAPS:**
```bash
# NGINX mit LDAP-Modul kompilieren (nicht in Standard-Paketen)
# Siehe: https://github.com/kvspb/nginx-auth-ldap

sudo cp nginx/nginx-ldap.conf /etc/nginx/nginx.conf

# LDAP-Settings anpassen:
sudo nano /etc/nginx/nginx.conf
```

Anpassen:
```nginx
ldap_server firma_ad {
    url ldaps://dc.firma.local:636/DC=firma,DC=local?sAMAccountName?sub?(objectClass=person);
    binddn "CN=nginx_service,OU=ServiceAccounts,DC=firma,DC=local";
    binddn_passwd "SERVICEACCOUNT_PASSWORD";
    require valid_user;
}
```

**Für Kerberos SSO:**
```bash
sudo apt-get install -y libngx-http-auth-spnego-module

sudo cp nginx/nginx-kerberos.conf /etc/nginx/nginx.conf
```

Keytab erstellen:
```bash
# Auf Windows Domain Controller:
ktpass -princ HTTP/webapp.firma.local@FIRMA.LOCAL -mapuser webapp_service@FIRMA.LOCAL \
       -pass * -out webapp.keytab -ptype KRB5_NT_PRINCIPAL

# Auf Linux Server:
sudo mv webapp.keytab /etc/nginx/
sudo chmod 600 /etc/nginx/webapp.keytab
sudo chown www-data:www-data /etc/nginx/webapp.keytab
```

NGINX neu laden:
```bash
sudo nginx -t  # Config testen
sudo systemctl reload nginx
```

## 8. API-Credentials für Production

```bash
# Sichere Credentials setzen (NICHT die Development-Defaults verwenden!)
export API_USER="technischer_api_user"
export API_PASSWORD="$(openssl rand -base64 32)"
export API_SECRET="$(openssl rand -base64 64)"
```

Die JWT-Tokens werden mit HMAC-SHA256 signiert. Token-Lebensdauer: 8 Stunden.
Das Frontend zeigt beim Start einen Login-Dialog.

## 9. Backend als systemd Service

```bash
sudo nano /etc/systemd/system/webapp-backend.service
```

```ini
[Unit]
Description=Qt WebApp Backend
After=network.target oracle.service

[Service]
Type=simple
User=webapp
Group=webapp
WorkingDirectory=/opt/webapp/backend
Environment="DB_PASSWORD=secure_password"
Environment="API_USER=technischer_api_user"
Environment="API_PASSWORD=sicheres_passwort"
Environment="API_SECRET=geheimer_schluessel"
Environment="LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib"
ExecStart=/opt/webapp/backend/backend
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Service aktivieren:
```bash
# User erstellen
sudo useradd -r -s /bin/false webapp

# Backend installieren
sudo mkdir -p /opt/webapp/backend
sudo cp backend/backend /opt/webapp/backend/
sudo chown -R webapp:webapp /opt/webapp

# Service starten
sudo systemctl daemon-reload
sudo systemctl enable webapp-backend
sudo systemctl start webapp-backend
sudo systemctl status webapp-backend
```

## 10. Firewall konfigurieren

```bash
# Ubuntu (ufw)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# RHEL (firewalld)
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

## 11. SQL-Unterschiede PostgreSQL vs Oracle

### Auto-Increment
**PostgreSQL:**
```sql
id SERIAL PRIMARY KEY
```

**Oracle:**
```sql
id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
-- oder mit Sequence (11g):
CREATE SEQUENCE greetings_seq;
id NUMBER DEFAULT greetings_seq.NEXTVAL PRIMARY KEY
```

### String-Concat
**PostgreSQL:**
```sql
SELECT 'Hello' || ' ' || 'World'
```

**Oracle:** (identisch)
```sql
SELECT 'Hello' || ' ' || 'World' FROM DUAL
```

### LIMIT
**PostgreSQL:**
```sql
SELECT * FROM greetings LIMIT 10
```

**Oracle:**
```sql
SELECT * FROM greetings FETCH FIRST 10 ROWS ONLY
-- oder (11g):
SELECT * FROM (SELECT * FROM greetings) WHERE ROWNUM <= 10
```

### Boolean
**PostgreSQL:**
```sql
active BOOLEAN DEFAULT TRUE
```

**Oracle:**
```sql
active NUMBER(1) DEFAULT 1 CHECK (active IN (0,1))
-- oder:
active CHAR(1) DEFAULT 'Y' CHECK (active IN ('Y','N'))
```

## 12. Performance-Tuning

### Connection Pooling
```cpp
// backend/database.cpp
QSqlDatabase db = QSqlDatabase::addDatabase("QOCI");
db.setConnectOptions("OCI_ATTR_PREFETCH_ROWS=100"); // Prefetch
```

### Prepared Statements verwenden
```cpp
QSqlQuery query(db);
query.prepare("SELECT message FROM greetings WHERE id = :id");
query.bindValue(":id", id);
query.exec();
```

## 13. Monitoring

### Logs
```bash
# Backend Logs
sudo journalctl -u webapp-backend -f

# NGINX Logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Health Check Endpoint

Backend erweitern:
```cpp
server.route("/health", []() {
    return QHttpServerResponse("OK");
});
```

NGINX Health Check:
```nginx
location /health {
    proxy_pass http://localhost:3000/health;
    access_log off;
}
```

Monitoring via cron:
```bash
*/5 * * * * curl -f http://localhost/health || systemctl restart webapp-backend
```

## 14. Backup

### Datenbank
```bash
# Oracle Export
expdp username/password@SERVICE_NAME \
      directory=DATA_PUMP_DIR \
      dumpfile=webapp_backup.dmp \
      schemas=WEBAPP_SCHEMA
```

### Applikation
```bash
sudo tar -czf /backup/webapp-$(date +%Y%m%d).tar.gz /opt/webapp
```

## Checkliste Production Deployment

- [ ] Oracle Instant Client installiert
- [ ] Oracle Schema angelegt (`init-oracle.sql`)
- [ ] Backend kompiliert mit `QOCI` Treiber
- [ ] DB-Passwort in Umgebungsvariable/Vault
- [ ] API-Credentials gesetzt (`API_USER`, `API_PASSWORD`, `API_SECRET`)
- [ ] Frontend nach `/var/www/webapp` kopiert
- [ ] Echtes SSL-Zertifikat installiert (Let's Encrypt / Firmen-CA)
- [ ] NGINX mit HTTPS + gewünschtem Auth konfiguriert
- [ ] systemd Service erstellt (mit Env-Variablen)
- [ ] Firewall-Regeln gesetzt (nur 443 offen)
- [ ] Logs und Monitoring eingerichtet
- [ ] Backup-Strategie definiert

## Troubleshooting Production

### "ORA-12154: TNS:could not resolve the connect identifier"
```bash
# TNS_ADMIN setzen
export TNS_ADMIN=/opt/oracle/network/admin
# oder Connection String verwenden statt TNS-Name
```

### "ORA-12541: TNS:no listener"
```bash
# Oracle Listener Status prüfen
lsnrctl status
# Firewall zwischen App-Server und Oracle prüfen
telnet oracle-host 1521
```

### "QSqlDatabase: QOCI driver not loaded"
```bash
# Oracle Instant Client Library-Pfad prüfen
ldd /path/to/backend | grep libclnt
export LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib:$LD_LIBRARY_PATH
```

## Support

Oracle-spezifische Fragen:
- Oracle Dokumentation: https://docs.oracle.com/
- Qt SQL Driver: https://doc.qt.io/qt-6/sql-driver.html#qoci

AD/Kerberos Fragen:
- Konsultieren Sie Ihren System-Administrator
- Windows-Domain-Dokumentation
