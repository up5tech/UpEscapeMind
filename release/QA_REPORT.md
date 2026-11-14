# QA & Performance Report — Up Escape Mind 1.0.0

**Date:** 2026-11-14 · **Version:** 1.0.0+1 · **Scope:** Phase 11 release candidate

## 1. Automated test results

| Suite | Command | Result |
| ----- | ------- | ------ |
| Static analysis | `flutter analyze` | Clean — 0 issues |
| Unit tests | `flutter test` (test/unit, test/data, test/content_validation, test/widget) | **136/136 passed** |
| Content validation | included above + `test/content_validation` | Production `manifest.json` valid; all 52 content files load; solvability test confirms Chapter 1 is completable |
| Integration (device) | `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_journey_test.dart` | **2/2 passed** on iPhone 17 Pro simulator (iOS 26.x) |

### Integration coverage (`integration_test/app_journey_test.dart`)

1. **Critical path** — New Game → prologue (skippable) → Entrance Hall
   hotspots render → tutorial keypad rejects `9999` with feedback and no
   durable change → authored code `1024` solves `puz_eh_door_lock` →
   `room_study` unlocks and its exit hotspot appears → player enters the
   study.
2. **Save/resume** — app restarted over the same on-device database;
   Continue lands directly in `room_study` (not the entrance hall).

Note: test 2 depends on test 1 having run first (same file, sequential).

## 2. Build verification

| Artifact | Command | Result |
| -------- | ------- | ------ |
| Android release APK (fat) | `flutter build apk --release` | ✅ `app-release.apk` — 61.8 MB |
| Android release APKs (per-ABI) | `flutter build apk --release --split-per-abi` | ✅ arm64-v8a 21.6 MB · armeabi-v7a 19.1 MB · x86_64 23.1 MB |
| Android App Bundle | `flutter build appbundle --release` | ⚠️ Gradle build succeeds but Flutter's post-build debug-symbol check fails: `cmdline-tools` (apkanalyzer) not installed in the local Android SDK. Install cmdline-tools or build AAB on CI before Play Store upload. |
| iOS release (unsigned) | `flutter build ios --release --no-codesign` | ✅ `build/ios/iphoneos/Runner.app` — 20.5 MB |

All builds are signed with debug keys locally — configure release
signing before store distribution (see RELEASE_CHECKLIST.md).

## 3. Offline & permissions audit

- `android/app/src/main/AndroidManifest.xml` — **zero** `<uses-permission>`
  entries; INTERNET exists only in `debug`/`profile` manifests (Flutter
  tooling requirement, not shipped in release).
- `ios/Runner/Info.plist` — no privacy-sensitive usage descriptions; the
  app requests no capabilities.
- `pubspec.yaml` — no network packages (no http/dio/etc.); all content,
  art, and strings are bundled assets; saves are local SQLite +
  shared_preferences.
- Content loader reads exclusively from `assets/content/manifest.json`
  (production) — sample/dev content is unreachable in release.

## 4. Performance notes

- Scene art is deliberately small: 5 rooms at 360×640 PNG (~8–12 KB each),
  2 puzzle backdrops (~5 KB), 5 item icons. Total `assets/` ≈ 150 KB —
  negligible memory and decode cost; no texture compression needed.
- Audio directories are empty by design (game ships silent, 1.0.0).
- Integration journey completes in ~6 s on an iPhone 17 Pro simulator,
  including two cold app boots and full content load — no perceptible
  jank observed during automated run.
- Font tree-shaking reduced icon fonts ~99.7% in release builds.

## 5. Manual-play coverage status

- Full-chapter manual playthrough on physical devices: **pending** —
  recommend a device pass before store submission (solvability is covered
  by `test/data/chapter1_solvability_test.dart` and the integration
  critical path).
- Save/restore under interruption: covered by the restart test; low-
  storage scenario not exercised (SQLite writes are small transactions).
- Airplane-mode run: not explicitly executed, but with no INTERNET
  permission and zero network code paths, offline behavior is structural.
  Recommend one manual airplane-mode smoke test on device.

## 6. Known issues / follow-ups

1. Android release signing not configured (debug keys in use).
2. App Bundle post-build check needs Android `cmdline-tools` installed.
3. App icon is the Flutter placeholder — replace before submission.
4. Store screenshots not yet captured (need RC build on device).
5. No audio assets ship in 1.0.0 (accepted scope decision).
6. Physical min-spec device testing outstanding.
