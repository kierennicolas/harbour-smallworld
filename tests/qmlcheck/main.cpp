// qmlcheck <app qml dir> [--full]
//
// 1. Compiles every QML file of the app against the real Sailfish modules.
//    This catches missing imports, unknown types, misspelt properties and
//    signal handlers (for example a handler for a WebView signal that does
//    not exist on this OS version).
// 2. Creates the pages that do not embed the web engine and evaluates their
//    bindings.
// 3. With --full, also creates the whole app (starts the web engine). Under
//    qemu this may not get far, so CI treats it as informational.
// Errors and warnings that point at the app's own files are counted.

#include <QDir>
#include <QDirIterator>
#include <QGuiApplication>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickView>
#include <QTimer>
#include <QUrl>
#include <cstdio>
#include <cstdlib>
#include <unistd.h>

static QString g_appUrl;
static QString g_appPath;
static int g_problems = 0;

static void handler(QtMsgType type, const QMessageLogContext &, const QString &msg)
{
    const bool ours = msg.contains(g_appUrl) || msg.contains(g_appPath);
    const bool counts = ours && type != QtDebugMsg && type != QtInfoMsg;
    if (counts)
        ++g_problems;
    fprintf(stderr, "%s%s\n", counts ? "[APP-QML] " : "          ", qPrintable(msg));
    fflush(stderr);
    if (type == QtFatalMsg)
        abort();
}

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    if (argc < 2) {
        fprintf(stderr, "usage: qmlcheck <app qml dir> [--full]\n");
        return 2;
    }
    const QDir root(QString::fromLocal8Bit(argv[1]));
    const bool full = argc > 2 && QByteArray(argv[2]) == "--full";
    g_appPath = root.absolutePath();
    g_appUrl = QUrl::fromLocalFile(g_appPath).toString();
    qInstallMessageHandler(handler);

    QQuickView view;
    QQmlEngine *engine = view.engine();

    if (!full) {
        int files = 0;
        QDirIterator it(root.absolutePath(), QStringList() << QStringLiteral("*.qml"),
                        QDir::Files, QDirIterator::Subdirectories);
        while (it.hasNext()) {
            const QString path = it.next();
            QQmlComponent c(engine, QUrl::fromLocalFile(path));
            ++files;
            if (c.isError()) {
                for (const QQmlError &e : c.errors())
                    qWarning("%s", qPrintable(e.toString()));
                ++g_problems;
            } else {
                fprintf(stderr, "COMPILED  %s\n", qPrintable(root.relativeFilePath(path)));
            }
        }
        fprintf(stderr, "compiled %d file(s)\n", files);

        const char *creatable[] = { "pages/AboutPage.qml", "pages/MenuPage.qml", "cover/CoverPage.qml" };
        for (const char *f : creatable) {
            QQmlComponent c(engine, QUrl::fromLocalFile(root.filePath(QString::fromLatin1(f))));
            QObject *o = c.create(view.rootContext());
            if (!o) {
                for (const QQmlError &e : c.errors())
                    qWarning("%s", qPrintable(e.toString()));
                ++g_problems;
            } else {
                fprintf(stderr, "CREATED   %s (%s)\n", f, o->metaObject()->className());
            }
        }
        // Bindings were evaluated during creation. Leave now: loading the
        // WebView module starts Gecko threads, which crash under qemu.
        fprintf(stderr, "qmlcheck: %d problem(s) in app QML\n", g_problems);
        fflush(stderr);
        _exit(g_problems ? 1 : 0);
    } else {
        view.setSource(QUrl::fromLocalFile(root.filePath(QStringLiteral("harbour-smallworld.qml"))));
        if (view.status() != QQuickView::Ready || !view.rootObject()) {
            for (const QQmlError &e : view.errors())
                qWarning("%s", qPrintable(e.toString()));
            ++g_problems;
        } else {
            fprintf(stderr, "CREATED   harbour-smallworld.qml with the web view\n");
        }
        QTimer::singleShot(8000, &app, &QCoreApplication::quit);
        app.exec();
    }

    fprintf(stderr, "qmlcheck%s: %d problem(s) in app QML\n", full ? " --full" : "", g_problems);
    return g_problems ? 1 : 0;
}
