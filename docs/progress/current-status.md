# Current Status

This snapshot reflects the repo state on March 14, 2026.

## Alignment Estimate

- The project is currently about 70-80% aligned with the stated Android recipe, pantry, grocery, and nutrition-tracking goals.
- The core local app foundation is strong.
- The biggest remaining gaps are richer planning depth, smarter cloud sync diagnostics, and final live cloud validation.

## Built And Working

- Local-first app shell with Recipes, Grocery, Pantry, and Food Log tabs
- Drift-backed persistence with seeded data and upgrade-safe migrations
- Recipe CRUD with linked pantry ingredients, nested recipe nutrition, and saved-meal composition
- Recipe import from pasted text, fetched recipe URLs, and screenshot OCR
- Pantry brand and barcode capture
- Camera barcode scanning with Open Food Facts plus USDA fallback nutrition import
- Pantry product image persistence for imported item artwork
- Universal Quick Add for grocery, pantry, and food-log entry
- Grocery list generation plus manual add/edit flows
- Food-log goals, entry logging, and saved-meal logging
- Food-log macro-aware suggestions using saved meals, recipes, and pantry items
- Reusable Food-log day plans that can be saved from logged entries and replayed into today
- Direct create/edit day-plan flow using saved meals, recipes, and pantry items before anything is logged
- Grocery export toggles and generated shopping sections for reusable day plans
- Sync queue, Sync Center UI, and optional Firebase Auth + Firestore push scaffolding
- Pull-first cloud merge for recipes, pantry, grocery, saved meals, day plans, and food log, with conflict summaries in Sync Center
- Firebase project binding for `nutrichef-recipeapp-6d24f`
- Secret-bearing Firebase API keys and config artifacts are intentionally kept out of Git

## Verified

- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- Android emulator smoke test across Recipes, Grocery, Pantry, Food Log, Quick Add, pantry barcode import, reusable day-plan UI, and post-OCR-plugin app launch

## Validation Notes

- The pantry barcode import flow was verified end to end on the Android emulator using a real Open Food Facts lookup.
- USDA FoodData Central is now wired as a branded-food fallback when Open Food Facts misses a barcode.
- Imported pantry product images now persist on the item record and render back on pantry cards and in the editor.
- The live scanner sheet opens and requests camera permission correctly on emulator.
- The app was rebuilt, reinstalled, and launched successfully on the Android emulator after adding screenshot OCR import dependencies.
- Reusable day plans now persist locally, sync through the same queue/pull-merge path, and can be applied back into today’s Food Log entries.
- Day plans can now be authored directly instead of only being captured from an already-logged day.
- Grocery export can now expand reusable day plans into ingredient shopping sections alongside pinned recipes and saved meals.
- A real Android device is still needed for final live-camera barcode validation because the emulator camera backend did not provide a reliable preview stream.

## In Progress

- Firebase console enablement for live sign-in and Firestore access
- Real-device validation of full Firebase sync after console setup

## Manual Steps Still Required

- Enable Google sign-in in Firebase Auth
- Add Android SHA fingerprints for `com.istuart.recipeapp`
- Enable Cloud Firestore for `nutrichef-recipeapp-6d24f`
- Provide the remaining OAuth client ids:
  - `FIREBASE_ANDROID_API_KEY`
  - `FIREBASE_WEB_CLIENT_ID`
  - `FIREBASE_IOS_API_KEY`
  - `FIREBASE_IOS_CLIENT_ID`
- Validate iOS Google sign-in later on a Mac/Xcode machine

## Safe Multi-PC Workflow

- Sync code and docs through Git as usual
- Keep real Firebase values in a local `firebase.local.json` on each machine
- Start Firebase-enabled runs with `pwsh -File .\scripts\flutter_with_local_firebase.ps1`
- Keep downloaded Firebase config files local and untracked

## Next Development Slice

1. Validate real Android sign-in and Firestore push once console setup is complete.
2. Validate full-entity pull/merge, now including day plans, on a real Android device once console setup is complete.
3. Expand planning from reusable day plans into richer mixed meal-plan assemblies, planning views, and schedule-oriented organization.
4. Add pantry item photo import and richer imported-product image handling.
5. Polish recipe import with more source-specific cleanup and confidence cues where parsing is uncertain.
