#include "database.h"
#include <QDebug>
#include <QSqlRecord>
#include <QJsonObject>
#include <QJsonArray>

Database::Database(QObject *parent)
    : QObject(parent)
{
}

Database::~Database()
{
    if (db.isOpen()) {
        db.close();
    }
}

bool Database::connect()
{
    // PostgreSQL für Development
    db = QSqlDatabase::addDatabase("QPSQL");
    db.setHostName("localhost");
    db.setPort(5432);
    db.setDatabaseName("webapp");
    db.setUserName("webapp_user");
    db.setPassword("webapp_pass");
    
    /* 
     * Für Oracle Production (siehe MIGRATION.md):
     * 
     * db = QSqlDatabase::addDatabase("QOCI");
     * 
     * // Variante 1: Easy Connect
     * db.setDatabaseName("//oracle-host.firma.local:1521/XEPDB1");
     * 
     * // Variante 2: TNS Name
     * db.setDatabaseName("ORCL");
     * 
     * db.setUserName("webapp_user");
     * 
     * // Passwort aus Umgebungsvariable
     * QString password = qEnvironmentVariable("DB_PASSWORD");
     * if (password.isEmpty()) {
     *     qCritical() << "DB_PASSWORD Umgebungsvariable nicht gesetzt!";
     *     return false;
     * }
     * db.setPassword(password);
     */
    
    if (!db.open()) {
        logError("Verbindung herstellen", db.lastError());
        return false;
    }
    
    qInfo() << "Datenbank verbunden:" << db.databaseName();
    return true;
}

QString Database::getGreeting(const QString &language)
{
    if (!isConnected()) {
        qWarning() << "Keine Datenbankverbindung!";
        return "Error: No database connection";
    }
    
    QSqlQuery query(db);
    
    // Prepared Statement für Sicherheit
    query.prepare("SELECT message FROM greetings WHERE language = :lang LIMIT 1");
    query.bindValue(":lang", language);
    
    if (!query.exec()) {
        logError("Greeting abrufen", query.lastError());
        return "Error loading greeting";
    }
    
    if (query.next()) {
        QString message = query.value("message").toString();
        qDebug() << "Greeting gefunden:" << message << "(" << language << ")";
        return message;
    }
    
    // Fallback auf Deutsch wenn Sprache nicht gefunden
    if (language != "de") {
        qWarning() << "Sprache nicht gefunden:" << language << "- Fallback auf Deutsch";
        return getGreeting("de");
    }
    
    return "Hello World!";  // Ultimate Fallback
}

QStringList Database::getTables()
{
    QStringList tables;
    if (!isConnected()) return tables;

    QSqlQuery query(db);
    query.exec("SELECT table_name FROM information_schema.tables "
               "WHERE table_schema = 'public' ORDER BY table_name");
    while (query.next()) {
        tables << query.value(0).toString();
    }
    return tables;
}

QJsonObject Database::getTableData(const QString &tableName)
{
    QJsonObject result;
    if (!isConnected()) {
        result["error"] = "Keine Datenbankverbindung";
        return result;
    }

    // Whitelist: nur existierende Tabellen erlauben (SQL-Injection-Schutz)
    QStringList validTables = getTables();
    if (!validTables.contains(tableName)) {
        result["error"] = "Tabelle nicht gefunden: " + tableName;
        return result;
    }

    QSqlQuery query(db);
    query.exec(QString("SELECT * FROM %1 LIMIT 200").arg(tableName));

    // Spalten auslesen
    QSqlRecord rec = query.record();
    QJsonArray columns;
    for (int i = 0; i < rec.count(); ++i) {
        columns.append(rec.fieldName(i));
    }
    result["columns"] = columns;
    result["table"] = tableName;

    // Zeilen auslesen
    QJsonArray rows;
    while (query.next()) {
        QJsonObject row;
        for (int i = 0; i < rec.count(); ++i) {
            row[rec.fieldName(i)] = QJsonValue::fromVariant(query.value(i));
        }
        rows.append(row);
    }
    result["rows"] = rows;
    result["rowCount"] = rows.size();

    return result;
}

QJsonObject Database::getRowById(const QString &tableName, int id)
{
    QJsonObject result;
    if (!isConnected()) {
        result["error"] = "Keine Datenbankverbindung";
        return result;
    }

    QStringList validTables = getTables();
    if (!validTables.contains(tableName)) {
        result["error"] = "Tabelle nicht gefunden";
        return result;
    }

    QSqlQuery query(db);
    query.prepare(QString("SELECT * FROM %1 WHERE id = :id").arg(tableName));
    query.bindValue(":id", id);

    if (!query.exec() || !query.next()) {
        result["error"] = "Datensatz nicht gefunden";
        return result;
    }

    QSqlRecord rec = query.record();
    for (int i = 0; i < rec.count(); ++i) {
        result[rec.fieldName(i)] = QJsonValue::fromVariant(query.value(i));
    }
    return result;
}

bool Database::isConnected() const
{
    return db.isOpen();
}

void Database::logError(const QString &operation, const QSqlError &error)
{
    if (error.type() != QSqlError::NoError) {
        qCritical() << "DB-Fehler bei" << operation << ":";
        qCritical() << "  Type:" << error.type();
        qCritical() << "  Text:" << error.text();
        qCritical() << "  Database:" << error.databaseText();
        qCritical() << "  Driver:" << error.driverText();
    }
}
