# Release Checklist — Up Escape Mind 1.0.0

Version: `1.0.0+1` (pubspec.yaml)
Target platforms: Android, iOS — portrait-first, fully offline.

## Code & content gates

- [x] `flutter analyze` — clean, no issues
- [x] `flutter test` — all unit, widget, content-validation, and solvability tests pass (136 tests)
- [x] `flutter test integration_test/app_journey_test.dart` — written; verified via `flutter drive` on iPhone 17 Pro simulator (2/2 pass). `flutter test -d` on-device path hits a local WebSocket issue; Android emulator on this machine is unstable — rerun on CI/physical device.
- [x] Content validation — production `manifest.json` covers Chapter 1 only; sample/dev content unreachable
- [x] Localization — complete vi + en string sets (269 content strings each, plus arb UI strings)
- [x] No placeholders or fake success paths in release paths
- [x] In-app Credits screen expanded (art/audio/tech sections + open-source licenses page)

## Platform gates

- [x] Android manifest — no permissions in `src/main` (INTERNET only in debug/profile manifests, required by Flutter tooling)
- [x] iOS `Info.plist` — no privacy-sensitive usage descriptions required (no camera/photos/mic/etc.)
- [x] Offline-first — no network dependencies on the critical path; all content/art bundled as assets
- [ ] Android release signing — **release build currently signed with debug keys**; configure a real keystore before store upload
- [ ] Android App Bundle — `flutter build appbundle` fails its debug-symbol check because `cmdline-tools`/`apkanalyzer` is missing from the local SDK; install cmdline-tools or produce the AAB on CI
- [ ] iOS distribution signing & provisioning — build with `--no-codesign` locally; archive via Xcode/Codemagic for App Store
- [ ] Physical-device smoke test on min-spec Android + iPhone (see QA_REPORT.md for simulator coverage)

## Assets

- [x] Scene art: 5 rooms + 2 puzzle backdrops, 360×640 PNG, ~70 KB total
- [x] Item icons: 5 production items
- [x] License ledger: `assets/licenses/README.md` — all shipped art is project-owned original IP
- [ ] App icon review — current icons are the Flutter default placeholder; replace with final branded icon before store submission
- [ ] Store screenshots — capture on release-candidate build (6.7" + 6.5" iPhone, Android phone + 7"/10" tablet optional)
- [ ] Fonts — currently system default; `assets/fonts/` is empty pending licensed font decision (see license ledger)

## Release artifacts

- [x] Android release APKs: fat 61.8 MB; per-ABI 19.1–23.1 MB (`build/app/outputs/flutter-apk/`)
- [x] iOS release build: `build/ios/iphoneos/Runner.app` (20.5 MB, unsigned)
- [x] Release notes: `release/RELEASE_NOTES.md`
- [x] Store listing copy: `release/STORE_LISTING.md`
- [x] Credits: `release/CREDITS.md`
- [x] QA & performance report: `release/QA_REPORT.md`

## Known limitations (documented, accepted for 1.0.0)

- Game ships silent — `assets/audio/` is empty; audio settings toggles exist but no audio assets are bundled yet (Phase 10 scope).
- Sample/dev content files (`*_sample*`) remain in `assets/` for tests but are not referenced by the production manifest.
- Debug-signed Android release APK is suitable for internal RC distribution only.
