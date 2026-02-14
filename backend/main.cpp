#include <QCoreApplication>
#include <QDebug>
#include "server.h"
#include "database.h"
#include "authmanager.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    qInfo() << "=== Qt WebApp Backend ===";
    qInfo() << "Qt Version:" << QT_VERSION_STR;

    // Datenbank initialisieren
    Database db;
    if (!db.connect()) {
        qCritical() << "Datenbankverbindung fehlgeschlagen!";
        return 1;
    }

    qInfo() << "Datenbank erfolgreich verbunden";

    // Auth-Manager initialisieren
    AuthManager auth;
    qInfo() << "Authentifizierung aktiviert (Token-Lebensdauer:" << auth.tokenLifetime() / 3600 << "Stunden)";

    // HTTP Server starten
    Server server(&db, &auth);
    quint16 port = 3000;
    if (!server.start(port)) {
        qCritical() << "Server konnte nicht gestartet werden!";
        return 1;
    }

    qInfo() << "Server läuft auf http://localhost:" + QString::number(port);
    qInfo() << "API Endpoints:";
    qInfo() << "  POST /api/login          (öffentlich)";
    qInfo() << "  GET  /api/greeting       (Auth erforderlich)";
    qInfo() << "  GET  /api/styles         (Auth erforderlich)";
    qInfo() << "  GET  /api/tables         (Auth erforderlich)";
    qInfo() << "  GET  /api/table?name=X   (Auth erforderlich)";
    qInfo() << "  POST /api/shutdown       (Auth erforderlich)";
    qInfo() << "";
    qInfo() << "Env-Variablen: API_USER, API_PASSWORD, API_SECRET";
    qInfo() << "Drücke Ctrl+C zum Beenden";

    return app.exec();
}
