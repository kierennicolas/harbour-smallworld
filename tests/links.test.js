// Tests the link rules in qml/js/links.js with plain Node (no Qt needed).
// Run: node tests/links.test.js
"use strict";
const fs = require("fs");
const path = require("path");
const vm = require("vm");
const assert = require("assert");

const src = fs.readFileSync(path.join(__dirname, "..", "qml", "js", "links.js"), "utf8")
    .replace(/^\.pragma library\s*$/m, "");
const L = {};
vm.runInNewContext(src + "\n;Object.assign(L, {homeUrl, schemeOf, hostOf, isSiteHost, classify});", { L });

let failures = 0;
function check(name, fn) {
    try { fn(); console.log("PASS  " + name); }
    catch (e) { failures++; console.log("FAIL  " + name + "\n      " + e.message); }
}

check("home page is on the site", () => {
    assert.strictEqual(L.classify(L.homeUrl), "stay");
    assert.ok(L.homeUrl.startsWith("https://"));
});

check("site pages stay in the app", () => {
    for (const u of [
        "https://www.asmallworld.com/",
        "https://asmallworld.com/events/123?x=1#top",
        "https://WWW.ASMALLWORLD.COM/Profile",
        "https://cdn.asmallworld.com/img.jpg",
        "http://asmallworld.com",
        "https://www.asmallworld.com./trailing-dot",
        "https://www.asmallworld.com:443/port",
        "https://user:pw@www.asmallworld.com/userinfo",
    ]) assert.strictEqual(L.classify(u), "stay", u);
});

check("other websites open outside", () => {
    for (const u of [
        "https://www.instagram.com/asmallworld",
        "https://apps.apple.com/app/asmallworld/id528252808",
        "https://evilasmallworld.com/",               // suffix without a dot
        "https://asmallworld.com.evil.example/",      // site name as a prefix
        "https://www.asmallworld.com@evil.example/",  // userinfo trick
        "http://example.org",
    ]) assert.strictEqual(L.classify(u), "external", u);
});

check("non-web links go to the system", () => {
    for (const u of ["mailto:concierge@asmallworld.com", "tel:+41441234567", "sms:+4412", "geo:47.37,8.54", "intent://x"])
        assert.strictEqual(L.classify(u), "external", u);
});

check("in-page and engine-internal URLs stay", () => {
    for (const u of ["", "about:blank", "data:text/html,hi", "blob:https://www.asmallworld.com/abc", "javascript:void(0)"])
        assert.strictEqual(L.classify(u), "stay", JSON.stringify(u));
});

check("hostOf", () => {
    assert.strictEqual(L.hostOf("https://Www.Example.com:8080/a?b#c"), "www.example.com");
    assert.strictEqual(L.hostOf("https://u:p@h.example/"), "h.example");
    assert.strictEqual(L.hostOf("https://[::1]:8080/"), "[::1]");
    assert.strictEqual(L.hostOf("mailto:x@y"), "");
});

check("links.js is plain ES5 (Qt 5.6)", () => {
    for (const bad of [/\blet\s/, /\bconst\s/, /=>/, /`/, /\.endsWith\(/, /\.startsWith\(/, /\.includes\(/])
        assert.ok(!bad.test(src), "uses " + bad);
});

check("all app JavaScript is ES5 (Qt 5.6)", () => {
    const root = path.join(__dirname, "..", "qml");
    const files = [];
    (function walk(d) {
        for (const e of fs.readdirSync(d, { withFileTypes: true })) {
            const p = path.join(d, e.name);
            if (e.isDirectory()) walk(p);
            else if (/\.(qml|js)$/.test(e.name)) files.push(p);
        }
    })(root);
    for (const f of files) {
        const text = fs.readFileSync(f, "utf8").replace(/\/\/.*$/gm, "");
        for (const bad of [/\blet\s/, /\bconst\s/, /=>/, /`/])
            assert.ok(!bad.test(text), path.relative(root, f) + " uses " + bad);
    }
});

console.log(failures ? `${failures} failed` : "all link tests passed");
process.exit(failures ? 1 : 0);
