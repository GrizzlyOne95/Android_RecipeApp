# Current Status

This snapshot reflects the repo state on March 15, 2026.

## Alignment Estimate

- The project is currently about 82-89% aligned with the stated Android recipe, pantry, grocery, and nutrition-tracking goals.
- The core local app foundation is strong.
- The biggest remaining gaps are final live cloud validation, demo-device packaging validation, and deeper import/media polish.

## Built And Working

- Local-first app shell with Recipes, Grocery, Pantry, and Food Log tabs
- Drift-backed persistence with seeded data and upgrade-safe migrations
- Recipe CRUD with linked pantry ingredients, nested recipe nutrition, and saved-meal composition
- Recipe import from pasted text, fetched recipe URLs, and screenshot OCR
- Pantry brand and barcode capture
- Camera barcode scanning with Open Food Facts plus USDA fallback nutrition import
- Pantry product image persistence for imported item artwork
- Pantry photo import from gallery or camera with local-device persistence
- Universal Quick Add for grocery, pantry, and food-log entry
- Grocery list generation plus manual add/edit flows
- Food-log goals, entry logging, and saved-meal logging
- Food-log macro-aware suggestions using saved meals, recipes, and pantry items
- Reusable Food-log day plans that can be saved from logged entries and replayed into today
- Direct create/edit day-plan flow using saved meals, recipes, and pantry items before anything is logged
- Weekly meal-plan boards with scheduled day slots, mixed source entries, and pin-to-export behavior
- Meal-plan folders / boards with grouped organization and bulk pin-to-grocery behavior
- Calendar-style weekly meal-plan board previews in both the meal-plan cards and meal-plan editor
- Grocery export toggles and generated shopping sections for reusable day plans and pinned meal plans
- Fresh app launches now start from user-created data instead of auto-seeded demo records, with guided empty states for Recipes, Pantry, Grocery, and editable Food Log goals
- Sync queue, Sync Center UI, and optional Firebase Auth + Firestore push scaffolding
- Pull-first cloud merge for recipes, pantry, grocery, saved meals, day plans, meal plans, and food log, with richer Sync Center diagnostics for queue health, recent errors, and merge activity
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
- Pantry items can now keep a manually imported gallery photo or camera photo locally on-device without pushing machine-specific file paths into cloud sync.
- Sync Center now surfaces the latest sync summary, queue age, and recent error/conflict history instead of only the last one-line message.
- The live scanner sheet opens and requests camera permission correctly on emulator.
- The app was rebuilt, reinstalled, and launched successfully on the Android emulator after adding screenshot OCR import dependencies.
- Reusable day plans now persist locally, sync through the same queue/pull-merge path, and can be applied back into today’s Food Log entries.
- Day plans can now be authored directly instead of only being captured from an already-logged day.
- Grocery export can now expand reusable day plans into ingredient shopping sections alongside pinned recipes and saved meals.
- Meal plans now persist locally, sync through the same queue/pull-merge path, and can be pinned into grocery export as weekly planning boards.
- Meal plans can now mix recipes, saved meals, and pantry items across multiple named weekdays inside Food Log.
- Meal plans can now be grouped into named folders/boards, and a whole folder can be pinned or unpinned for grocery export in one action.
- Meal-plan cards and the meal-plan editor now share a weekly board preview so scheduled entries read more like a real planning calendar during demos.
- The real app now uses the current day for Food Log activity and no longer depends on the fixed mock "today" used for deterministic seeded tests.
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
2. Validate full-entity pull/merge plus richer sync diagnostics against real Firebase data on a configured Android device.
3. Build and smoke-test a demo APK on one or more real Android devices.
4. Add richer pantry media handling beyond the first local photo workflow.
5. Continue recipe-import polish with stronger source-specific cleanup and confidence cues.
