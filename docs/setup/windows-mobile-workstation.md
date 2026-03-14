# Windows Mobile Workstation Setup

This document records the working mobile setup on `C:\Users\iestu\Documents\GIT\Android_RecipeApp` as of March 14, 2026.

## Machine State

- OS: Windows 11 Pro 25H2
- Java: Temurin OpenJDK 21.0.10
- Android Studio: not required for the verified Android workflow on this profile
- Android SDK: `C:\Users\istuart\AppData\Local\Android\Sdk`
- Android SDK: `C:\Users\iestu\AppData\Local\Android\Sdk`
- Flutter SDK: `C:\Users\iestu\develop\flutter`
- Flutter version: `3.41.4`
- Dart version: `3.11.1`
- Node.js: `v22.22.0`
- npm: `10.9.4`
- Node install path: `C:\Users\iestu\Tools\nodejs`
- JDK path: `C:\Users\iestu\Tools\jdk-21`
- Firebase CLI: `15.10.0`
- FlutterFire CLI: installed via Dart pub global activate
- Verified Android emulator: `NutriChef_Emulator`

## User Environment Variables

These were added to the user profile:

- `ANDROID_HOME=C:\Users\iestu\AppData\Local\Android\Sdk`
- `ANDROID_SDK_ROOT=C:\Users\iestu\AppData\Local\Android\Sdk`
- `JAVA_HOME=C:\Users\iestu\Tools\jdk-21`

The user `Path` includes:

- `C:\Users\iestu\Tools\jdk-21\bin`
- `C:\Users\iestu\develop\flutter\bin`
- `C:\Users\iestu\Tools\nodejs`
- `C:\Users\iestu\AppData\Local\Android\Sdk\platform-tools`
- `C:\Users\iestu\AppData\Local\Android\Sdk\emulator`
- `C:\Users\iestu\AppData\Local\Android\Sdk\cmdline-tools\latest\bin`
- `C:\Users\iestu\AppData\Local\Pub\Cache\bin`
- `C:\Users\iestu\AppData\Roaming\npm`

Open a new terminal after applying environment-variable changes.

## What Was Installed Or Verified

1. Verified the existing Android SDK, emulator packages, and system images.
2. Installed Flutter stable by cloning to `C:\Users\iestu\develop\flutter`.
3. Downloaded and installed Android command-line tools under `C:\Users\iestu\AppData\Local\Android\Sdk\cmdline-tools\latest`.
4. Installed Node.js 22 as a user-local zip to `C:\Users\iestu\Tools\nodejs`.
5. Installed Temurin JDK 21 as a user-local zip to `C:\Users\iestu\Tools\jdk-21`.
6. Configured Flutter to use that JDK with `flutter config --jdk-dir="C:\Users\iestu\Tools\jdk-21"`.
7. Accepted Android SDK licenses.
8. Installed `firebase-tools` globally with npm.
9. Installed `flutterfire_cli` with Dart pub.
10. Created and boot-verified the Android emulator `NutriChef_Emulator`.
11. Verified the repo with `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, `flutter test`, and `flutter run -d emulator-5554 --no-resident`.

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
JAVA_HOME=<JDK 21 path>
Path += flutter\bin
Path += <JDK 21>\bin
Path += <Node.js path>
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

11. If Flutter is picking up the wrong JDK, point it at Java 21:

```powershell
flutter config --jdk-dir="<JDK 21 path>"
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

- Enable Google sign-in and Cloud Firestore in Firebase project `nutrichef-recipeapp-6d24f`
- Add Android SHA fingerprints for `com.istuart.recipeapp`
- Refresh remaining OAuth client ids for Google sign-in wiring
- Apple signing, bundle identifiers, and iOS simulator or device setup on a Mac

## Non-Blocking Note

`flutter doctor -v` still reports missing Visual Studio C++ components for Windows desktop development on this profile. That does not block Android development or this repo's current mobile workflow.
