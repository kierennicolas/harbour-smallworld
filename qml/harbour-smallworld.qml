import QtQuick 2.6
import Sailfish.Silica 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: appWindow

    // The page that holds the web view; the cover reads its title from it.
    property Item browserPage: null

    initialPage: Component {
        BrowserPage {
            id: browser
            Component.onCompleted: appWindow.browserPage = browser
        }
    }
    cover: Component {
        CoverPage {
            browser: appWindow.browserPage
        }
    }
    allowedOrientations: defaultAllowedOrientations
}
