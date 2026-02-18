#include "server.h"
#include <QCoreApplication>
#include <QDebug>
#include <QTcpServer>
#include <QUrlQuery>
#include <QDateTime>
#include <QJsonArray>

Server::Server(Database *database, AuthManager *auth, QObject *parent)
    : QObject(parent), db(database), authManager(auth)
{
    setupRoutes();
}

Server::~Server()
{
}

void Server::setupRoutes()
{
    // Health Check — KEIN Auth nötig
    httpServer.route("/health", [this]() {
        return handleHealth();
    });

    // Login — KEIN Auth nötig
    httpServer.route("/api/login", QHttpServerRequest::Method::Post,
                     [this](const QHttpServerRequest &request) {
        return handleLogin(request);
    });

    // API: Greeting — Auth erforderlich
    httpServer.route("/api/greeting", QHttpServerRequest::Method::Get,
                     [this](const QHttpServerRequest &request) {
        QString authError = checkAuth(request);
        if (!authError.isEmpty()) return unauthorizedResponse(authError);
        return handleGetGreeting(request);
    });

    // API: Styles — Auth erforderlich
    httpServer.route("/api/styles", QHttpServerRequest::Method::Get,
                     [this](const QHttpServerRequest &request) {
        QString authError = checkAuth(request);
        if (!authError.isEmpty()) return unauthorizedResponse(authError);
        return handleGetStyles();
    });

    // API: Tabellenliste — Auth erforderlich
    httpServer.route("/api/tables", QHttpServerRequest::Method::Get,
                     [this](const QHttpServerRequest &request) {
        QString authError = checkAuth(request);
        if (!authError.isEmpty()) return unauthorizedResponse(authError);
        return handleGetTables();
    });

    // API: Tabellendaten — Auth erforderlich
    httpServer.route("/api/table", QHttpServerRequest::Method::Get,
                     [this](const QHttpServerRequest &request) {
        QString authError = checkAuth(request);
        if (!authError.isEmpty()) return unauthorizedResponse(authError);
        return handleGetTableData(request);
    });

    // API: Shutdown — Auth erforderlich
    httpServer.route("/api/shutdown", QHttpServerRequest::Method::Post,
                     [this](const QHttpServerRequest &request) {
        QString authError = checkAuth(request);
        if (!authError.isEmpty()) return unauthorizedResponse(authError);
        return handleShutdown(request);
    });

    // ===== PRODUCT API =====

    // GET /api/products — alle Produkte laden
    httpServer.route("/api/products", QHttpServerRequest::Method::Get,
                     [this](const QHttpServerRequest &request) {
        QString authError = checkAuth(request);
        if (!authError.isEmpty()) return unauthorizedResponse(authError);
        return handleGetProducts(request);
    });

    // POST /api/products — neues Produkt anlegen
    httpServer.route("/api/products", QHttpServerRequest::Method::Post,
                     [this](const QHttpServerRequest &request) {
        QString authError = checkAuth(request);
        if (!authError.isEmpty()) return unauthorizedResponse(authError);
        return handleCreateProduct(request);
    });

    // PUT /api/products/<id> — Produkt aktualisieren
    httpServer.route("/api/products/<arg>", QHttpServerRequest::Method::Put,
                     [this](int productId, const QHttpServerRequest &request) {
        QString authError = checkAuth(request);
        if (!authError.isEmpty()) return unauthorizedResponse(authError);
        return handleUpdateProduct(productId, request);
    });

    // DELETE /api/products/<id> — Produkt löschen
    httpServer.route("/api/products/<arg>", QHttpServerRequest::Method::Delete,
                     [this](int productId, const QHttpServerRequest &request) {
        QString authError = checkAuth(request);
        if (!authError.isEmpty()) return unauthorizedResponse(authError);
        return handleDeleteProduct(productId, request);
    });

    // Catch-All für 404
    httpServer.route("/", []() {
        QJsonObject response;
        response["error"] = "Not Found";
        response["message"] = "API Endpoints: POST /api/login, GET /api/greeting, GET /api/styles, GET /api/tables, GET /api/table?name=X, POST /api/shutdown";
        return QHttpServerResponse("application/json",
                                   QJsonDocument(response).toJson(),
                                   QHttpServerResponse::StatusCode::NotFound);
    });
}

bool Server::start(quint16 port)
{
    tcpServer = new QTcpServer(this);

    if (!tcpServer->listen(QHostAddress::Any, port)) {
        qCritical() << "Server konnte nicht auf Port" << port << "starten";
        return false;
    }

    httpServer.bind(tcpServer);

    qInfo() << "HTTP Server läuft auf Port" << port;
    return true;
}

