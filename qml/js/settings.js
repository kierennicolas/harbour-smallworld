.pragma library
.import QtQuick.LocalStorage 2.0 as Sql
// Tiny key/value store in the app's own data folder (works inside Sailjail).

function _db() {
    var db = Sql.LocalStorage.openDatabaseSync("harbour-smallworld", "", "Small World settings", 10000)
    db.transaction(function (tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT)")
    })
    return db
}

function get(key, fallback) {
    var value = fallback
    try {
        _db().readTransaction(function (tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE key = ?", [key])
            if (rs.rows.length > 0)
                value = rs.rows.item(0).value
        })
    } catch (e) {
        console.warn("settings: cannot read " + key + ": " + e)
    }
    return value
}

function set(key, value) {
    try {
        _db().transaction(function (tx) {
            tx.executeSql("INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)", [key, String(value)])
        })
    } catch (e) {
        console.warn("settings: cannot write " + key + ": " + e)
    }
}
