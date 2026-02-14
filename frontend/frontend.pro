QT += quick qml quickcontrols2

CONFIG += c++17

# WebAssembly spezifisch
wasm {
    QMAKE_WASM_PTHREAD_POOL_SIZE = 4
}

# Source Files
SOURCES += \
    main.cpp

# Header Files
HEADERS += \
    stylehelper.h

# QML Files
RESOURCES += qml.qrc

# Additional import path used to resolve QML modules
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
