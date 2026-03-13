# Recipe App

Cross-platform recipe, pantry, grocery, and nutrition tracking app built with Flutter for Android first and iOS-ready architecture.

## Current State

This repository now includes:

- A working Flutter project scaffold for Android and iOS.
- A real local SQLite database layer implemented with Drift.
- Android emulator-ready local setup on this Windows workstation.
- An adaptive mobile shell with the four primary tabs:
  - Recipes
  - Grocery List
  - Pantry
  - Food Log
- Seed product architecture and setup documentation for reproducing the environment on another machine.

## Product Direction

The initial architecture is being built around these principles:

- Local-first storage so the app works without an account.
- Optional Google sign-in for sync and backup.
- Android and iPhone support from one shared codebase.
- Phone and tablet responsive layouts.
- Nutrition tracking that covers calories, protein, carbs, fat, fiber, sodium, and sugar.

## Run The App

Open a new terminal after the environment-variable changes, then run:

```powershell
flutter pub get
flutter run -d emulator-5554
```

If you need to boot the Android emulator first:

```powershell
emulator -avd NutriChef_Emulator
```

## Key Docs

- [Windows workstation setup](./docs/setup/windows-mobile-workstation.md)
- [Product and architecture foundation](./docs/architecture/product-foundation.md)

## Near-Term Build Plan

1. Add CRUD flows and forms on top of the local database.
2. Add optional Firebase auth and cloud sync.
3. Add barcode scanning and nutrition import.
4. Add recipe import from URL, text, and OCR screenshots.
5. Add cascading nutrition recalculation for nested recipes and saved meals.
