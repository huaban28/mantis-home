# Mantis Home

An offline FLauncher fork tested on **Fire TV Stick 4K, first generation
(2018), AFTMM / mantis**, Fire OS 6.7.1.1 (NS6711), Android 7.1.2 / SDK 25.
This is not the older non-4K Fire TV Stick, nor the 4K Max.

Based on [Zomp's FLauncher](https://github.com/zompinc/flauncher), commit
`9188d9b41bcb57f07c5c47c456ed74f073e56ea0`, derived from
[FLauncher](https://gitlab.com/flauncher/flauncher). Copyrights and the
[GPL-3.0 license](LICENSE) are retained. See [the upstream README](UPSTREAM_README.md).
This is independent of Amazon and CleanYourTV.

## Mantis changes

- CPU and used/total memory in the toolbar, sampled only while foreground.
- Network settings and app input-service shortcuts. Physical HDMI source
  selection belongs to the television remote; a Stick has no HDMI inputs.
- Long Select/OK opens the menu even without repeated key events. A short
  release launches once; release after a hold does not also launch.
- **Add to category** permits multiple home categories; **Move to category**
  leaves the app only in the chosen category and restores its visibility.
- **Hide everywhere** explicitly names global hiding. Settings > Applications
  remains an installed-app inventory, separate from home categories.

Package: `me.efesser.flauncher.mantis`; minimum SDK remains 21. No new
permissions or dependencies were added for these features. The inherited offline
fork has no INTERNET permission. Local wallpapers and manual ordering remain.

## Build

See [MANTIS_BUILD.md](MANTIS_BUILD.md) for pinned tools and build commands.
No APKs or signing keys are distributed. Build your own APK and keep its signing
key private; updates require the same key as the installed application. This
development release configuration uses a local Android debug key, not a
production signing setup. The inherited tag-release workflow is not the build
procedure for this Mantis variant; no automated Mantis release is offered.

For installation use authorized Python ADB from
[CleanYourTV](https://github.com/Gathin23/cleanyourtv)'s `tools/tv.py`.
Do not lower another launcher's minimum SDK or bypass installation refusals.
Keep Amazon Home enabled and verify the new launcher before setting up helpers.

## Home and HDMI return

Mantis Home does not intercept Home itself. On the tested unit, **Launcher
Manager Mini V2** targeted Mantis Home with **ActivityManager** selected and
**Launch on Boot** enabled. The owner verified one physical Home press from a
regular app and switching the Samsung television to another HDMI source and back.
Both returned to Mantis Home. Reboot persistence was not tested.

The helper is a separate third-party app by SweenWolf:
[developer's XDA thread](https://xdaforums.com/t/app-firetv-noroot-launcher-manager-change-launcher-without-root.4176349/).
No helper APK is redistributed. Obtain it from its developer and assess its
permissions separately. The tested setup used READ_LOGS, overlay and usage
access, plus a battery-optimization exemption, without WRITE_SECURE_SETTINGS.
Those let the helper observe system/app activity and act across apps; they are
not Mantis Home permissions. Firmware and helper versions can change results.
Do not disable protected Amazon packages or bypass a refusal.

Rollback: select the previous launcher in the helper, or turn its custom Home
feature off to return to the still-enabled Amazon Home. Neither requires an
uninstall. Verify actual Home with the physical remote.

## Verification and troubleshooting

Version **0.18.0-mantis.4 (147)** passed **125 Flutter tests**, was built and
installed on the device above. Physical remote checks covered single Home,
HDMI return, long OK/Reorder and YouTube/Netflix opening. Category moves were
checked through the installed UI and acknowledged by the owner. No screenshots
were requested on this device and no private device data is published.

Some fresh Python ADB connections closed before authentication, including
Windows errors 10053/10054. Toggling ADB debugging on the device restored access
during the session; one authenticated connection then handled related operations.
The root cause is unproven: screenshots and firmware age were not established
as causes. Manual app installation working does not prove ADB transport is healthy.
Avoid reconnect loops and stop on permission or compatibility refusals.

An Appstore download listing does not necessarily mean the app is installed.
After installation, use Settings > Applications to add it to a home category.
For existing tools: **long OK > Move to category > Tools**. The inventory's TV
tab will still list TV-capable tools; it is not the TV Applications home category.

---

The remaining text describes the upstream project and its original screenshots.

> **Zomp fork of FLauncher.** This is a modified version of
> [FLauncher](https://gitlab.com/flauncher/flauncher) (GPL-3.0), maintained by
> [Zomp](https://zomp.com) as a default Android TV home launcher.
>
> Changes from upstream 0.18.0 (2026-07):
> - **Pointer / mouse support** — app cards respond to mouse hover (focus) and
>   click (launch), so air-mouse remotes work. Offered back upstream.
> - **Firebase removed** — Crashlytics, Analytics and Remote Config stripped, so
>   the launcher runs fully offline with no telemetry (it targets an
>   offline-first, privacy-focused Android TV appliance). As a consequence,
>   Unsplash online wallpaper browsing is disabled; local wallpapers and
>   gradients are unaffected.
>
> Licensed under GPL-3.0, the same as upstream — see [LICENSE](LICENSE).

---

# FLauncher
FLauncher is an open-source alternative launcher for Android TV, built with [Flutter](https://flutter.dev).

The project is still at an early development stage and may be unstable. It currently lacks testing on real devices and has only been tested on Chromecast with Google TV.

<a href="https://play.google.com/store/apps/details?id=me.efesser.flauncher">
 <img alt="Get it on Google Play" width="200" src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"/>
</a>

## Features
- [x] No ads
- [x] Customizable categories
- [x] Manually reorder apps within categories
- [x] Wallpaper support
- [x] Open "Android Settings"
- [x] Open "App info"
- [x] Uninstall app
- [x] Clock
- [x] Switch between row and grid for categories
- [x] Support for non-TV (sideloaded) apps
- [x] Navigation sound feedback
- [ ] Force stop app

## Screenshots
|  |  |  |
|--|--|--|
| ![](screenshots/Screenshot_1624378896.png) | ![](screenshots/Screenshot_1624378921.png) | ![](screenshots/Screenshot_1624378938.png) |

## Set FLauncher as default launcher

### Method 1: remap the Home button
This is the "safer" and easiest way. Use [Button Mapper](https://play.google.com/store/apps/details?id=flar2.homebutton) to remap the Home button of the remote to launch FLauncher.

### Method 2: disable the default launcher
**:warning: Disclaimer :warning:**

**You are doing this at your own risk, and you'll be responsible in any case of malfunction on your device.**

The following commands have been tested on Chromecast with Google TV only. This may be different on other devices.

Once the default launcher is disabled, press the Home button on the remote, and you'll be prompted by the system to choose which app to set as default.

#### Disable default launcher
```shell
# Disable com.google.android.apps.tv.launcherx which is the default launcher on CCwGTV
$ adb shell pm disable-user --user 0 com.google.android.apps.tv.launcherx
# com.google.android.tungsten.setupwraith will then be used as a 'fallback' and will automatically
# re-enable the default launcher, so disable it as well
$ adb shell pm disable-user --user 0 com.google.android.tungsten.setupwraith
```

#### Re-enable default launcher
```shell
$ adb shell pm enable com.google.android.apps.tv.launcherx
$ adb shell pm enable com.google.android.tungsten.setupwraith
```

#### Known issues
On Chromecast with Google TV (maybe others), the "YouTube" remote button will stop working if the default launcher is disabled. As a workaround, you can use [Button Mapper](https://play.google.com/store/apps/details?id=flar2.homebutton) to remap it correctly.

## Wallpaper
Because Android's `WallpaperManager` is not available on some Android TV devices, FLauncher implements its own wallpaper management method.

Please note that changing wallpaper requires a file explorer to be installed on the device in order to pick a file.

<a href="https://www.buymeacoffee.com/etienn01" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="200"></a>
