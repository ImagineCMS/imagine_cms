---
version: alpha
name: Imagine CMS
description: >-
  Quiet Studio chrome for a versioned content management system. Near-monochrome
  cool-neutral surfaces recede so content reads true; a two-temperature state
  system (warm = draft/pinned/yours, cool = published/live) carries the only
  personality. Product register, WCAG AA.
colors:
  # ── Brand anchor: near-black ink. Primary text + primary action fill. ──
  primary: "#1A1D21"
  primary-hover: "#2E333A"
  primary-active: "#111316"
  on-primary: "#FFFFFF"    # text on near-black fills (= focus ring color too)
  # ── Chrome: cool-neutral, the honest backdrop ──
  bg: "#F6F7F9"            # page background
  surface: "#FFFFFF"       # raised surfaces, cards
  fill: "#EDEFF2"          # tonal fill: secondary buttons, hover washes
  fill-hover: "#E3E6EA"
  fill-pressed: "#D4D8DE"
  border: "#E3E6EA"        # default hairline border / divider
  border-strong: "#D4D8DE" # stronger border / pressed edge
  text-muted: "#6B7178"    # secondary text — 4.9:1 on surface
  text-meta: "#6F757C"     # metadata, mono face — 4.6:1 on surface (AA for 11px)
  # ── State: draft + pinned (warm marigold) ──
  draft: "#F59E0B"         # markers, dots, sketch stroke — shape only, never small text
  draft-ink: "#9A5B08"     # accent-colored TEXT on draft-wash (AA, 4.9:1)
  draft-wash: "#FEF3E2"    # solid composite of marigold @12% on white
  pinned: "#F59E0B"        # solid pin dot, same family as draft
  # ── State: published (cool teal) ──
  published: "#2F6B5E"
  published-wash: "#EAF0EF" # solid composite of teal @10% on white
  # ── Destructive: true red, kept clear of marigold ──
  danger: "#B42318"
  danger-wash: "#F9EDEC"   # solid composite of red @8% on white
typography:
  display:                 # screen titles
    fontFamily: Inter
    fontSize: 22px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: -0.01em
  title:                   # section titles
    fontFamily: Inter
    fontSize: 16px
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.5
  label:                   # control labels, buttons
    fontFamily: Inter
    fontSize: 13px
    fontWeight: 500
    lineHeight: 1.2
  meta:                    # numbers, timestamps, versions, ids
    fontFamily: "IBM Plex Mono"
    fontSize: 11px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: 0.05em
spacing:                   # 4px base — every margin and pad snaps to this
  1: 4px
  2: 8px
  3: 12px
  4: 16px
  6: 24px
  8: 32px
  12: 48px
rounded:
  sm: 6px
  md: 10px
  full: 9999px
components:
  # ── Surfaces ──
  page:                    # the app canvas
    backgroundColor: "{colors.bg}"
    textColor: "{colors.primary}"
  card:                    # raised container
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary}"
    rounded: "{rounded.md}"
    padding: "{spacing.4}"
  input:                   # form field
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary}"
    rounded: "{rounded.sm}"
    padding: 8px 12px
  divider:                 # hairline rule
    backgroundColor: "{colors.border}"
    height: 1px
  divider-strong:          # stronger rule / pressed edge
    backgroundColor: "{colors.border-strong}"
    height: 1px
  # ── Text styles ──
  text-secondary:          # muted body text
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-muted}"
    typography: "{typography.body}"
  text-metadata:           # numbers, timestamps, ids
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-meta}"
    typography: "{typography.meta}"
  # ── Buttons: neutral importance axis, never accent-colored ──
  button-primary:          # the one heaviest action per view — use once
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: 8px 16px
  button-primary-hover:
    backgroundColor: "{colors.primary-hover}"
  button-primary-active:
    backgroundColor: "{colors.primary-active}"
  button-secondary:        # tonal fill, no border
    backgroundColor: "{colors.fill}"
    textColor: "{colors.primary}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: 8px 16px
  button-secondary-hover:
    backgroundColor: "{colors.fill-hover}"
  button-secondary-active:
    backgroundColor: "{colors.fill-pressed}"
  button-tertiary:         # ghost — transparent at rest (resolves to surface)
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: 8px 16px
  button-tertiary-hover:
    backgroundColor: "{colors.fill}"
  button-danger:           # variant, not a tier — irreversible only
    backgroundColor: "{colors.danger}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: 8px 16px
  button-danger-ghost:     # destructive in a row — quiet until hover
    backgroundColor: "{colors.surface}"
    textColor: "{colors.danger}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: 8px 16px
  button-danger-ghost-hover:
    backgroundColor: "{colors.danger-wash}"
  # ── State markers & badges — always carry a label, never color alone ──
  badge-draft:
    backgroundColor: "{colors.draft-wash}"
    textColor: "{colors.draft-ink}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: 2px 8px
  badge-published:
    backgroundColor: "{colors.published-wash}"
    textColor: "{colors.published}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: 2px 8px
  marker-draft:            # the loose draft leading edge / divider
    backgroundColor: "{colors.draft}"
    width: 2px
  marker-pinned:           # solid pin dot
    backgroundColor: "{colors.pinned}"
    rounded: "{rounded.full}"
    size: 8px
