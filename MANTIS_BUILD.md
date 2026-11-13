# Mantis Home

Local GPL-3.0 fork of https://github.com/zompinc/flauncher.

Adds foreground-only CPU and used/total memory readings, a Network settings
button, and an Inputs dialog. On a Fire TV Stick the inputs are app services;
physical HDMI source selection remains on the television's own remote.

Package: `me.efesser.flauncher.mantis`; minimum SDK remains 21. The original
FLauncher can stay installed. Select **Mantis Home** in Launcher Manager Mini
after verifying the new app. No new permissions or dependencies are required.

Build with Flutter 3.7.5, JDK 11, Android platform 33 and build-tools 33.0.2.
The fork aligns Kotlin 1.7.22 with Android Gradle Plugin 7.2.2, using Gradle 7.4.
Run `flutter pub get`, `flutter test test/widgets/system_panel_test.dart`, and
`flutter build apk --release --target-platform android-arm --build-name 0.18.0-mantis.4 --build-number 147`.
The local fork uses the standard local debug signing key for its release build;
retain that key to install later updates without changing the package identity.

The complete suite is `flutter test --concurrency=1` (125 tests). Windows needs
a SQLite-compatible `sqlite3.dll` on PATH for host database tests; this session
used a local copy of Windows' `winsqlite3.dll` under `work/toolchain/test-native/`.
This host test library is not packaged into the Android application. Wallpaper
tests use their own temporary directories to avoid Windows file-lock races.

Version 145 fixes remote Select holds without key-repeat events: short Select
opens the app on release, a 500 ms hold opens its menu once, and focus loss or
leaving the activity cancels a pending hold. Release after a hold cannot also
launch the app. Pointer long-press and manual category sorting are preserved.

Version 146 adds **Add to category** to the app menu and makes the category
picker explicitly usable with the remote. The menu scrolls on shorter displays;
an app already in all categories gets an explanation rather than a blank picker.
Newly installed apps can be added through Settings > Applications > the plus
button > the desired category. Adding does not uninstall or duplicate the app.

Version 147 adds **Move to category** in both home-card menus and the installed
app inventory. A move atomically keeps the app only in the chosen home category,
restores visibility for a hidden app, and preserves the destination's existing
order. It does not alter any other app. **Hide everywhere** and **Unhide
everywhere** are explicitly labelled as global actions. The TV/Non-TV tabs in
Settings > Applications remain inventories of installed apps, independent of
the categories displayed on Home.

Rollback: select the original **FLauncher** in Launcher Manager Mini, or turn
off its custom Home feature to return to the still-enabled Amazon Home.
Neither launcher nor Amazon Home needs to be uninstalled.
