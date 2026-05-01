# Akili School

Multi-platform Flutter app (web, mobile, desktop) for SaaS-grade school management.

## Quick start

This Replit runs the **Flutter web** build on port 5000 via the `Start application` workflow:

```
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000 --release
```

Compilation takes ~1 minute on a cold cache. Subsequent reloads are fast.

## Demo accounts (mock auth)

The app falls back to a mock auth source when `SUPABASE_URL` / `SUPABASE_ANON_KEY` are not provided. Sign in with any of:

- `student@akili.school`
- `parent@akili.school`
- `teacher@akili.school`
- `surveillance@akili.school`
- `finance@akili.school`
- `admin@akili.school`

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
└── shared/           desktop_shell · mobile_shell · responsive shell · widgets
```

Key principles:
- **UI never contains business logic** — every screen calls a provider.
- **RBAC** is centralized in `lib/core/permissions/permissions.dart`. Never inline a role check in UI.
- **Platform branching** lives in `lib/core/platform/platform_utils.dart` and the `ResponsiveRoleShell` widget.

## Localization

`assets/translations/{en,fr,sw,ln}.json` — managed by `easy_localization`. To add a new language, drop a JSON file and register the locale in `lib/core/localization/locales.dart`.

## Theming

`flex_color_scheme` with light/dark + dynamic accent. Per-school branding overrides the accent at runtime via `ThemeController.setAccent()`.

## Mobile vs Desktop UX

- **Wide form factor (desktop / wide web)**: Fluent-style sidebar (collapsible, inner-radius) + topbar + content area.
- **Mobile / small web**: Material 3 with a floating, rounded, shadowed bottom dock (built on `salomon_bottom_bar`).

Selection happens automatically based on viewport width and platform.

## CI / CD

GitHub Actions are wired in `.github/workflows/`:

- `build-all.yml` → Android (every ABI: armeabi-v7a, arm64-v8a, x86_64) **first**, then iOS, Web, Linux, Windows, macOS. Triggers on push, PR, tag, manual.
- `build-android-arm64.yml` → A focused, fast pipeline that only produces `app-arm64-v8a-release.apk`.

Repo: https://github.com/ferelking242/akili-school

## Recent changes

- 2026-04-29: Initial scaffolding. All 6 role shells, both desktop and mobile shells, 4-language packs, charts, QR, RBAC, GitHub Actions, public repo created and pushed.