// ===== AUTH =====

QString Server::checkAuth(const QHttpServerRequest &request) const
{
    // Authorization Header auslesen
    QByteArray authHeader;
    const QHttpHeaders headers = request.headers();
    for (qsizetype i = 0; i < headers.size(); ++i) {
        if (headers.nameAt(i).compare("authorization", Qt::CaseInsensitive) == 0) {
            authHeader = headers.valueAt(i).toByteArray();
            break;
        }
    }

    if (authHeader.isEmpty()) {
        return "Kein Authorization-Header";
    }

    // "Bearer <token>" Format
    QString headerStr = QString::fromUtf8(authHeader);
    if (!headerStr.startsWith("Bearer ", Qt::CaseInsensitive)) {
        return "Ungültiges Auth-Format (erwartet: Bearer <token>)";
    }

    QString token = headerStr.mid(7).trimmed();
    if (token.isEmpty()) {
        return "Leerer Token";
    }

    QString username = authManager->validateToken(token);
    if (username.isEmpty()) {
        return "Token ungültig oder abgelaufen";
    }

    return {};  // Leer = OK
}

// ===== LOGIN =====

QHttpServerResponse Server::handleLogin(const QHttpServerRequest &request)
{
    qDebug() << "POST /api/login";

    // JSON Body parsen
    QJsonDocument doc = QJsonDocument::fromJson(request.body());
    if (doc.isNull() || !doc.isObject()) {
        return errorResponse("Ungültiger Request-Body (JSON erwartet)",
                             QHttpServerResponse::StatusCode::BadRequest);
    }

    QJsonObject body = doc.object();
    QString username = body["username"].toString();
    QString password = body["password"].toString();

    if (username.isEmpty() || password.isEmpty()) {
        return errorResponse("Username und Passwort erforderlich",
                             QHttpServerResponse::StatusCode::BadRequest);
    }

    // Credentials prüfen
    if (!authManager->authenticate(username, password)) {
        qWarning() << "Auth: Login fehlgeschlagen für User:" << username;
        return errorResponse("Ungültige Anmeldedaten",
                             QHttpServerResponse::StatusCode::Unauthorized);
    }

    // Token generieren
    QString token = authManager->generateToken(username);

    QJsonObject response;
    response["token"] = token;
    response["username"] = username;
    response["expiresIn"] = authManager->tokenLifetime();
    response["message"] = "Login erfolgreich";

    qInfo() << "Auth: Login erfolgreich für User:" << username;
    return jsonResponse(response);
}

// ===== ROUTE HANDLERS =====