---

# Imagine CMS — Design System

## Overview

The mood is **Quiet Studio**: a calm, near-monochrome workbench that recedes so
the user's content reads true. The CMS is the workbench; the content is the
work. Surfaces are airy and cool-neutral; grouping comes from whitespace and
alignment rather than boxes, so any region carries at most one of {border, fill,
shadow}.

Personality is concentrated in one place — a **two-temperature state system**.
Warm marigold means *draft / pinned / yours*; cool teal means *published / live
/ the world's*. The contrast between those temperatures carries the entire
emotional message: you are free to build and experiment, because everything is
versioned and nothing can be lost. Everything else stays neutral and quiet.

The one expressive risk is a single **Sketchbook gesture**, reserved for the
draft state only (see *Shapes*). This is a **product**-register system —
design serves the workflow — and it targets WCAG AA. See `PRODUCT.md` for users,
purpose, and principles, and `docs/design-notes.md` for the build order and the
draft-divider reference snippet.

## Colors

Strategy is **restrained**: tinted-neutral chrome plus a single reserved accent
that never exceeds the state system. The accent (`draft`/`published`) is reserved
for **version-state and the wordmark dot only** — it never fills a button and is
never a generic brand splash.

- **Chrome** — `bg` (Faint Cool White) is the page; `surface` (Pure White) raises
  cards; `border` is the hairline; `primary` (near-black ink) is primary text and
  the primary-button fill; `text-muted` and `text-meta` step down for secondary
  text and metadata (both verified ≥4.5:1 on `surface` — `text-meta` is darker
  than a typical caption gray precisely to clear AA at 11px). The neutrals are
  deliberately *cool* so they never contaminate the user's judgment of their own
  content's color. The focus ring reuses `primary`.
- **Draft / pinned** — `draft` (Bright Marigold) is legible as a *shape* (dot,
  marker, sketch stroke) but **fails as small text on white**; any accent-colored
  text must use `draft-ink` (Marigold Ink, AA at 4.9:1 on `draft-wash`). The wash
  tokens (`draft-wash`, `published-wash`, `danger-wash`) are stored as solid
  composites-on-white so their text contrast is well-defined.
- **Published** — `published` (Settled Teal-Green) marks live content; `published-wash`
  tints published regions.
- **Destructive** — `danger` (Clear Warning Red) is deliberately kept clear of
  marigold so a warm draft tint is never read as danger. Reserved for the rare
  irreversible action.

Contrast floor: body text ≥4.5:1, large text ≥3:1. State is **never** signaled by
color alone — every state pairs its temperature with a text label.

## Typography

Two families on a clear contrast axis, never two similar sans-serifs:

- **`display` / `title` / `body` / `label` — Inter** (humanist sans). All chrome:
  titles, prose, labels, buttons.
- **`meta` — IBM Plex Mono.** Every number, timestamp, identifier, hash, or
  version. A version history is a log; the mono face signals "record." Always
  paired with the `text-meta` color.

The dividing rule: anything read as prose is Inter; anything that is a number,
time, id, or version is mono. Template-rendered *content* owns its own
typography — the chrome never imposes type on it. Display tracking stays at
-0.01em (well above the cramped floor); line length for any prose caps at ~70ch.

## Layout

