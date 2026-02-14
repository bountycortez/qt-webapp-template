#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QUrl>
#include <QUrlQuery>
#include <QTranslator>
#include "stylehelper.h"

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setOrganizationName("WebApp");
    app.setOrganizationDomain("webapp.local");
    app.setApplicationName("Qt WebApp Frontend");
    app.setApplicationVersion(QT_VERSION_STR);

    // URL-Parameter lesen (style + lang)
    // In WASM: direkt via JavaScript aus window.location
    QString styleName = "Material";
    QString langCode = "de";

#ifdef __EMSCRIPTEN__
    char *styleResult = emscripten_run_script_string(
        "(new URLSearchParams(window.location.search)).get('style') || ''"
    );
    if (styleResult && strlen(styleResult) > 0) {
        styleName = QString::fromUtf8(styleResult);
    }

    char *langResult = emscripten_run_script_string(
        "(new URLSearchParams(window.location.search)).get('lang') || ''"
    );
    if (langResult && strlen(langResult) > 0) {
        langCode = QString::fromUtf8(langResult);
    }
#else
    // Fallback für Desktop-Tests
    QStringList args = app.arguments();
    for (const QString &arg : args) {
        if (arg.contains("style=")) {
            QUrl argUrl(arg);
            QUrlQuery query(argUrl);
            QString s = query.queryItemValue("style");
            if (!s.isEmpty()) styleName = s;
        }
        if (arg.contains("lang=")) {
            QUrl argUrl(arg);
            QUrlQuery query(argUrl);
            QString l = query.queryItemValue("lang");
            if (!l.isEmpty()) langCode = l;
        }
    }
#endif

    // Style setzen (muss vor QML-Laden passieren)
    QQuickStyle::setStyle(styleName);

    // Übersetzung laden (Deutsch ist Quellsprache, nur Englisch braucht .qm)
    QTranslator translator;
    if (langCode == "en") {
        if (translator.load(":/translations/en.qm")) {
            app.installTranslator(&translator);
            qInfo() << "English translation loaded";
        } else {
            qWarning() << "Could not load English translation";
        }
    }

    QQmlApplicationEngine engine;

    // API Base URL dynamisch aus Browser-Location ermitteln (gleicher Host/Port)
#ifdef __EMSCRIPTEN__
    QString apiBaseUrl = QString::fromUtf8(
        emscripten_run_script_string(
            "window.location.protocol + '//' + window.location.host"
        )
    );
#else
    QString apiBaseUrl = "http://localhost:3000";
#endif
    StyleHelper styleHelper;
    engine.rootContext()->setContextProperty("apiBaseUrl", apiBaseUrl);
    engine.rootContext()->setContextProperty("currentStyle", styleName);
    engine.rootContext()->setContextProperty("currentLang", langCode);
    engine.rootContext()->setContextProperty("styleHelper", &styleHelper);

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
