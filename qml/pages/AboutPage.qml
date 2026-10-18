import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    allowedOrientations: Orientation.All

    // Replaced with the package version when the RPM is built.
    readonly property string appVersion: "@VERSION@"

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader { title: qsTr("About Small World") }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.iconSizeExtraLarge
                height: width
                sourceSize.width: width
                sourceSize.height: height
                source: "/usr/share/icons/hicolor/172x172/apps/harbour-smallworld.png"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Version %1").arg(appVersion)
                color: Theme.secondaryHighlightColor
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                wrapMode: Text.WordWrap
                text: qsTr("Small World is an unofficial Sailfish OS app for the ASMALLWORLD website. It shows asmallworld.com in Sailfish's built-in browser engine, keeps you signed in, and opens outside links in the Sailfish Browser.")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("It is not made, endorsed or supported by ASMALLWORLD AG. Your sign-in and everything you do go straight to asmallworld.com; this app stores only the website's cookies and one setting on your phone.")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Open source under the MIT licence.")
            }
        }
        VerticalScrollDecorator {}
    }
}
