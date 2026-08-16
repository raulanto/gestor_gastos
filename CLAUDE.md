# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**Gestor de Gastos Personales** is a Flutter personal-finance app (Spanish UI/comments) with local-only persistence (no backend). It covers transactions, multi-account balances, hierarchical categories, recurring transactions, savings goals, budgets, and loans/persons tracking, backed by a single SQLite database with local notifications and a WorkManager background task for daily checks.

## Commands

```bash
flutter pub get                 # install dependencies
flutter run                     # run on a connected device/emulator
flutter analyze                 # static analysis (uses flutter_lints via analysis_options.yaml)
flutter test                    # run tests (no test/ directory exists yet — add tests under test/)
flutter test test/some_test.dart              # run a single test file
flutter build apk / build ios   # platform builds
```

There is no CI config in this repo; `flutter analyze` and `flutter test` are the only verification gates.

## Architecture

### Feature-first, layered structure

Code lives under `lib/features/<feature>/` with a consistent three-layer split, and shared infrastructure under `lib/core/`:

```
lib/features/<feature>/
  domain/entities/          # plain Dart model classes
  domain/repositories/      # abstract repository interfaces
  data/datasources/         # sqflite CRUD against AppDatabase, maps rows <-> entities
  data/repositories/        # concrete repository impl, delegates to the datasource
  presentation/providers/   # Riverpod providers/notifiers wiring datasource -> repo -> UI
  presentation/pages/       # screens
  presentation/widgets/     # feature-local widgets
```

Features: `accounts`, `auth`, `budgets`, `categories`, `home`, `loans`, `onboarding`, `persons`, `recurring_transactions`, `savings`, `settings`, `transactions`. Some features also have an `application/` layer (e.g. `budgets/application/budget_notification_watcher.dart`, `savings/application/savings_service.dart`, `recurring_transactions/application/recurring_service.dart`) for cross-cutting logic that doesn't belong in a repository (scheduling, notification side effects).

When adding a feature, follow this same four-folder shape — datasource does SQL, repository is a thin passthrough implementing the domain interface, and a Riverpod provider chain (`xLocalDataSourceProvider` -> `xRepositoryProvider` -> `AsyncNotifierProvider`) exposes it to the UI. Look at `lib/features/accounts/` as the reference implementation for this pattern.

### State management (Riverpod)

- Uses `flutter_riverpod` with `AsyncNotifier`/`Notifier` classes, not the old `StateNotifier`.
- The typical per-feature provider chain: `xLocalDataSourceProvider` (wraps `appDatabaseProvider`) -> `xRepositoryProvider` -> `AsyncNotifierProvider<XNotifier, List<X>>` whose `build()` loads initial data and whose mutating methods (`add`/`update`/`delete`) call the repository then reload state.
- `sharedPreferencesProvider` is overridden at app startup in `lib/main.dart` (`ProviderScope(overrides: [...])`) after `SharedPreferences.getInstance()` is awaited — note it's declared as a plain (unimplemented, override-only) `Provider<SharedPreferences>` in `core/theme/theme_provider.dart`, but as a separate `FutureProvider<SharedPreferences>` in `features/auth/presentation/providers/pin_provider.dart`. Keep this distinction in mind — they are two different providers with the same name in different scopes, not one shared provider.
- `notificationServiceProvider` is similarly overridden in `main.dart` with an already-initialized `NotificationService`.

### Database (`lib/core/database/app_database.dart`)

- Single `sqflite` database (`gestor_gastos.db`), current schema `version: 11`.
- `_createDB` defines the full current schema (source of truth for a fresh install); `_upgradeDB` has one `if (oldVersion < N)` block per version for incremental migrations on existing installs.
- **When changing the schema, update both**: add the new column/table/index to `_createDB` AND add a new `if (oldVersion < 12)` block (bump the block number and `version:` together) in `_upgradeDB` with the equivalent `ALTER TABLE`/`CREATE TABLE`/`CREATE INDEX`. Forgetting either leaves fresh installs and upgraded installs with divergent schemas.
- Foreign keys are enforced (`PRAGMA foreign_keys = ON`) with `ON DELETE CASCADE` used throughout.
- `_createDB` also seeds default accounts and categories (with hardcoded `Icons.*.codePoint` / `Colors.*.toARGB32()` values) — `lib/core/utils/icon_utils.dart` maps codepoints back to `IconData` for rendering (its `_iconMap` must be kept in sync with any newly seeded/used icons).

### Routing (`lib/core/routing/app_router.dart`)

- `go_router` with a single `GoRouter` built from an `appRouterProvider`, driven by `goRouterRefreshNotifierProvider` (listens to auth/pin/session state to trigger redirects).
- Auth flow gating happens in the top-level `redirect` callback: unauthenticated -> `/`, authenticated without a PIN -> `/pin_setup`, authenticated with PIN but locked -> `/pin_login`, otherwise -> `/transactions`. There is no real backend auth — "auth" is a locally saved username (`auth_repository`) plus a locally saved PIN (`pin_provider`) gating a `sessionProvider` unlock flag.
- Main tabs (`/transactions`, `/recurring`, `/savings`, `/budgets`, `/loans`, `/settings`) are a `StatefulShellRoute.indexedStack` wrapped in `MainLayout`, each with its own navigator key so per-tab navigation state is preserved when switching tabs. Detail/edit/add screens (e.g. `/add_transaction`, `/transaction_details/:transactionId`) are top-level routes outside the shell so they cover the bottom nav.

### Theming (`lib/core/theme/theme.dart`, `theme_provider.dart`)

- Two theming paths selected by `colorSchemeProvider` (persisted string in `SharedPreferences`): `'original'` uses the hand-authored `MaterialTheme` in `theme.dart`; any other value is looked up in `FlexScheme.values` and rendered via `flex_color_scheme`'s `FlexThemeData`.
- `themeModeProvider` (light/dark/system) and `appBackgroundProvider` (rotating background image from `assets/images/`) are separate persisted `Notifier`s in the same file, following the same read-from-`SharedPreferences`-in-`build()`, write-through-on-mutation pattern.

### Background work & notifications

- `workmanager` registers a periodic `"daily_check_task"` in `main.dart`; `lib/core/background/background_task_handler.dart` is the isolate entrypoint (`callbackDispatcher`) that runs outside the normal widget/provider tree.
- `lib/core/notifications/notification_service.dart` wraps `flutter_local_notifications`; feature-level "watcher" classes (`budget_notification_watcher.dart`, `savings_notification_watcher.dart`) contain the logic that decides *when* to notify (budget thresholds, savings goal progress), separate from the notification-sending mechanics.

## Notes

- No test suite currently exists — there is no `test/` directory.
- UI strings, comments, and the README are primarily in Spanish; match that convention for user-facing text in this app.
