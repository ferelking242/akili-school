# Scolaris

Multi-platform Flutter app (web, mobile, desktop) for SaaS-grade school management.

## Quick start

This Replit runs the **Flutter web** build on port 5000 via the `Start application` workflow (`node serve.js`).

To rebuild after code changes:
```
export PATH="/home/runner/flutter/bin:$PATH" && cd scolaris && flutter build web --release --base-href "/"
```
Then restart the "Start application" workflow.

## Demo accounts (mock auth)

The app uses real Supabase auth when credentials are embedded. It falls back to mock auth for development. Sign in with any of:

- `student@scolaris.app`
- `parent@scolaris.app`
- `teacher@scolaris.app`
- `surveillance@scolaris.app`
- `finance@scolaris.app`
- `admin@scolaris.app`

Password: `demo1234`. Role is inferred from the local-part of the email.

## Architecture

Strict Clean Architecture (UI → Provider → UseCase → Repository → Service):

```
lib/
├── core/             config · theme · localization · permissions · routing · services
├── data/             models · sources (remote/local) · repository implementations
├── domain/           pure entities · repository interfaces · use cases
├── presentation/     riverpod providers · global widgets
├── features/         auth · student · parent · teacher · surveillance · finance · admin
│   └── onboarding/  school_registration_page.dart (7-step wizard)
└── shared/           desktop_shell · mobile_shell · responsive shell · widgets
```

Key principles:
- **UI never contains business logic** — every screen calls a provider.
- **RBAC** is centralized in `lib/core/permissions/permissions.dart`. Never inline a role check in UI.
- **Platform branching** lives in `lib/core/platform/platform_utils.dart` and the `ResponsiveRoleShell` widget.

## Supabase

- **URL**: `https://iaxwvgqusxyhmyansawi.supabase.co`
- Credentials stored in `lib/core/config/app_config.dart` (compiled via `--dart-define`, defaults embedded for dev)
- Schema: `scolaris/supabase/schema.sql`
- Tables created: `schools`, `campuses`, `profiles`, `classes`, `enrollments`, `courses`, `grades`, `attendance`, `invoices`, `payments`, `schedule_slots`, `notifications`
- RLS enabled on all tables with simplified per-user policies

## Localization

`assets/translations/{en,fr,sw,ln}.json` — managed by `easy_localization`. To add a new language, drop a JSON file and register the locale in `lib/core/localization/locales.dart`.

## Theming

`flex_color_scheme` with light/dark + dynamic accent. Per-school branding overrides the accent at runtime via `ThemeController.setAccent()`.

## Mobile vs Desktop UX

- **Wide form factor (desktop / wide web)**: Fluent-style sidebar (collapsible, inner-radius) + topbar + content area.
- **Mobile / small web**: Material 3 with a floating, rounded, shadowed bottom dock (built on `salomon_bottom_bar`).

Selection happens automatically based on viewport width and platform.

## Desktop Shell

- `lib/shared/desktop_shell/desktop_shell.dart` — sidebar + header layout
- Sidebar toggle: hamburger always visible (`_BrandRow` shows icon even when collapsed)
- Header: school name + Section/Campus `_SelectorChip` dropdowns + search/notifications/account action panels

## School Registration (Onboarding)

Route: `/onboarding` (no auth required)  
File: `lib/features/onboarding/presentation/school_registration_page.dart`

7-step wizard:
1. **Bienvenue** — plan selection (Gratuit / Essentiel / Pro / Entreprise)
2. **École** — school name, type, logo upload
3. **Localisation** — country, city, address
4. **Académique** — school year format, grading system, languages, shifts
5. **Campus** — add one or more campuses with capacity
6. **Administrateur** — admin account (name, email, password)
7. **Confirmation** — animated summary + "Lancer mon école" button

## Recent changes

- 2026-04-29: Initial scaffolding. All 6 role shells, both desktop and mobile shells, 4-language packs, charts, QR, RBAC, GitHub Actions.
- 2026-05-05: (1) Fixed PC sidebar toggle bug — hamburger always visible when collapsed. (2) Updated desktop header — school name + section/campus chips + wired search/notifications/account panels. (3) Connected Supabase (anon key in AppConfig, initialize in main.dart, real auth source). (4) Created 12 Supabase tables + RLS policies. (5) Built 7-step school registration/onboarding wizard at `/onboarding`.
