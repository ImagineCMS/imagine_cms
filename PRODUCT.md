# Product

## Register

product

## Users

The primary user is the **occasional content editor** — a client who logs into the CMS roughly once a month to make a change, then leaves. Most CMSes assume daily use; this one cannot. By the next visit the editor has forgotten how everything works, so every screen must be re-enterable on sight: plain labels named for what the user does, no memorized workflows, and nothing that can be permanently broken.

Two secondary audiences share the same management UI:
- **Managers**, who govern who may publish where (the draft-approval system) and need to stay oriented across many pages.
- **Developers and designers**, who build the templates and snippets the editors fill in. For them the chrome should stay out of the way and expose structure rather than decorate it.

The context is real production sites with thousands of pages — work, not play — accessed from a normal desktop browser, often after a long gap.

## Product Purpose

Imagine CMS is an easy-to-use, self-contained web content management system (the Elixir/Phoenix rewrite of the original Rails Imagine 5). It exists to resolve the usual CMS trade-off: simple systems are too rigid for designers and developers, while flexible systems are too intimidating for occasional clients. Imagine aims to be easy for clients, flexible for builders, and to stay out of everyone's way.

The signature mechanism is **versioning as a safety net**. Pages, templates, and snippets are all versioned; you can pin a published version and experiment around it, and undo nearly anything. Success looks like an editor who returns after months, recognizes every control, makes the change confidently because they can see nothing is at risk, and ships it — without a support call.

## Brand Personality

Warm, plain-spoken, and quietly confident. Three words: **calm, generous, un-enterprise**. The voice is plain and active, in sentence case, naming controls by what the user does rather than how the system works — and an action keeps its name through the flow ("Publish" → "Published"). It should feel like a well-kept studio workbench: the tool recedes so the user's content is the work. The emotional goal is *permission to experiment* — the interface's job is to make the safety net visible so the user feels free to build.

## Anti-references

- **Heavy enterprise admin** (WordPress/Drupal-style dashboards): cluttered toolbars, boxes nested in boxes, intimidating density. Avoid.
- **Trendy SaaS dashboards**: generic gradient-and-card layouts, the hero-metric template, identical icon-card grids, AI-default cream backgrounds. Avoid.
- **Sterile, cold developer tooling**: impersonal, gray, clinical. The brand is warm and human, not a control panel.

## Design Principles

- **Make the safety net visible.** The product's core promise is "you can't lose this." Surface versioning and state so the user *sees* they're safe; that visible safety is what earns experimentation. Destructive, irreversible actions should be rare — and their rarity is the promise made concrete.
- **Easy to re-enter, every time.** Design for the user returning after months, not the user who's here every day. Plain labels, recognizable-on-sight controls, no memorized paths.
- **The tool recedes; the content is the work.** Quiet, near-monochrome chrome that never competes with or contaminates the user's judgment of their own content.
- **One emphasized thing per group.** Group by whitespace and alignment, not boxes. Spend emphasis once; subtract competing borders, fills, and shadows.
- **Personality in one place only.** Warmth and identity live in the version-state system (warm = draft/yours, cool = published/live) and the wordmark — not scattered across the surfaces.

## Accessibility & Inclusion

Target **WCAG 2.1 AA**. Body text meets ≥4.5:1 contrast (≥3:1 for large text); accent-colored text uses the darker marigold ink pair rather than the bright surface value. Every interactive control carries a visible focus ring. State is never communicated by color alone — every state pairs its temperature with a text label (draft / pinned / published) for color-blind users. Motion respects `prefers-reduced-motion` (the draft-to-published sketch transition snaps instantly). The management UI must remain usable down to mobile widths, where compact rows wrap gracefully.
