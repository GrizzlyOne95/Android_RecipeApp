# Windows Mobile Workstation Setup

This document records the working mobile setup on `C:\Users\istuart\Documents\GIT\Android_RecipeApp` as of March 13, 2026.

## Machine State

- OS: Windows 11 Pro 25H2
- Java: Temurin OpenJDK 21.0.7
- Android Studio: `C:\Program Files\Android\Android Studio`
- Android SDK: `C:\Users\istuart\AppData\Local\Android\Sdk`
- Flutter SDK: `C:\Users\istuart\develop\flutter`
- Flutter version: `3.41.4`
- Dart version: `3.11.1`
- Node.js: `v22.19.0`
- npm: `10.9.3`
- Firebase CLI: installed globally via npm
- FlutterFire CLI: installed via Dart pub global activate
- Verified Android emulator: `NutriChef_Emulator`

## User Environment Variables

These were added to the user profile:

- `ANDROID_HOME=C:\Users\istuart\AppData\Local\Android\Sdk`
- `ANDROID_SDK_ROOT=C:\Users\istuart\AppData\Local\Android\Sdk`

The user `Path` includes:

- `C:\Users\istuart\develop\flutter\bin`
- `C:\Users\istuart\AppData\Local\Android\Sdk\platform-tools`
- `C:\Users\istuart\AppData\Local\Android\Sdk\emulator`
- `C:\Users\istuart\AppData\Local\Android\Sdk\cmdline-tools\latest\bin`
- `C:\Users\istuart\AppData\Local\Pub\Cache\bin`
- `C:\Users\istuart\AppData\Roaming\npm`

Open a new terminal after applying environment-variable changes.

## What Was Installed Or Verified

1. Verified Android Studio and Android SDK were already present.
2. Installed Flutter SDK by cloning the stable channel to `C:\Users\istuart\develop\flutter`.
3. Downloaded and installed Android command-line tools under `C:\Users\istuart\AppData\Local\Android\Sdk\cmdline-tools\latest`.
4. Accepted Android SDK licenses.
5. Verified `flutter doctor -v` returned no issues.
6. Installed `firebase-tools` globally with npm.
7. Installed `flutterfire_cli` with Dart pub.
8. Booted and verified the Android emulator with `adb devices`.

## Recreate On Another Windows Workstation

1. Install Android Studio.
2. Install an Android SDK with emulator, platform-tools, system images, and at least one AVD.
3. Install Java 21 if Android Studio does not already provide a suitable JBR or JDK.
4. Install Node.js.
5. Clone Flutter stable to a path without spaces, for example:

```powershell
git clone https://github.com/flutter/flutter.git -b stable C:\Users\<you>\develop\flutter
```

6. Download Android command-line tools and place them at:

```text
<Android SDK>\cmdline-tools\latest
```

7. Add these to the user environment:

```text
ANDROID_HOME=<Android SDK path>
ANDROID_SDK_ROOT=<Android SDK path>
Path += flutter\bin
Path += <Android SDK>\platform-tools
Path += <Android SDK>\emulator
Path += <Android SDK>\cmdline-tools\latest\bin
Path += %LOCALAPPDATA%\Pub\Cache\bin
Path += %APPDATA%\npm
```

8. Accept Android licenses:

```powershell
flutter doctor --android-licenses
```

9. Install Firebase tooling:

```powershell
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

10. Verify the environment:

```powershell
flutter doctor -v
adb devices
emulator -list-avds
```

## Daily Commands

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run -d emulator-5554
```

## Important Constraint

iPhone simulator testing cannot be done from this Windows machine. The shared Flutter codebase is iOS-ready, but iOS build verification will require a Mac with Xcode later.

## Deferred Manual Steps

- `firebase login`
- `flutterfire configure`
- Apple signing, bundle identifiers, and iOS simulator or device setup on a Mac
