.pragma library
// Link rules for Small World. Plain ES5: Sailfish OS runs QML on Qt 5.6.

var homeUrl = "https://www.asmallworld.com/"

// Pages on these domains (and their subdomains) stay in the app.
// Everything else opens in the Sailfish Browser or the matching app.
var siteDomains = ["asmallworld.com"]

function schemeOf(url) {
    var m = /^([a-z][a-z0-9+.\-]*):/i.exec(String(url))
    return m ? m[1].toLowerCase() : ""
}

function hostOf(url) {
    var m = /^[a-z][a-z0-9+.\-]*:\/\/(?:[^@\/?#]*@)?(\[[^\]]*\]|[^:\/?#]*)/i.exec(String(url))
    return m ? m[1].toLowerCase().replace(/\.$/, "") : ""
}

function isSiteHost(host) {
    host = String(host).toLowerCase()
    for (var i = 0; i < siteDomains.length; ++i) {
        var d = siteDomains[i]
        if (host === d)
            return true
        var suffix = "." + d
        if (host.length > suffix.length && host.slice(-suffix.length) === suffix)
            return true
    }
    return false
}

// "stay": load inside the app. "external": hand to the system (browser,
// mail, phone, maps...).
function classify(url) {
    var scheme = schemeOf(url)
    if (scheme === "http" || scheme === "https")
        return isSiteHost(hostOf(url)) ? "stay" : "external"
    if (scheme === "" || scheme === "about" || scheme === "data"
            || scheme === "blob" || scheme === "javascript")
        return "stay"
    return "external"
}
