# Goal Alignment

This checklist compares the current repository state to the intended product goals.

Estimated overall alignment: about 70-80%.

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
- Food Log with macro rollups and daily tracking
- Food Log suggestions that rank saved meals, recipes, and pantry items against remaining daily goals
- Reusable day plans that can be saved from logged entries and applied back into the Food Log
- Direct day-plan authoring and editing from Food Log
- Saved meals with adjustable quantities that do not mutate the master definition
- Recipe variations / version-style duplication flows
- Unit and nutrition math across linked ingredients and scaled recipes
- Favorite notes and saved scale context groundwork in recipe data

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
  - richer manual photo capture and media handling are still missing
- Meal planning:
  - pinned/exportable recipe and saved-meal flows exist
  - goal-aware suggestions now exist inside Food Log
  - reusable day plans now exist inside Food Log
  - day plans now feed the grocery export pipeline
  - richer visual meal-plan folder UX is still missing
- Master recipe change propagation:
  - the data model supports dependency-aware nutrition behavior
  - the full user-facing confirmation and update UX can still be improved
- Firebase sync:
  - queue, Sync Center, Firestore push, and pull-merge coverage for recipes, pantry, grocery, saved meals, day plans, and food log now exist
  - live sign-in and real Firebase validation still depend on console setup

## Not Yet Done

- Manual pantry photo capture/import beyond remote product artwork
- Rich meal-plan folders with strong visual organization
- Advanced categorization and organizational views beyond the current foundation
## Recommended Next Steps

1. Finish Firebase console enablement and validate real Android sign-in plus Firestore push.
2. Validate full-entity pull/merge plus conflict behavior against real Firebase data after live sync is confirmed.
3. Build the higher-level planning layer beyond today’s reusable day plans:
   meal-plan folders, mixed recipe-plus-ingredient meal assemblies, schedule views, and richer planning organization.
4. Add richer pantry media handling such as manual photo capture and local image management.
5. Polish recipe import with stronger cleanup, confidence hints, and source-specific extraction rules.

## Why This Order

- Barcode and nutrition import directly unlock one of the most distinctive parts of the product vision.
- Recipe import now covers the core ingestion paths, and sync now has full local entity pull/merge coverage, so the next leverage point is validating it against live Firebase data and then building planning on top of that data.
- Real-world sync validation should come before more advanced planning so shared data stays trustworthy.
- The first goal-aware suggestion layer and reusable day-plan layer are now in place, and richer meal planning will work better once the pantry, recipe, and food-log inputs are easier to populate accurately.
