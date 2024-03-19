TARGET = chapter5-ipc
DESTDIR = ..

QT += qml quick positioning location network concurrent sql sensors
CONFIG -= app_bundle

SOURCES = main.cpp
RESOURCES += app.qrc \
             ../../images/images.qrc \
             ../../images/weather/weatherimages.qrc \

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = $$OUT_PWD/../frontend/qml

CONFIG += install_ok  # Do not cargo-cult this!
target.path = $$[QT_INSTALL_EXAMPLES]/interfaceframework/qface-tutorial/chapter5-ipc
INSTALLS += target
