# CLAUDE.md — Craving Hospitality website

> Project memory / handoff for the next session. Read this first.

## What this is
A **showcase-first marketing website** for **Craving Hospitality**, a premium-but-playful fresh
catering company in Lebanon (sandwiches "Yummy Sands" + salads "Fresh Salads"). The whole site
funnels toward **one action: getting a catering/event inquiry**. Most traffic arrives from Instagram
on mobile, so it's **mobile-first**. It is NOT e-commerce / no online ordering.

Brand voice: warm, confident, playful but polished — "a fresh farmer's market elevated to five-star."
Tagline energy from their IG: *"In the mOOd with a smile."*

## Tech & how to run
- **Static site**: plain HTML + one CSS file + one vanilla JS file. **No build step, no framework, no deps.**
- Preview locally (from the repo root `10k websites plan`):
  - A `.claude/launch.json` defines a server named **`craving`** → `py -m http.server 5577 --directory craving-hospitality`.
  - In Claude Code: start the `craving` preview; or just run that command and open `http://localhost:5577/index.html`.
  - Python is available as **`py`** (3.14). `python`/`python3` are NOT on PATH (Windows Store stubs).
- Deploy: drop the `craving-hospitality/` folder on any static host (Netlify / Vercel / Cloudflare Pages / GitHub Pages).

## File structure
```
craving-hospitality/
├─ index.html         Home (hero, intro, featured dishes, catering teaser, gallery marquee, closing CTA)
├─ menu.html          Sticky category toggle + protein filters, 8 sandwiches + 3 salads, ♥ bookmark, CTA
├─ catering.html      Hero, 3-step "How it works", offer formats + pricing-from, 3-STEP INQUIRY FORM
├─ about.html         Story, BTS photos, values, CTA
├─ gallery.html       Filter tabs (All/Food/Events/BTS) + masonry + lightbox
├─ contact.html       Info cards + simplified 1-step message form
├─ assets/
│  ├─ css/styles.css  ← entire design system (tokens, components, responsive, reduced-motion)
│  ├─ js/main.js      ← all interactions (nav, reveals, parallax, menu filters, lightbox, forms→WhatsApp, analytics)
│  └─ img/            ← processed brand images (see Image pipeline)
├─ AI-IMAGES.md       ← per-item AI image PROMPT PACK + exact filenames to drop in
├─ CLAUDE.md          ← this file
└─ _work/             ← image-processing scripts + scratch (safe to ignore/delete)
```

## Design system (in `assets/css/styles.css`, CSS custom props on `:root`)
- **Canvas**: cream `--cream:#F7F4E3` (dominant). Alt bands: butter `#F2E8B0`, sage `#C5D5B0`, peach `#FAE5D3`, `--cream-2:#FBF9EE`.
- **Ink**: forest green `--forest:#1F4D2E` (headings/nav/logo), body charcoal `--charcoal:#3A3A3A`.
- **Accent / CTA**: coral. `--coral:#D4715E` decorative only; `--coral-deep:#BC4D38` for buttons + small coral text (passes WCAG AA on cream).
- **Type** (Google Fonts, 2 families max): display **Baloo 2** (rounded, matches their bubbly logo lettering) for headings/logo/buttons; body **Plus Jakarta Sans**.
- Key classes: `.btn`/`.btn--outline`/`.btn--forest`/`.btn--ghost`, `.badge` (green price), `.tag`/`.tag--best`, `.chip`,
  `.card`/`.card__media`/`.bookmark`, `.blob`/`.blob--1..3` (organic image masks), `.reveal` (scroll-in), `.fab` (WhatsApp),
  `.menubar`/`.toggle`/`.cards`, `.formwrap`/`.fstep`/`.progress`, `.masonry`/`.gitem`/`.lightbox`.
- Motion: 600–800ms ease reveals, hover lift+shadow, hero parallax, breathing-logo preloader. Everything respects `prefers-reduced-motion`.

