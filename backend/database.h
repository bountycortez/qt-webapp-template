#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QString>
#include <QStringList>
#include <QJsonObject>
#include <QJsonArray>

class Database : public QObject
{
    Q_OBJECT

public:
    explicit Database(QObject *parent = nullptr);
    ~Database();

    // Verbindung herstellen
    bool connect();

    // Begrüßung aus DB holen
    QString getGreeting(const QString &language = "de");

    // Tabellen auflisten
    QStringList getTables();

    // Tabellenstruktur + Daten holen
    QJsonObject getTableData(const QString &tableName);

    // Einzelnen Datensatz holen
    QJsonObject getRowById(const QString &tableName, int id);

    // Product-Tabelle anlegen + Beispieldaten einfügen
    void initProductTable();

    // Product CRUD
    QJsonObject getProducts();
    QJsonObject insertProduct(const QJsonObject &data, const QString &updatedBy = QString());
    QJsonObject updateProduct(int productId, const QJsonObject &data, const QString &updatedBy = QString());
    QJsonObject deleteProduct(int productId);

    // Verbindungsstatus prüfen
    bool isConnected() const;
    
private:
    QSqlDatabase db;
    
    // Hilfsfunktion für Fehlerbehandlung
    void logError(const QString &operation, const QSqlError &error);
};

#endif // DATABASE_H
