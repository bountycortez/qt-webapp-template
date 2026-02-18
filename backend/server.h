#ifndef SERVER_H
#define SERVER_H

#include <QObject>
#include <QHttpServer>
#include <QHttpServerResponse>
#include <QJsonObject>
#include <QJsonDocument>
#include <QTimer>
#include "database.h"
#include "authmanager.h"

class Server : public QObject
{
    Q_OBJECT

public:
    explicit Server(Database *database, AuthManager *auth, QObject *parent = nullptr);
    ~Server();

    // Server starten
    bool start(quint16 port);

private:
    QHttpServer httpServer;
    QTcpServer *tcpServer = nullptr;
    Database *db;
    AuthManager *authManager;

    // Route Handlers
    void setupRoutes();
    QHttpServerResponse handleLogin(const QHttpServerRequest &request);
    QHttpServerResponse handleGetGreeting(const QHttpServerRequest &request);
    QHttpServerResponse handleGetStyles();
    QHttpServerResponse handleGetTables();
    QHttpServerResponse handleGetTableData(const QHttpServerRequest &request);
    QHttpServerResponse handleShutdown(const QHttpServerRequest &request);
    QHttpServerResponse handleHealth();

    // Product CRUD Handlers
    QHttpServerResponse handleGetProducts(const QHttpServerRequest &request);
    QHttpServerResponse handleCreateProduct(const QHttpServerRequest &request);
    QHttpServerResponse handleUpdateProduct(int productId, const QHttpServerRequest &request);
    QHttpServerResponse handleDeleteProduct(int productId, const QHttpServerRequest &request);

    // Username aus Bearer-Token extrahieren
    QString getUsernameFromRequest(const QHttpServerRequest &request) const;

    // Auth-Prüfung — gibt leeren String zurück wenn gültig, sonst Fehlermeldung
    QString checkAuth(const QHttpServerRequest &request) const;

    // Hilfsfunktionen
    QHttpServerResponse jsonResponse(const QJsonObject &data,
                                     QHttpServerResponse::StatusCode status = QHttpServerResponse::StatusCode::Ok);
    QHttpServerResponse errorResponse(const QString &message,
                                      QHttpServerResponse::StatusCode status = QHttpServerResponse::StatusCode::InternalServerError);
    QHttpServerResponse unauthorizedResponse(const QString &message = "Nicht autorisiert");
};

#endif // SERVER_H
