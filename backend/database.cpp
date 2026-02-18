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

// ===== PRODUCT CRUD =====

void Database::initProductTable()
{
    if (!isConnected()) return;

    QSqlQuery q(db);

    // Tabelle anlegen (PostgreSQL-Syntax, Oracle-kompatible Struktur)
    bool ok = q.exec(R"(
        CREATE TABLE IF NOT EXISTS product (
            product_id   SERIAL PRIMARY KEY,
            product_number VARCHAR(20) UNIQUE NOT NULL,
            gtin         BIGINT,
            name         VARCHAR(100) NOT NULL,
            unit         VARCHAR(2) NOT NULL DEFAULT 'ST',
            category_id  INTEGER,
            supplier_id  INTEGER,
            purchase_price NUMERIC(10,2),
            sales_price  NUMERIC(10,2) NOT NULL,
            vat_code     SMALLINT NOT NULL DEFAULT 2,
            description  VARCHAR(500),
            active       SMALLINT NOT NULL DEFAULT 1,
            created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at   TIMESTAMP,
            updated_by   VARCHAR(25)
        )
    )");
    if (!ok) { logError("Product-Tabelle erstellen", q.lastError()); return; }

    q.exec("CREATE INDEX IF NOT EXISTS idx_product_number ON product(product_number)");
    q.exec("CREATE INDEX IF NOT EXISTS idx_gtin ON product(gtin)");
    q.exec("CREATE INDEX IF NOT EXISTS idx_category ON product(category_id)");

    // Beispieldaten nur einfügen wenn Tabelle leer
    QSqlQuery countQ(db);
    countQ.exec("SELECT COUNT(*) FROM product");
    if (!countQ.next() || countQ.value(0).toInt() > 0) return;

    struct Sample {
        const char *number, *gtin, *name, *unit, *desc;
        double purchase, sales;
        int vatCode;
    };
    Sample samples[] = {
        {"P001", "4008400401584", "Mineralwasser Classic 0,5l",    "ST",
         "Natuerliches Mineralwasser, 0,5 Liter PET-Flasche",       0.29, 0.49, 1},
        {"P002", "4001690019002", "Kartoffelchips Salz 150g",       "ST",
         "Kartoffelchips mit Meersalz, 150g Tuete",                  0.79, 1.29, 1},
        {"P003", "4006591000011", "Langkornreis 1kg",               "ST",
         "Parboiled Langkornreis, 1 kg Packung",                     1.29, 1.99, 1},
        {"P004", "7622210951939", "Vollmilch-Schokolade 100g",      "ST",
         "Zartschmelzende Vollmilch-Schokolade, 100g Tafel",         0.89, 1.49, 1},
        {"P005", "4026608000020", "Vollkornbrot 500g",              "ST",
         "Saftiges Vollkornbrot, 500g, in Scheiben",                 1.49, 2.29, 1}
    };

    for (const auto &s : samples) {
        QSqlQuery ins(db);
        ins.prepare(
            "INSERT INTO product "
            "(product_number, gtin, name, unit, purchase_price, sales_price, vat_code, description) "
            "VALUES (:num, :gtin, :name, :unit, :pp, :sp, :vc, :desc)"
        );
        ins.bindValue(":num",  QString(s.number));
        ins.bindValue(":gtin", QString(s.gtin).toLongLong());
        ins.bindValue(":name", QString(s.name));
        ins.bindValue(":unit", QString(s.unit));
        ins.bindValue(":pp",   s.purchase);
        ins.bindValue(":sp",   s.sales);
        ins.bindValue(":vc",   s.vatCode);
        ins.bindValue(":desc", QString(s.desc));
        if (!ins.exec()) logError("Beispielprodukt einfuegen", ins.lastError());
    }
    qInfo() << "5 Beispielprodukte in product-Tabelle eingefuegt";
}

QJsonObject Database::getProducts()
{
    QJsonObject result;
    if (!isConnected()) { result["error"] = "Keine Datenbankverbindung"; return result; }

    QSqlQuery q(db);
    q.exec("SELECT product_id, product_number, gtin, name, unit, category_id, supplier_id, "
           "purchase_price, sales_price, vat_code, description, active, "
           "created_at, updated_at, updated_by FROM product ORDER BY product_id");

    QSqlRecord rec = q.record();
    QJsonArray columns, rows;
    for (int i = 0; i < rec.count(); ++i) columns.append(rec.fieldName(i));

    while (q.next()) {
        QJsonObject row;
        for (int i = 0; i < rec.count(); ++i)
            row[rec.fieldName(i)] = QJsonValue::fromVariant(q.value(i));
        rows.append(row);
    }

    result["products"] = rows;
    result["columns"]  = columns;
    result["count"]    = rows.size();
    return result;
}

