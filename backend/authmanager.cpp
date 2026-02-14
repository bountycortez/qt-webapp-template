#include "authmanager.h"
#include <QMessageAuthenticationCode>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUuid>
#include <QDebug>

AuthManager::AuthManager(QObject *parent)
    : QObject(parent)
{
    // Secret aus Umgebungsvariable oder zufällig generieren
    QByteArray envSecret = qgetenv("API_SECRET");
    if (envSecret.isEmpty()) {
        m_secret = QUuid::createUuid().toByteArray() + QUuid::createUuid().toByteArray();
        qInfo() << "Auth: Zufälliger Secret-Key generiert (setze API_SECRET für persistenten Key)";
    } else {
        m_secret = envSecret;
        qInfo() << "Auth: Secret-Key aus API_SECRET geladen";
    }

    // Credentials aus Umgebungsvariablen oder Development-Defaults
    m_apiUser = qEnvironmentVariable("API_USER", "admin");
    m_apiPassword = qEnvironmentVariable("API_PASSWORD", "admin123");

    if (qEnvironmentVariable("API_USER").isEmpty()) {
        qWarning() << "Auth: Verwende Default-Credentials (API_USER/API_PASSWORD setzen für Production!)";
    }
}

bool AuthManager::authenticate(const QString &username, const QString &password) const
{
    return (username == m_apiUser && password == m_apiPassword);
}

QString AuthManager::generateToken(const QString &username)
{
    // JWT-ähnliches Format: header.payload.signature
    QJsonObject header;
    header["alg"] = "HS256";
    header["typ"] = "JWT";

    QJsonObject payload;
    payload["sub"] = username;
    payload["iat"] = QDateTime::currentSecsSinceEpoch();
    payload["exp"] = QDateTime::currentSecsSinceEpoch() + m_tokenLifetime;

    QByteArray headerB64 = base64UrlEncode(QJsonDocument(header).toJson(QJsonDocument::Compact));
    QByteArray payloadB64 = base64UrlEncode(QJsonDocument(payload).toJson(QJsonDocument::Compact));

    QByteArray sigInput = headerB64 + "." + payloadB64;
    QByteArray signature = base64UrlEncode(sign(sigInput));

    QString token = QString::fromUtf8(headerB64 + "." + payloadB64 + "." + signature);

    qInfo() << "Auth: Token generiert für User:" << username
            << "- gültig bis:" << QDateTime::fromSecsSinceEpoch(
                   QDateTime::currentSecsSinceEpoch() + m_tokenLifetime).toString(Qt::ISODate);

    return token;
}

QString AuthManager::validateToken(const QString &token) const
{
    QStringList parts = token.split('.');
    if (parts.size() != 3) {
        qDebug() << "Auth: Token-Format ungültig (erwartet 3 Teile)";
        return {};
    }

    // Signatur prüfen
    QByteArray sigInput = parts[0].toUtf8() + "." + parts[1].toUtf8();
    QByteArray expectedSig = base64UrlEncode(sign(sigInput));

    if (expectedSig != parts[2].toUtf8()) {
        qDebug() << "Auth: Token-Signatur ungültig";
        return {};
    }

    // Payload dekodieren
    QByteArray payloadJson = base64UrlDecode(parts[1].toUtf8());
    QJsonDocument doc = QJsonDocument::fromJson(payloadJson);
    if (doc.isNull()) {
        qDebug() << "Auth: Token-Payload nicht lesbar";
        return {};
    }

    QJsonObject payload = doc.object();

    // Ablaufzeit prüfen
    qint64 exp = payload["exp"].toInteger();
    if (QDateTime::currentSecsSinceEpoch() > exp) {
        qDebug() << "Auth: Token abgelaufen";
        return {};
    }

    return payload["sub"].toString();
}

QByteArray AuthManager::sign(const QByteArray &payload) const
{
    return QMessageAuthenticationCode::hash(payload, m_secret, QCryptographicHash::Sha256);
}

QByteArray AuthManager::base64UrlEncode(const QByteArray &data)
{
    QByteArray b64 = data.toBase64(QByteArray::Base64UrlEncoding | QByteArray::OmitTrailingEquals);
    return b64;
}

QByteArray AuthManager::base64UrlDecode(const QByteArray &data)
{
    return QByteArray::fromBase64(data, QByteArray::Base64UrlEncoding);
}

void AuthManager::setTokenLifetime(int seconds)
{
    m_tokenLifetime = seconds;
}

int AuthManager::tokenLifetime() const
{
    return m_tokenLifetime;
}
