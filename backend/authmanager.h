#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QString>
#include <QMap>
#include <QDateTime>
#include <QJsonObject>

class AuthManager : public QObject
{
    Q_OBJECT

public:
    explicit AuthManager(QObject *parent = nullptr);

    // Token erzeugen bei erfolgreichem Login
    QString generateToken(const QString &username);

    // Token validieren — gibt Username zurück oder leer bei Fehler
    QString validateToken(const QString &token) const;

    // Login prüfen (Username + Passwort)
    bool authenticate(const QString &username, const QString &password) const;

    // Token-Lebensdauer in Sekunden (default: 8 Stunden)
    void setTokenLifetime(int seconds);
    int tokenLifetime() const;

private:
    // HMAC-SHA256 Signatur erzeugen
    QByteArray sign(const QByteArray &payload) const;

    // Base64Url Encoding (JWT-kompatibel)
    static QByteArray base64UrlEncode(const QByteArray &data);
    static QByteArray base64UrlDecode(const QByteArray &data);

    QByteArray m_secret;          // HMAC Secret Key
    int m_tokenLifetime = 28800;  // 8 Stunden

    // Credentials (aus Env-Variablen oder Defaults)
    QString m_apiUser;
    QString m_apiPassword;
};

#endif // AUTHMANAGER_H