QJsonObject Database::insertProduct(const QJsonObject &data, const QString &updatedBy)
{
    QJsonObject result;
    if (!isConnected()) { result["error"] = "Keine Datenbankverbindung"; return result; }

    QSqlQuery q(db);
    q.prepare(
        "INSERT INTO product "
        "(product_number, gtin, name, unit, category_id, supplier_id, "
        " purchase_price, sales_price, vat_code, description, active, updated_by) "
        "VALUES (:num, :gtin, :name, :unit, :cat, :sup, :pp, :sp, :vc, :desc, :active, :by) "
        "RETURNING product_id"
    );

    q.bindValue(":num",    data["product_number"].toString());
    q.bindValue(":gtin",   data["gtin"].toVariant());       // QVariant() → NULL wenn leer
    q.bindValue(":name",   data["name"].toString());
    q.bindValue(":unit",   data["unit"].toString().isEmpty() ? "ST" : data["unit"].toString());
    q.bindValue(":cat",    data["category_id"].toVariant());
    q.bindValue(":sup",    data["supplier_id"].toVariant());
    q.bindValue(":pp",     data["purchase_price"].toVariant());
    q.bindValue(":sp",     data["sales_price"].toDouble());
    q.bindValue(":vc",     data["vat_code"].toInt(2));
    q.bindValue(":desc",   data["description"].toString().isEmpty() ? QVariant() : data["description"].toString());
    q.bindValue(":active", data["active"].toInt(1));
    q.bindValue(":by",     updatedBy.isEmpty() ? QVariant() : updatedBy);

    if (!q.exec() || !q.next()) {
        logError("Produkt einfuegen", q.lastError());
        result["error"] = q.lastError().text();
        return result;
    }

    result["success"]    = true;
    result["product_id"] = q.value(0).toInt();
    result["message"]    = "Produkt erfolgreich angelegt";
    return result;
}

QJsonObject Database::updateProduct(int productId, const QJsonObject &data, const QString &updatedBy)
{
    QJsonObject result;
    if (!isConnected()) { result["error"] = "Keine Datenbankverbindung"; return result; }

    QSqlQuery q(db);
    q.prepare(
        "UPDATE product SET "
        "  product_number = :num, gtin = :gtin, name = :name, unit = :unit, "
        "  category_id = :cat, supplier_id = :sup, purchase_price = :pp, "
        "  sales_price = :sp, vat_code = :vc, description = :desc, "
        "  active = :active, updated_at = CURRENT_TIMESTAMP, updated_by = :by "
        "WHERE product_id = :id"
    );

    q.bindValue(":num",    data["product_number"].toString());
    q.bindValue(":gtin",   data["gtin"].toVariant());
    q.bindValue(":name",   data["name"].toString());
    q.bindValue(":unit",   data["unit"].toString().isEmpty() ? "ST" : data["unit"].toString());
    q.bindValue(":cat",    data["category_id"].toVariant());
    q.bindValue(":sup",    data["supplier_id"].toVariant());
    q.bindValue(":pp",     data["purchase_price"].toVariant());
    q.bindValue(":sp",     data["sales_price"].toDouble());
    q.bindValue(":vc",     data["vat_code"].toInt(2));
    q.bindValue(":desc",   data["description"].toString().isEmpty() ? QVariant() : data["description"].toString());
    q.bindValue(":active", data["active"].toInt(1));
    q.bindValue(":by",     updatedBy.isEmpty() ? QVariant() : updatedBy);
    q.bindValue(":id",     productId);

    if (!q.exec()) {
        logError("Produkt aktualisieren", q.lastError());
        result["error"] = q.lastError().text();
        return result;
    }
    if (q.numRowsAffected() == 0) { result["error"] = "Produkt nicht gefunden"; return result; }

    result["success"] = true;
    result["message"] = "Produkt erfolgreich aktualisiert";
    return result;
}

QJsonObject Database::deleteProduct(int productId)
{
    QJsonObject result;
    if (!isConnected()) { result["error"] = "Keine Datenbankverbindung"; return result; }

    QSqlQuery q(db);
    q.prepare("DELETE FROM product WHERE product_id = :id");
    q.bindValue(":id", productId);

    if (!q.exec()) {
        logError("Produkt loeschen", q.lastError());
        result["error"] = q.lastError().text();
        return result;
    }
    if (q.numRowsAffected() == 0) { result["error"] = "Produkt nicht gefunden"; return result; }

    result["success"] = true;
    result["message"] = "Produkt erfolgreich geloescht";
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
