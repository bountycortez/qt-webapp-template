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
    # Mac ARM mit Homebrew
    INCLUDEPATH += /opt/homebrew/opt/postgresql@15/include
    LIBS += -L/opt/homebrew/opt/postgresql@15/lib -lpq
    
    # Qt6 Pfad
    INCLUDEPATH += /opt/homebrew/opt/qt@6/include
    LIBS += -L/opt/homebrew/opt/qt@6/lib
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
