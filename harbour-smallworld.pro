# QML-only app, started by Sailfish's standard launcher (sailfish-qml).
TARGET = harbour-smallworld
CONFIG += sailfishapp_qml

DISTFILES += \
    harbour-smallworld.desktop \
    qml/harbour-smallworld.qml \
    qml/pages/BrowserPage.qml \
    qml/pages/MenuPage.qml \
    qml/pages/AboutPage.qml \
    qml/cover/CoverPage.qml \
    qml/js/links.js \
    qml/js/settings.js \
    rpm/harbour-smallworld.spec \
    README.md \
    LICENSE

# Harbour only allows files under /usr/share/harbour-smallworld.
license.files = LICENSE
license.path = /usr/share/$${TARGET}
INSTALLS += license

# sailfishapp_qml.prf installs icons/<size>/harbour-smallworld.png for each size.
SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172
