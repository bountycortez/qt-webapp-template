QT += core network sql httpserver
QT -= gui

CONFIG += c++17 console
CONFIG -= app_bundle

# Compiler Flags
QMAKE_CXXFLAGS += -Wall -Wextra

# Target Name
TARGET = backend
TEMPLATE = app

# Source Files
SOURCES += \
    main.cpp \
    server.cpp \
    database.cpp \
    authmanager.cpp

# Header Files
HEADERS += \
    server.h \
    database.h \
    authmanager.h

# PostgreSQL für Development (Mac)
unix:!macx {
    # Linux
    LIBS += -lpq
}

macx {
    # libpq Pfad dynamisch ermitteln:
    # brew install libpq  → /opt/homebrew/opt/libpq   (empfohlen, kein Konflikt)
    # brew install postgresql@17 → /opt/homebrew/opt/postgresql@17
    # brew install postgresql@15 → /opt/homebrew/opt/postgresql@15  (legacy)
    LIBPQ_PREFIX = $$system(brew --prefix libpq 2>/dev/null)
    isEmpty(LIBPQ_PREFIX) {
        LIBPQ_PREFIX = $$system(brew --prefix postgresql@17 2>/dev/null)
    }
    isEmpty(LIBPQ_PREFIX) {
        LIBPQ_PREFIX = $$system(brew --prefix postgresql@15 2>/dev/null)
    }
    isEmpty(LIBPQ_PREFIX) {
        LIBPQ_PREFIX = /opt/homebrew/opt/libpq   # letzter Fallback
    }
    message("libpq prefix: $$LIBPQ_PREFIX")

    INCLUDEPATH += $$LIBPQ_PREFIX/include
    LIBS        += -L$$LIBPQ_PREFIX/lib -lpq

    # Qt6 Pfad
    QT6_PREFIX = $$system(brew --prefix qt@6 2>/dev/null)
    isEmpty(QT6_PREFIX): QT6_PREFIX = /opt/homebrew/opt/qt@6
    INCLUDEPATH += $$QT6_PREFIX/include
    LIBS        += -L$$QT6_PREFIX/lib
}

# Für Oracle Production (auskommentiert für Development)
# unix {
#     ORACLE_HOME = /usr/lib/oracle/21/client64
#     INCLUDEPATH += $$ORACLE_HOME/include
#     LIBS += -L$$ORACLE_HOME/lib -lclntsh
# }

# Output Directory
DESTDIR = $$PWD
OBJECTS_DIR = $$PWD/obj
MOC_DIR = $$PWD/moc

# Default rules for deployment
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