Whitespace and alignment do the grouping — the cure for a busy screen is
subtractive (delete competing borders, fills, shadows), not additive. Everything
snaps to the 4px `spacing` scale, which alone makes most screens read as
intentional. Emphasis is spent once per group: a row with a state badge does not
also get a bold title *and* a border *and* a shadow.

Two density tiers, never ad-hoc:

- **comfortable** — 16px (`spacing.4`) rows, Inter — content editing, forms, prose.
- **compact** — 8×12px (`spacing.2` × `spacing.3`) rows, mono — version history,
  metadata rows, logs.

Layouts work down to mobile, where compact rows wrap gracefully. Use flexbox for
1D, grid for 2D; responsive grids without breakpoints via
`repeat(auto-fit, minmax(280px, 1fr))`.

## Elevation & Depth

Depth is whisper-soft and rare — prefer whitespace plus a hairline to a shadow.
The only elevation token is the raised surface: `box-shadow: 0 1px 2px
rgba(26,29,33,0.04)`. Never pair a 1px border **and** a soft wide shadow on the
same element; pick one. No glassmorphism, no decorative blur.

## Shapes

Corners are gently rounded, never over-rounded: `rounded.sm` (6px) for buttons,
inputs, and badges; `rounded.md` (10px) for cards and containers; `rounded.full`
only for pills/dots. Cards top out at 10px — no 24/28/32px "insanely rounded"
surfaces.

**The signature gesture (the one allowed loose edge):** draft-state structural
edges — *draft dividers and the draft region's leading edge only* — render as a
slightly loose, hand-pencilled marigold stroke (`{colors.draft}`, ~2px, faintly
irregular). On publish they **snap** to a 1px solid hairline (`{colors.border}`
or `{colors.published}`); the snap is instant under `prefers-reduced-motion`.
Strict scope: never apply the sketch treatment to text, icons, buttons, or
layout frames. The reference SVG implementation lives in `docs/design-notes.md`.

## Components

- **Buttons** — three neutral tiers on an importance axis, never accent-colored.
  `button-primary` (near-black `primary` fill, one per view), `button-secondary`
  (tonal fill, no border), `button-tertiary` (ghost; transparent at rest —
  tokenized as `surface` so its contrast is defined — with a visible hover and
  focus ring, quiet not hidden). `button-danger` / `button-danger-ghost` is a
  cross-cutting **variant**, not a fourth tier, and is rare because almost nothing
  here is irreversible. All tiers share a 2px `primary` focus ring at 2px offset
  and 0.4 opacity when disabled.
- **State badges** — `badge-draft` (marigold-wash pill, marigold-ink text) and
  `badge-published` (teal-wash pill, teal text). The pin marker is a solid
  `{colors.pinned}` dot. Each badge always carries its word, not just its color.
- **Cards / containers** — `surface` on `bg`, `rounded.md`, one hairline `border`
  *or* the raised shadow, never both. Draft containers add `draft-wash` and the
  loose leading edge; published containers add a teal chip and a crisp hairline.
- **Inputs / forms** — quiet low-stroke fields, hairline `border` that
  strengthens to the ink focus ring on focus; comfortable density for editing,
  compact for metadata rows.
- **Wordmark** — "Imagine" in Inter 600, -0.02em tracking, the dot on the *i*
  rendered in `{colors.draft}` (marigold). The brand and the product's core
  gesture — pin this, experiment around it — are the same object.

## Do's and Don'ts

**Do**
- Reserve marigold and teal for version-state and the wordmark dot.
- Use `draft-ink` for any accent-colored text; use `draft` only as a shape.
- Pair every state with a text label, not color alone.
- Group with whitespace and alignment; give a region at most one of {border,
  fill, shadow}.
- Set numbers, times, ids, and versions in the mono `meta` style.
- Keep one primary action per view.

**Don't**
- Don't color buttons with marigold or teal — even "Publish" is a primary ink
  button; the *result* turns teal, not the control.
- Don't use side-stripe (`border-left`) accents, gradient text, or decorative
  glassmorphism.
- Don't over-round cards (no 24px+) or pair a 1px border with a wide soft shadow.
- Don't apply the sketch gesture anywhere but draft dividers / the draft edge.
- Don't let muted gray body text fall below 4.5:1 on tinted backgrounds.
- Don't let the chrome impose typography on template-rendered content.
