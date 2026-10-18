<img src="icons/harbour-smallworld.svg" width="96" alt="Small World icon">

# Small World for Sailfish OS

An **unofficial** Sailfish OS app for [ASMALLWORLD](https://www.asmallworld.com).
ASMALLWORLD has no Sailfish app and no public API, so Small World shows the
official asmallworld.com website inside a native Sailfish app, using the same
Gecko engine as the Sailfish Browser.

Small World is not made, endorsed or supported by ASMALLWORLD AG. It does not
scrape, automate or reverse-engineer anything: your sign-in and everything you
do go straight to asmallworld.com, exactly as in a browser.

## What you get

- Its own icon and launcher entry, separate from the Sailfish Browser
- Stays signed in between launches (the site's cookies live in the app's own
  sandboxed folder)
- Toolbar: back, forward, home, reload/stop and a menu
- Menu: open the current page in the Sailfish Browser, copy its link, switch
  to the desktop layout of the site, About
- Links to other websites, e-mail addresses and phone numbers open in the
  Sailfish Browser, Mail or Phone app instead of inside Small World
- Photo and file uploads use the Sailfish pickers; alerts, sign-in prompts and
  long-press menus use the standard Sailfish WebView dialogs
- Cover shows the current page and has a reload action

It can only do what the website does; there are no push notifications.

## Install on the phone (Sony Xperia XA2 or any Sailfish OS 4.5+ device)

1. Download `harbour-smallworld-*.noarch.rpm` from the latest
   [release](../../releases/latest) (or from the artifacts of a
   [Build](../../actions/workflows/build.yml) run). The same RPM works on
   32-bit and 64-bit devices.
2. On the phone: **Settings → Untrusted software → Allow untrusted software**.
3. Open the RPM from the browser's downloads or the Transfers page and tap
   **Install**, or with developer mode on run
   `devel-su pkcon install-local harbour-smallworld-*.noarch.rpm`.

## How it is built and checked

Every push runs [`.github/workflows/build.yml`](.github/workflows/build.yml):

| Job | What it does |
| --- | --- |
| Link rules and QML lint | Runs `tests/links.test.js` on the rules that decide which links stay in the app, checks that all QML JavaScript is ES5 (Sailfish OS runs Qt 5.6), lints the QML and validates the desktop file. |
| RPM | Builds the RPM with `mb2` in the [Sailfish OS Platform SDK image](https://hub.docker.com/r/coderus/sailfishos-platform-sdk-armv7hl), runs Jolla's Harbour RPM validator, installs the RPM and its dependencies into the SDK target, checks every theme icon the app uses exists, and loads the installed QML with the real Sailfish Silica and WebView modules. |
| GitHub release | On a `v*` tag, attaches the RPM to a release. |

To cut a release: bump `Version:` in `rpm/harbour-smallworld.spec`, then either
`git tag v0.1.1 && git push --tags`, or on GitHub go to **Releases → Draft a
new release**, type a new tag such as `v0.1.1`, and publish.

### Building locally

With the [Sailfish SDK](https://docs.sailfishos.org/Develop/Apps/):

```sh
sfdk config target=SailfishOS-4.5.0.16-armv7hl
sfdk build
```

## License

MIT (see LICENSE). ASMALLWORLD is a trademark of ASMALLWORLD AG.
