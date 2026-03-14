# Goal Alignment

This checklist compares the current repository state to the intended product goals.

Estimated overall alignment: about 65-75%.

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
- Food Log with macro rollups and daily tracking
- Saved meals with adjustable quantities that do not mutate the master definition
- Recipe variations / version-style duplication flows
- Unit and nutrition math across linked ingredients and scaled recipes
- Favorite notes and saved scale context groundwork in recipe data

## Partially Done

- Browse and save online recipes:
  - plain text recipe import groundwork exists
  - full online URL import and browser-style save flow is still incomplete
- Barcode pantry workflow:
  - manual barcode entry exists
  - camera scanning and Open Food Facts lookup now import product nutrition into the pantry editor
- Pantry nutrition auto-fill:
  - barcode-driven nutrition import now works
  - item image persistence and richer imported-product media handling are still missing
- Meal planning:
  - pinned/exportable recipe and saved-meal flows exist
  - richer visual meal-plan folder UX is still missing
- Master recipe change propagation:
  - the data model supports dependency-aware nutrition behavior
  - the full user-facing confirmation and update UX can still be improved
- Firebase sync:
  - queue, Sync Center, and project scaffolding exist
  - live sign-in and Firestore validation still depend on console setup

## Not Yet Done

- Auto-import of pantry item pictures
- Strong online recipe URL import flow
- OCR screenshot recipe import flow
- Suggested meals from your own data to help hit macro targets
- Rich meal-plan folders with strong visual organization
- Advanced categorization and organizational views beyond the current foundation
- Cloud pull / merge / conflict handling

## Recommended Next Steps

1. Finish Firebase console enablement and validate real Android sign-in plus Firestore push.
2. Expand recipe import into URL and OCR flows to cover the “browse and save recipes” goal.
3. Add cloud pull, merge, and conflict handling after live sync is confirmed.
4. Build the higher-level planning layer:
   meal-plan folders, mixed recipe-plus-ingredient meal assemblies, and macro-aware meal suggestions.
5. Add pantry item image persistence on top of the new barcode import flow.

## Why This Order

- Barcode and nutrition import directly unlock one of the most distinctive parts of the product vision.
- Recipe import is the next biggest usability win for getting real data into the app quickly.
- Cloud pull/merge should come after basic cloud push is validated so the sync model stays understandable.
- Macro suggestions and richer meal planning will work better once the pantry, recipe, and food-log inputs are easier to populate accurately.
