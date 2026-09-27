# don-campground modern relay bundle

Modernization of Bale's `campground.ash` without changing its basic purpose.

## Install in KoLmafia

From the KoLmafia gCLI:

```text
git checkout donCannoli-burns/don-campground
```

KoLmafia recognizes the repository-root `relay/` directory and copies those files into its live `relay/` directory. The included `dependencies.txt` declares `Ezandora/Choice-Override`; when KoLmafia's `gitInstallDependencies` preference is enabled, it will install that dependency automatically if it is not already installed.

Updates can be pulled with:

```text
git update don-campground
```

To remove the installed project:

```text
git delete don-campground
```

## What changed

- Keeps native KoLmafia relay overrides for `campground.php`; current KoLmafia still supports them.
- Uses KoLmafia's current workshed-specific relay dispatch (`campground.workshed.<item-id>.ash|js`) for appliance-page enhancements, while the workshed replacement selector stays on the main campground page.
- Replaces the old undocumented `campground.php?action=workshed&remodel=...` + hand-built `inv_use.php` call with `get_workshed()` and `use(1, item)`.
- Updates the workshed registry through current `CampgroundRequest` entries, including Cold Medicine Cabinet, Model Train Set, and TakerSpace letter of Marque.
- Adds a Model Train Set Choice-Override handler for choice **1485**.
- Adds `campground.workshed.11045.ash` for Model Train Set status enhancement; the replacement selector remains on `campground.php`.
- Preserves the old telescope annotations, bookshelf summon counters, Trendy cleanup, garden switcher, and DNA hybrid annotations.
- Adds a quick familiar selector to the **top of `campground.php`**. The terrarium is read server-side only to discover currently-selectable familiars; the visible form posts back to `campground.php`, where ASH calls `use_familiar()` and verifies `my_familiar()` before re-rendering the campground.
- Modernizes the garden switcher to use item installation rather than the old `remodel=` URL.

## Files

Copy the contents of `relay/` into KoLmafia's `relay/` directory:

- `campground.ash`
- `campground.workshed.ash`
- `campground.workshed.11045.ash`
- `choice.1485.js`
- `don-campground-common.ash`

`src/choice.1485.ts` is optional maintainable TypeScript source. KoLmafia runs the checked-in JavaScript file directly.

## Choice-Override dependency

`choice.1485.js` follows the supplied Choice-Override contract and requires its `relay/choice.ash` multiplexer/helper.

The model-train workshed bridge does **not** require Choice-Override to render the train status panel; it exists because KoLmafia dispatches a workshed-specific relay override before the model train redirects into choice 1485.

## Verification

Before live use, run KoLmafia's installed-runtime checks rather than trusting static documentation:

```text
verify relay/campground.ash
verify relay/campground.workshed.ash
ashref get_workshed
ashref use
```

Then test read-first in Relay:

1. Open the base campground and confirm telescope/garden UI still renders.
2. Confirm the Quick familiar selector appears at the top of the main campground page.
3. Confirm the garden and workshed switchers appear at the bottom of the campground pane, below the native campsite content.
4. Open a non-train workshed and confirm the workshed switcher is **not** injected there.
5. Do **not** submit a workshed replacement until you intend to consume the one-per-day replacement.
6. Open a Model Train Set workshed and confirm the train page remains functional and only the train-status enhancement appears.
7. Open/refresh choice 1485 directly and confirm `choice.1485.js` does not duplicate or break the native train controls.
8. Use the campground Quick familiar dropdown once and confirm the familiar changes while the browser remains on `campground.php`.

All three campground control panels use the same green garden-panel styling and uniform select widths.

## Important behavior

Replacing a workshed item is a real game mutation and is intentionally behind an explicit form submission plus browser confirmation. The script checks `_workshedItemUsed`, validates the selected item against the current workshed registry, calls `use(1, item)`, and verifies the resulting `get_workshed()` value before reporting success.

## Deliberately not recreated

The legacy source imported `c2t_takerSpace_relay.ash`, but the supplied file did not call any symbol from it and its source was not supplied. This bundle therefore does not invent or reconstruct that external script's behavior.
