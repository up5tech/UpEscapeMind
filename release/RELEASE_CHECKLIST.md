# Release Checklist — Up Escape Mind 1.1.0 (iOS update)

**Version:** `1.1.0` (build `1`) — `pubspec.yaml` + `ios/Runner.xcodeproj/project.pbxproj`
**Bundle ID:** `com.up5.upescapemind` (unchanged — matches the existing App Store app 1.0)
**Prepared:** 2026-11-24
**Scope of this update:** iOS. Android still uses the same version bump but has not been rebuilt here.

## Code, content & tests

- [x] Version bumped to 1.1.0+1; Xcode `MARKETING_VERSION=1.1.0`, `CURRENT_PROJECT_VERSION=1` for Runner (Debug/Profile/Release)
- [x] `flutter analyze` — clean, 0 issues
- [x] `flutter test` — **146/146 passed**
- [x] `python3 tool/validate_art.py` — OK, 5 rooms checked
- [x] Content manifest loads 2 chapters / 8 rooms / 29 puzzles / 9 items / 2 combinations / 40 clues
- [x] Integration journey (`flutter drive` on iPhone 17 Pro simulator, iOS 26.1) — **3/3 passed**: critical path, save/resume, teardown
- [x] Fixed stale integration tap that hit the lock plate instead of the exit door after r2 art changed hotspot layout
- [x] Release notes updated for 1.1.0 (`release/RELEASE_NOTES.md`)

## iOS build status

- [x] Archive created: `build/ios/archive/Runner.xcarchive` (188.1 MB)
- [x] Archive Info.plist verified: `CFBundleShortVersionString=1.1.0`, `CFBundleVersion=1`, `CFBundleIdentifier=com.up5.upescapemind`
- [x] Export compliance: no app-implemented encryption; answered "None of the algorithms mentioned above" and set `ITSAppUsesNonExemptEncryption = false` in `ios/Runner/Info.plist`; verified in the rebuilt archive.
- [x] App icon is branded keyhole art (not Flutter placeholder)
- [ ] **IPA export still blocked:** Apple account is now signed in to Xcode GUI (Personal Team + UP5 TECH Company Limited), but `xcodebuild`/`flutter build ipa` still reports `No Accounts`, no iOS Distribution certificate, and no App Store profile for `com.up5.upescapemind`. The archive has been opened in Xcode Organizer for manual distribution.
- [ ] Launch image is still the 1×1 placeholder — Flutter emits a non-blocking warning; replace if you want a branded launch screen
- [ ] Physical-device smoke test + airplane-mode check before submission

## Environment note

`xcodebuild` on this machine could not resolve the empty `FlutterGeneratedPluginSwiftPackage`
(`sandbox-exec: sandbox_apply: Operation not permitted`). The archive above was produced with
that empty package reference temporarily removed; `ios/Runner.xcodeproj/project.pbxproj` has been
restored to its normal state with the package reference intact. If CLI builds hit the same error,
fix the local sandbox/Xcode setup or build from Xcode GUI/CI.

## Remaining steps for App Store Connect

1. **Commit the working tree** — the r2 art, Chapter 2 metadata, version bump, and test fix are still uncommitted. Build the final archive from a clean commit.
2. **In Xcode → Settings → Accounts**, select the UP5 TECH account and click *Manage Certificates…* → “+” → *iOS Distribution* so a distribution certificate with private key exists. Then click *Download Manual Profiles* (or check *Automatically Manage Signing* in the target).
3. **Distribute the archive** (already opened in Organizer): *Distribute App* → *App Store Connect* → *Upload*. If the team shown differs from `CZJGGG5A9W`, update `DEVELOPMENT_TEAM` in the Runner target before re-archiving.
4. **App Store Connect:** select the existing app → create new version **1.1.0** → upload build `1` → paste notes from `release/RELEASE_NOTES.md` → update screenshots if needed.
5. **Review & submit** for review; verify the build is ready/processed before enabling release.

## Known items for 1.1.0

- No audio bundled (accepted scope).
- RunnerTests bundle ID in Xcode still uses `com.upescapemind.upEscapeMind.RunnerTests`; harmless for release but can be aligned to `com.up5.upescapemind.RunnerTests` later.
- Android 1.1.0 build/signing not part of this iOS update.