QHttpServerResponse Server::handleGetGreeting(const QHttpServerRequest &request)
{
    QUrlQuery query(request.url());
    QString language = query.queryItemValue("lang");
    if (language.isEmpty()) {
        language = "de";
    }

    qDebug() << "GET /api/greeting - Language:" << language;

    QString greeting = db->getGreeting(language);

    QJsonObject response;
    response["message"] = greeting;
    response["language"] = language;
    response["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);

    return jsonResponse(response);
}

QHttpServerResponse Server::handleShutdown(const QHttpServerRequest &request)
{
    Q_UNUSED(request);

    qWarning() << "POST /api/shutdown - Server wird heruntergefahren!";

    QJsonObject response;
    response["status"] = "shutting down";
    response["message"] = "Server wird in 2 Sekunden beendet";

    QTimer::singleShot(2000, qApp, &QCoreApplication::quit);

    return jsonResponse(response);
}

QHttpServerResponse Server::handleGetStyles()
{
    qDebug() << "GET /api/styles";

    QJsonArray styles;

    auto addStyle = [&](const QString &name, const QString &desc) {
        QJsonObject s;
        s["name"] = name;
        s["description"] = desc;
        styles.append(s);
    };

    addStyle("Material",  "Google Material Design - modern, farbenfroh");
    addStyle("Fusion",    "Desktop-Style - klassisch, plattformübergreifend");
    addStyle("Basic",     "Minimalistisch - leichtgewichtig, schlicht");
    addStyle("Universal", "Microsoft Universal Design - Windows 10/11 Look");

    QJsonObject response;
    response["styles"] = styles;
    response["default"] = "Material";

    return jsonResponse(response);
}

QHttpServerResponse Server::handleGetTables()
{
    qDebug() << "GET /api/tables";

    QStringList tables = db->getTables();

    QJsonArray arr;
    for (const QString &t : tables)
        arr.append(t);

    QJsonObject response;
    response["tables"] = arr;
    return jsonResponse(response);
}

QHttpServerResponse Server::handleGetTableData(const QHttpServerRequest &request)
{
    QUrlQuery query(request.url());
    QString tableName = query.queryItemValue("name");
    qDebug() << "GET /api/table - name:" << tableName;

    if (tableName.isEmpty()) {
        return errorResponse("Parameter 'name' fehlt",
                             QHttpServerResponse::StatusCode::BadRequest);
    }

    QJsonObject data = db->getTableData(tableName);
    if (data.contains("error")) {
        return errorResponse(data["error"].toString(),
                             QHttpServerResponse::StatusCode::NotFound);
    }

    return jsonResponse(data);
}

QHttpServerResponse Server::handleHealth()
{
    QJsonObject response;
    response["status"] = "ok";
    response["database"] = db->isConnected() ? "connected" : "disconnected";
    response["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);

    return jsonResponse(response);
}

// ===== PRODUCT HANDLER =====

QString Server::getUsernameFromRequest(const QHttpServerRequest &request) const
{
    const QHttpHeaders headers = request.headers();
    for (qsizetype i = 0; i < headers.size(); ++i) {
        if (headers.nameAt(i).compare("authorization", Qt::CaseInsensitive) == 0) {
            QString h = QString::fromUtf8(headers.valueAt(i).toByteArray());
            if (h.startsWith("Bearer ", Qt::CaseInsensitive))
                return authManager->validateToken(h.mid(7).trimmed());
        }
    }
    return {};
}

QHttpServerResponse Server::handleGetProducts(const QHttpServerRequest &request)
{
    Q_UNUSED(request);
    qDebug() << "GET /api/products";
    QJsonObject data = db->getProducts();
    if (data.contains("error"))
        return errorResponse(data["error"].toString());
    return jsonResponse(data);
}

QHttpServerResponse Server::handleCreateProduct(const QHttpServerRequest &request)
{
    qDebug() << "POST /api/products";
    QJsonDocument doc = QJsonDocument::fromJson(request.body());
    if (doc.isNull() || !doc.isObject())
        return errorResponse("Ungültiger JSON-Body", QHttpServerResponse::StatusCode::BadRequest);

    QString username = getUsernameFromRequest(request);
    QJsonObject result = db->insertProduct(doc.object(), username);

    if (result.contains("error"))
        return errorResponse(result["error"].toString(), QHttpServerResponse::StatusCode::BadRequest);
    return jsonResponse(result, QHttpServerResponse::StatusCode::Created);
}

QHttpServerResponse Server::handleUpdateProduct(int productId, const QHttpServerRequest &request)
{
    qDebug() << "PUT /api/products/" << productId;
    QJsonDocument doc = QJsonDocument::fromJson(request.body());
    if (doc.isNull() || !doc.isObject())
        return errorResponse("Ungültiger JSON-Body", QHttpServerResponse::StatusCode::BadRequest);

    QString username = getUsernameFromRequest(request);
    QJsonObject result = db->updateProduct(productId, doc.object(), username);

    if (result.contains("error"))
        return errorResponse(result["error"].toString(), QHttpServerResponse::StatusCode::BadRequest);
    return jsonResponse(result);
}

QHttpServerResponse Server::handleDeleteProduct(int productId, const QHttpServerRequest &request)
{
    Q_UNUSED(request);
    qDebug() << "DELETE /api/products/" << productId;
    QJsonObject result = db->deleteProduct(productId);

    if (result.contains("error"))
        return errorResponse(result["error"].toString(), QHttpServerResponse::StatusCode::NotFound);
    return jsonResponse(result);
}

// ===== HILFSFUNKTIONEN =====

QHttpServerResponse Server::jsonResponse(const QJsonObject &data,
                                         QHttpServerResponse::StatusCode status)
{
    return QHttpServerResponse("application/json",
                               QJsonDocument(data).toJson(),
                               status);
}

QHttpServerResponse Server::errorResponse(const QString &message,
                                          QHttpServerResponse::StatusCode status)
{
    QJsonObject error;
    error["error"] = true;
    error["message"] = message;
    error["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);

    return jsonResponse(error, status);
}

QHttpServerResponse Server::unauthorizedResponse(const QString &message)
{
    QJsonObject error;
    error["error"] = true;
    error["message"] = message;
    error["code"] = 401;
    error["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);

    return QHttpServerResponse("application/json",
                               QJsonDocument(error).toJson(),
                               QHttpServerResponse::StatusCode::Unauthorized);
}
