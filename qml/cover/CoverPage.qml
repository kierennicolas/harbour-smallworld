import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    // The BrowserPage, set by the app window.
    property Item browser

    Column {
        width: parent.width - 2 * Theme.paddingLarge
        anchors.centerIn: parent
        spacing: Theme.paddingMedium

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.iconSizeLarge
            height: width
            sourceSize.width: width
            sourceSize.height: height
            source: "/usr/share/icons/hicolor/172x172/apps/harbour-smallworld.png"
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Small World")
            color: Theme.highlightColor
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            text: !browser ? ""
                  : browser.webView.loading ? qsTr("Loading…")
                  : browser.webView.title
        }
    }

    CoverActionList {
        enabled: browser !== null
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: browser.webView.reload()
        }
    }
}
