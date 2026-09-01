# Karat Hive — UI Mock

Interactive **HTML/CSS/JS** mock of all **67** screens from `ui-screens/`, styled with **`Karat_Hive_UI_Design_Context.md`** (luxury Art Deco · sapphire · metallic gold).

## Explanation doc

| Format | Path |
|---|---|
| Full Markdown export | [`docs/EXPLANATION.md`](docs/EXPLANATION.md) |
| Side-panel content | [`docs/explanation-side.html`](docs/explanation-side.html) |

In the running mock:

- **Side section** (left rail on desktop ≥1100px; drawer on mobile) shows the condensed guide.
- Toggle with the floating **Docs** button (or **Close** in the panel).
- Use **Export full doc (Markdown)** in the panel header to download/open `EXPLANATION.md`.

## Run

Screen partials load via `fetch`, so open over HTTP (not `file://`):

```bash
npx --yes serve ui-mock
```

Or:

```bash
cd ui-mock
python -m http.server 5173
```

Then open the URL shown (e.g. `http://localhost:3000`).

## Login

Role chooser only:

- **Customer** → Home (`CUS-S02`)
- **Vendor** → Dashboard (`VEN-S05`)
- **Admin** → Dashboard (`ADM-S02`)

No password. Full auth **fields** still appear on `CUS-S01`, `VEN-S01`/`S04`, `ADM-S01` for inventory completeness.

## Navigation

- Hash routes: `#/customer/CUS-S04`, `#/vendor/VEN-S09`, `#/admin/ADM-S07`
- **☰ Screen map** — jump to any screen for the current role
- Bottom tabs (Customer): Home · Requests · Connections · Alerts · Profile
- Bottom tabs (Vendor): Home · Requests · Offers · Connect · More
- Admin: sidebar (≥1024) / drawer (mobile)

## Structure

```
ui-mock/
  index.html
  css/          tokens, components, shell, screens
  js/           data, nav, gold-light, app
  assets/       brand, placeholders, illustrations
  screens/
    customer/   22 HTML partials
    vendor/     22 HTML partials
    admin/      23 HTML partials
```

## Design notes

- Tokens mirror design-context palette (`sapphire900`, `gold400`, cream text).
- **Gold-light sweep** on hero / primary CTAs (respects `prefers-reduced-motion`).
- Identity **masked** pre-accept; **revealed** on connection screens.
- WhatsApp green only on Talk actions.

## Field completeness

Each screen HTML is generated from the matching `ui-screens/**/*.md` **Fields** table, then key surfaces (home, offers, accept, connection, vendor dashboard, admin dashboard) are hand-composed for visual fidelity.
