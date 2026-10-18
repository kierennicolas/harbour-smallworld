import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import "../js/links.js" as Links
import "../js/settings.js" as Settings

WebViewPage {
    id: page

    allowedOrientations: Orientation.All

    property alias webView: webView
    property bool desktopMode: false
    // The engine's own (mobile) user agent, remembered so desktop mode can be
    // switched off again without restarting.
    property string mobileUserAgent: ""
    readonly property string desktopUserAgent:
        "Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0"
    // Set when a tapped link is being handed to the system, so a page load
    // that already started for it can be undone.
    property string externalPending: ""

    function goHome() {
        webView.load(Links.homeUrl)
    }

    function setDesktopMode(on) {
        if (on === desktopMode)
            return
        desktopMode = on
        Settings.set("desktopMode", on ? "1" : "0")
        if (on) {
            webView.httpUserAgent = desktopUserAgent
        } else if (mobileUserAgent !== "") {
            webView.httpUserAgent = mobileUserAgent
        }
        webView.reload()
    }

    function openExternally(target) {
        externalPending = target
        externalTimer.restart()
        webView.stop()
        Qt.openUrlExternally(target)
    }

    Component.onCompleted: {
        desktopMode = Settings.get("desktopMode", "0") === "1"
        if (desktopMode)
            webView.httpUserAgent = desktopUserAgent
        webView.url = Links.homeUrl
    }

    WebView {
        id: webView

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: toolbar.top
        }

        onLinkClicked: {
            if (Links.classify(url) === "external")
                page.openExternally(url)
        }

        onUrlChanged: {
            var current = url.toString()
            if (page.externalPending !== ""
                    && Links.hostOf(current) === Links.hostOf(page.externalPending)) {
                // The outside page started loading in here before we could stop it.
                page.externalPending = ""
                if (webView.canGoBack)
                    webView.goBack()
                else
                    page.goHome()
            }
        }

        onHttpUserAgentChanged: {
            if (!page.desktopMode && httpUserAgent !== "" && httpUserAgent !== page.desktopUserAgent)
                page.mobileUserAgent = httpUserAgent
        }
    }

    Timer {
        id: externalTimer
        interval: 3000
        onTriggered: page.externalPending = ""
    }

    Item {
        id: toolbar

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: page.isPortrait ? Theme.itemSizeMedium : Theme.itemSizeSmall

        Rectangle {
            anchors.fill: parent
            color: Theme.highlightDimmerColor
        }

        // Page load progress, along the top edge of the toolbar.
        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
            }
            height: Math.max(2, Theme.paddingSmall / 2)
            width: parent.width * Math.max(0.05, webView.loadProgress / 100)
            color: Theme.highlightColor
            visible: webView.loading
        }

        Row {
            anchors.fill: parent

            IconButton {
                width: toolbar.width / 5
                height: toolbar.height
                icon.source: "image://theme/icon-m-back"
                enabled: webView.canGoBack
                onClicked: webView.goBack()
            }
            IconButton {
                width: toolbar.width / 5
                height: toolbar.height
                icon.source: "image://theme/icon-m-forward"
                enabled: webView.canGoForward
                onClicked: webView.goForward()
            }
            IconButton {
                width: toolbar.width / 5
                height: toolbar.height
                icon.source: "image://theme/icon-m-home"
                onClicked: page.goHome()
            }
            IconButton {
                width: toolbar.width / 5
                height: toolbar.height
                icon.source: webView.loading ? "image://theme/icon-m-reset" : "image://theme/icon-m-refresh"
                onClicked: webView.loading ? webView.stop() : webView.reload()
            }
            IconButton {
                width: toolbar.width / 5
                height: toolbar.height
                icon.source: "image://theme/icon-m-menu"
                onClicked: pageStack.push(Qt.resolvedUrl("MenuPage.qml"), { browser: page })
            }
        }
    }
}
