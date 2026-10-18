import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: page

    allowedOrientations: Orientation.All

    // The BrowserPage this menu acts on.
    property Item browser
    readonly property string currentUrl: browser ? browser.webView.url.toString() : ""
    property bool justCopied: false

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("Small World")
                description: browser ? browser.webView.title : ""
            }

            SectionHeader { text: qsTr("This page") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                text: page.currentUrl
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 3
                elide: Text.ElideRight
            }

            BackgroundItem {
                width: parent.width
                enabled: page.currentUrl !== ""
                onClicked: Qt.openUrlExternally(page.currentUrl)
                Label {
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Open in Sailfish Browser")
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
            }

            BackgroundItem {
                width: parent.width
                enabled: page.currentUrl !== ""
                onClicked: {
                    Clipboard.text = page.currentUrl
                    page.justCopied = true
                    copiedTimer.restart()
                }
                Label {
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    text: page.justCopied ? qsTr("Link copied") : qsTr("Copy link")
                    color: parent.highlighted || page.justCopied ? Theme.highlightColor : Theme.primaryColor
                }
            }

            SectionHeader { text: qsTr("Settings") }

            TextSwitch {
                text: qsTr("Desktop site")
                description: qsTr("Ask asmallworld.com for its desktop layout instead of the mobile one.")
                checked: browser ? browser.desktopMode : false
                automaticCheck: false
                onClicked: if (browser) browser.setDesktopMode(!browser.desktopMode)
            }

            SectionHeader { text: qsTr("App") }

            BackgroundItem {
                width: parent.width
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                Label {
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("About Small World")
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
            }
        }
        VerticalScrollDecorator {}
    }

    Timer {
        id: copiedTimer
        interval: 2000
        onTriggered: page.justCopied = false
    }
}
