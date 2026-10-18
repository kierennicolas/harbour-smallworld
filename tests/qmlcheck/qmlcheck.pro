# Loads the app's QML with the real Sailfish modules inside an SDK target.
# Used by CI (ci/sfos-qml-smoke.sh); not part of the RPM.
TEMPLATE = app
TARGET = qmlcheck
QT += quick qml
CONFIG += c++11
SOURCES += main.cpp
