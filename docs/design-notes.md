# Design Notes — Imagine CMS

Implementation companion to [`DESIGN.md`](../DESIGN.md). This file holds only the
things the design.md token schema has no slot for: the one reference snippet, the
sketch-gesture mechanics, and a suggested build order.

**Single source of truth for tokens is [`DESIGN.md`](../DESIGN.md).** Colors,
typography, spacing, radii, and component styles live in its YAML front matter —
don't duplicate them here. Strategic intent (who/why), the voice/copy rules, and
the accessibility floor live in [`PRODUCT.md`](../PRODUCT.md).

> Note on washes: `DESIGN.md` stores `draft-wash` / `published-wash` /
> `danger-wash` as **solid composites-on-white** (e.g. `#FEF3E2`) so their text
> contrast is well-defined and lints clean. In CSS you may prefer the equivalent
> alpha form when a wash must sit over a non-white surface:
> `rgba(245,158,11,0.12)` (draft), `rgba(47,107,94,0.10)` (published),
> `rgba(180,35,24,0.08)` (danger). On the white `surface` they are identical.

---

## The signature gesture — draft sketch edge

The one allowed loose gesture. Crisp ink everywhere **except** draft-state
structural edges, which render slightly loose, as if pencilled. On publish they
snap to a solid hairline.

Strict scope — apply only to **draft dividers and the draft region's leading
edge**. Never to text, icons, buttons, or layout frames. (See the `marker-draft`
component and the *Shapes* section in `DESIGN.md`.)

- **stroke:** `{colors.draft}` (#F59E0B), ~2px, faintly irregular / hand-drawn
- **on publish:** snap to a 1px solid hairline — `{colors.border}` (#E3E6EA) or
  `{colors.published}` (#2F6B5E)
- **reduced motion:** the snap is instant; no animation

Reference implementation for a draft divider (inline SVG, jitter baked into the
path — no JS, and it respects reduced-motion automatically since it doesn't
animate):

```html
<svg class="draft-divider" height="3" width="100%" preserveAspectRatio="none"
     viewBox="0 0 300 3" aria-hidden="true">
  <path d="M0 1.6 Q 40 0.6 75 1.7 T 150 1.5 T 225 1.8 T 300 1.4"
        fill="none" stroke="#F59E0B" stroke-width="1.6"
        stroke-linecap="round"/>
</svg>
```

The published counterpart is simply `border-top: 1px solid var(--border)`.

> Why so tightly scoped: hand-drawn / sketchy SVG used broadly reads as
> amateurish. The discipline is that it appears on the draft edge and nowhere
> else — a sketch is by definition not precious, which is the whole point of the
> draft state.

---

## Density tiers (implementation reminder)

`DESIGN.md` defines two tiers in prose; in practice they map to:

- **comfortable** — `padding: {spacing.4}` (16px), Inter — content editing, forms,
  prose.
- **compact** — `padding: {spacing.2} {spacing.3}` (8×12px), IBM Plex Mono —
  version history, metadata rows, logs.

Never invent a third tier or an ad-hoc pad value; snap to the `spacing` scale.

---

## Elevation (implementation reminder)

There is exactly one elevation: the raised surface,
`box-shadow: 0 1px 2px rgba(26,29,33,0.04)`. Prefer whitespace + a hairline to a
shadow, and never pair a 1px border **and** a soft wide shadow on the same
element.

---

## Build order suggestion

1. Lay the spacing scale + color tokens; convert existing black/white chrome to
   these cool-neutral values. (Most screens look *intentional* after just this,
   with zero accent work.)
2. Introduce the state system — draft wash, pinned dot, published chip.
3. Add the wordmark (the marigold dot on the *i*).
4. Add the sketch gesture last, only on draft dividers. Remove one accessory
   before shipping each screen.
