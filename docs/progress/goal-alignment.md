# Goal Alignment

This checklist compares the current repository state to the intended product goals.

Estimated overall alignment: about 82-89%.

## Done

- Android-first app foundation with four main tabs:
  - Recipes
  - Grocery List
  - Pantry
  - Food Log
- Real local persistence through Drift
- Manual recipe creation and editing
- Recipe files with ingredient ordering, directions, scaling, notes, and calorie sorting
- Pantry item saving with brand and barcode fields
- Pantry-backed ingredient linking in recipes
- Nested recipe support, where one recipe can be used as an ingredient in another
- Grocery export and manual grocery additions
- Grocery export from pinned recipes, saved meals, and reusable day plans
- Grocery export from pinned meal plans with mixed recipe, saved-meal, and pantry entries
- Food Log with macro rollups and daily tracking
- Food Log suggestions that rank saved meals, recipes, and pantry items against remaining daily goals
- Editable daily goal targets and create-first empty states so users can validate the data model with their own records instead of relying on seeded demo content
- Reusable day plans that can be saved from logged entries and applied back into the Food Log
- Direct day-plan authoring and editing from Food Log
- Weekly meal-plan boards with scheduled day slots, pinning, and direct editing from Food Log
- Meal-plan folder/board grouping with bulk pin-to-grocery actions
- Calendar-style meal-plan board previews across Food Log cards and the meal-plan editor
- Saved meals with adjustable quantities that do not mutate the master definition
- Recipe variations / version-style duplication flows
- Unit and nutrition math across linked ingredients and scaled recipes
- Favorite notes and saved scale context groundwork in recipe data
- Optional Firebase sync coverage for meal plans alongside recipes, pantry, grocery, saved meals, day plans, and food log

## Partially Done

- Browse and save online recipes:
  - plain text import, fetched URL import, and screenshot OCR import now exist
  - browser-style save/share flows and source-specific cleanup can still be improved
- Barcode pantry workflow:
  - manual barcode entry exists
  - camera scanning and Open Food Facts lookup now import product nutrition into the pantry editor
  - USDA FoodData Central now acts as a branded-food fallback when Open Food Facts misses
- Pantry nutrition auto-fill:
  - barcode-driven nutrition import now works
  - imported product image persistence now works for pantry items
  - manual pantry photo import from gallery/camera now works with local-device persistence
  - richer multi-image media handling is still missing
- Meal planning:
  - pinned/exportable recipe and saved-meal flows exist
  - goal-aware suggestions now exist inside Food Log
  - daily goals can now be edited directly in-app
  - reusable day plans now exist inside Food Log
  - weekly meal plans now exist with mixed recipe, saved-meal, and pantry scheduling
  - meal plans can now be grouped into named folders/boards with bulk grocery pinning
  - calendar-style weekly board previews now make those plans readable as visual planning boards
  - day plans and pinned meal plans now feed the grocery export pipeline
  - deeper categorization, drag/drop planning, and more advanced organization are still missing
- Master recipe change propagation:
  - the data model supports dependency-aware nutrition behavior
  - the full user-facing confirmation and update UX can still be improved
- Firebase sync:
  - queue, Sync Center, Firestore push, and pull-merge coverage for recipes, pantry, grocery, saved meals, day plans, meal plans, and food log now exist
  - Sync Center now includes queue-health and recent error/conflict diagnostics
  - live sign-in and real Firebase validation still depend on console setup

## Not Yet Done

- Advanced categorization and organizational views beyond the current foundation
- Real-device demo packaging and signed distribution workflow
## Recommended Next Steps

1. Finish Firebase console enablement and validate real Android sign-in plus Firestore push.
2. Validate full-entity pull/merge plus conflict behavior against real Firebase data after live sync is confirmed.
3. Build and smoke-test a demo APK on one or more real Android devices.
4. Expand pantry media handling beyond the first local photo flow, then polish recipe import further.
5. Add richer planning organization and categorization views on top of the current meal-plan foundation.

## Why This Order

- Barcode and nutrition import directly unlock one of the most distinctive parts of the product vision.
- Recipe import now covers the core ingestion paths, and sync now has full local entity pull/merge coverage across the main planning entities, so the next leverage point is validating and polishing that sync behavior with real Firebase data.
- Real-world sync validation should come before any trust-sensitive shared-demo messaging so planning and grocery data stays believable.
- The weekly meal-plan layer now has a first visual board treatment, and the live app now starts from user-created data, which shifts the remaining planning work toward polish and categorization rather than brand-new infrastructure.
