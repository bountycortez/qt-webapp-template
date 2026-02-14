#ifndef STYLEHELPER_H
#define STYLEHELPER_H

#include <QObject>
#include <QString>
#include <QDebug>

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

class StyleHelper : public QObject
{
    Q_OBJECT
public:
    explicit StyleHelper(QObject *parent = nullptr) : QObject(parent) {}

    // Einen URL-Parameter setzen, alle anderen beibehalten, Seite neu laden
    Q_INVOKABLE void switchWithParams(const QString &key, const QString &value) {
#ifdef __EMSCRIPTEN__
        QString js = QString(
            "var params = new URLSearchParams(window.location.search);"
            "params.set('%1', '%2');"
            "window.location.href = window.location.pathname + '?' + params.toString();"
        ).arg(key, value);
        emscripten_run_script(js.toUtf8().constData());
#else
        qDebug() << "switchWithParams:" << key << "=" << value << "(nur in WASM)";
#endif
    }

    // Legacy: nur Style wechseln
    Q_INVOKABLE void switchStyle(const QString &style) {
        switchWithParams("style", style);
    }
};

#endif // STYLEHELPER_H
