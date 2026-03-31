---
id: S-07
title: "Sprint 07: Content Quality Overhaul — March 2026 Core Update Response"
status: complete
start: 2026-03-22
end: 2026-03-29
velocity_target: 8
velocity_actual: 8
---

# Sprint 07: Content Quality Overhaul — March 2026 Core Update Response

**Duration:** 2026-03-22 → 2026-03-29
**Sprint goal:** Bring all 2.3M+ dynamically generated service pages into compliance with Google's March 2026 core update quality signals, restore indexing trajectory, and document the response for the blog.

---

## Trigger

Google rolled out the March 2026 core update targeting thin/template content at scale. Google Search Console showed ~60K pages in "Crawled — currently not indexed" status, indicating Google was evaluating and declining to index programmatically generated service landing pages. The site generates pages for 18,744 US cities × 154 service verticals via Cloudflare Pages edge functions.

---

## Features in this sprint

| Feature | PRD | SPEC | Status | Priority |
|---|---|---|---|---|
| Edge function content differentiation | PRD-CQ-001 | SPEC-CQ-001 | complete | high |
| SEO/PWA/accessibility site-wide audit | PRD-CQ-002 | SPEC-CQ-002 | complete | high |
| New service category expansion (6 categories, 38 verticals) | PRD-CQ-003 | SPEC-CQ-003 | complete | medium |
| Blog article: core update case study | PRD-CQ-004 | — | complete | medium |

---

## ADRs made during this sprint

| Decision area | ADR | Status | Rationale |
|---|---|---|---|
| Edge function architecture | ADR-EF-001 | accepted | Single edge function renders all /services/* routes dynamically — no static HTML fallback |
| Robots directive strategy | ADR-ROBOTS-001 | accepted | All valid pages: `index, follow, max-snippet:-1`. Only 404s get `noindex`. No tiered indexing. |
| Content differentiation approach | ADR-CONTENT-001 | accepted | Per-city metro population data, per-service unique insights, per-category pain points — injected at render time |

---

## Task board

### Sequential tasks (executed in order)

| Order | Task | Description | Files touched | Status | Date |
|---|---|---|---|---|---|
| 1 | TASK-CQ-001 | Deep site audit: SEO, PWA, accessibility | 53 files | complete | Mar 22 |
| 2 | TASK-CQ-002 | Fix Google Ads API v22 mutate bugs found in audit | 4 files | complete | Mar 22 |
| 3 | TASK-CQ-003 | Upgrade buddy-agent capabilities | 6 files | complete | Mar 22 |
| 4 | TASK-CQ-004 | Add 6 new service categories + 38 verticals | edge function, sitemaps, data | complete | Mar 24 |
| 5 | TASK-CQ-005 | Quality and compliance fixes for new categories | edge function, sitemaps | complete | Mar 25 |
| 6 | TASK-CQ-006 | Final sweep: sitemaps, llms-full.txt, video sitemap | 8 files | complete | Mar 25 |
| 7 | TASK-CQ-007 | Content quality overhaul: address core + spam signals | edge function (2,571 lines) | complete | Mar 28 |
| 8 | TASK-CQ-008 | Write article 17: case study on core update response | blog/ | complete | Mar 29 |

---

## Key decisions and tradeoffs

### Why not noindex low-traffic pages?

Considered tiered indexing (only submit top 200 metros to sitemaps, noindex the rest). Rejected because:
- Noindexing 95% of pages would abandon the programmatic SEO strategy entirely
- The pages were being declined for content quality, not technical issues
- The fix was differentiation, not restriction

### Why edge functions instead of static HTML?

The static build (`build.js`) generates ~4,700 pages from a template with no per-city differentiation. The edge function renders all 18,744 × 154 combinations dynamically with:
- Metro population data for top metros
- Per-service unique advertising insights
- Per-category pain point narratives
- Dynamic internal linking (same-category, nearby cities)
- Real-time `article:modified_time` meta tags

This means every page has content that a static build cannot provide.

---

## Commit chain

```
262f038 Deep site audit: SEO, PWA, accessibility fixes across 53 files
89ab59d Fix mutate bugs found in Google Ads API v22 audit
4932178 Fix Google Ads mutate bugs and upgrade buddy-agent capabilities
0a55a5e Add 6 new service categories and 38 verticals
9b06896 Quality and compliance fixes for new service categories
39d8ef6 Final sweep: article 16 sitemap, llms-full.txt, video sitemap
1203599 Content quality overhaul: address March 2026 core + spam updates
44bc02d Add article 17: How we responded to Google's March 2026 core update
```

---

## Quality gates

| Gate | Method | Result |
|---|---|---|
| All valid pages return 200 + `index, follow` | curl spot checks on 10 city/service combos | Pass |
| All 404s return `noindex, nofollow` | curl for invalid slugs | Pass |
| No broken internal links | lychee link checker in CI | Pass |
| HTML validation | html-validate across all static pages | Pass |
| npm audit clean | npm audit --audit-level=high | Pass (0 vulnerabilities) |
| Edge function serves correct canonical URLs | Verified via live headers | Pass |
| Sitemaps exclude state-restricted combos | Grep verification | Pass |

---

## Retrospective

### What went well
- Edge function approach allowed updating all 2.3M+ pages in a single deploy — no rebuild required
- CEP protocol prevented any accidental mutations during the Google Ads API audit
- Blog article documenting the response serves dual purpose: E-E-A-T signal + content marketing

### What to improve
- The edge function is now 2,571 lines in a single file — should be modularized in next sprint
- Sitemaps still reference 2.38M URLs across 58 files; should consolidate to match actual indexing priority
- Need automated monitoring for Google Search Console indexing status changes

### Carry-over to Sprint 08
- Edge function modularization
- Sitemap consolidation
- GSC monitoring automation

---

*Production example — contributed by John Williams ([itallstartedwithaidea](https://github.com/itallstartedwithaidea)) — BHIL AI-First Development Toolkit*