## Conversion plumbing
- **Phone / WhatsApp number: `+961 71 590 222`** (used in `tel:`, `wa.me/96171590222`, FAB, footer, forms). Change in HTML + `WHATSAPP` const in `main.js` if it ever changes.
- **Forms have NO backend.** On submit they build a formatted message and **open WhatsApp** (`wa.me`) pre-filled, then show a success state. Multi-step engine = any `<form data-multistep="...">` with `.fstep` steps, `.progress__step`s, `.js-back/.js-next/.js-submit`, and a sibling `.success`. Contact form reuses it as a single step.
- **Menu ♥ "Add to Inquiry"**: bookmarks persist in `localStorage` and are appended to the catering WhatsApp message.
- **Analytics**: every CTA has `data-track="..."`. `main.js` calls `gtag(...)` + pushes to `dataLayer` (no-ops until you add a GA/GTM snippet in each `<head>`). Search `data-track` to see tracked events.
- **SEO**: per-page `<title>`/meta/canonical, OpenGraph, JSON-LD (`Caterer`/`Menu`/`Service`). Update the `https://thisiscravings.com` URLs + add a real email when known.

## Image pipeline  ⚠️ IMPORTANT — current open task
Source images were **Instagram screenshots** (in `../images for Cravings/`) with phone + IG UI baked in.
They were auto-cropped/cleaned with **.NET System.Drawing via PowerShell** (Pillow would NOT build on Py 3.14;
GDI+ has no WebP encoder, so output is JPG/PNG). Scripts: `_work/imglib.ps1`, `_work/generate.ps1`, `_work/generate2.ps1`.
- Cleaned assets in `assets/img/`: `logo.png` (isolated circular), `hero-sandwich.jpg`, 8 `sand-*.jpg`, 3 `salad-*.jpg`,
  `post-*.jpg` (gallery), `poster-sands1/2`+`poster-salads` (full menu cards), `feature-halloumi-hand.jpg`.
- **Limitation**: extracted item photos are small/soft (the food is tiny inside the original screenshots) and some
  carry faint brand lettering at the edges (hidden by `object-fit: cover` card framing).

### 🟡 PENDING USER REQUEST: replace all photos with crisp AI-generated images
The user asked to "replace all the images with AI generated respectively, so everything looks crisp."
**There is NO image-generation tool available in this environment** (no DALL·E/Imagen/Flux/API key — verified).
So the plan agreed-by-default:
1. The site already uses **fixed, swappable filenames** → dropping a new file with the same name upgrades the site, zero code change.
2. **`AI-IMAGES.md`** has a ready-to-run, brand-locked prompt for every image (hero, 8 sandwiches, 3 salads, catering/gallery, + 3 new BTS/spread shots).
3. Next step options (user hadn't picked when this was written):
   - User runs the prompts in their tool (ChatGPT/Midjourney/Gemini/Flux) → I crop+optimize+wire. **(recommended)**
   - User sends images → I integrate.
   - I build crisp **vector/SVG illustrations** in-house instead (no external tool needed) — different, illustrated look.
   - Drive a logged-in generator via the Chrome extension (slow/fragile).
- Keep the real `logo.png` (actual brand mark) — don't AI-replace it.
- The logo is **white/forest/coral on a butter circle**; favicons + nav + footer + loader all reference `logo.png`.

## Status — done ✅ / next ⏭️
**Done:** all 6 pages, full design system + JS, cleaned images wired, multi-step WhatsApp forms, gallery lightbox,
mobile menu, FAB, SEO meta + JSON-LD, reduced-motion, analytics hooks, AI prompt pack.

**Next / TODO:**
- ⏭️ **Images**: execute the AI-image swap per the section above (the headline open item).
- ⏭️ Final verification pass already started (catering form flow, lightbox, mobile nav at 375px) — re-run after image swap.
- ⏭️ Add real **Google Analytics / GTM** ID in each `<head>` (hooks already in place).
- ⏭️ Replace placeholder canonical URLs / add real **email** + optional Google Maps embed on Contact.
- ⏭️ Optional: generate the 3 "(NEW)" images in AI-IMAGES.md (`catering-spread.jpg`, `about-team.jpg`, `about-prep.jpg`) to upgrade Catering/About; they currently reuse existing photos.
- ⏭️ Optional perf: once final images exist, also export WebP + `srcset` (couldn't via GDI+; do with squoosh/sharp/an online tool).

## Brand facts (don't lose these)
- Name: **Craving Hospitality** · IG: **@cravinghospitalitylb** · Web: **thisiscravings.com** · Phone/WA: **+961 71 590 222** · Lebanon.
- Menu (current): Yummy Sands $4–$5 (Roast Beef 5, Halloumi Pesto 4, Tuna 4, Deli Ham&Cheese 4, Chicken Avocado 4.5, Chicken Caesar 4, Crab&Corn 4, Chicken Pesto 4.5). Fresh Salads (Chicken Caesar 6, Crab&Citrus 5.5 = best seller, Greek Feta 6).
