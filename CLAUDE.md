# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ajiriwa Mobile is a Flutter job board app for ajiriwa.net. It supports Android, iOS, Web, Windows, and macOS.

## Commands

```bash
# Run the app
flutter run

# Build
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web

# Test
flutter test               # All tests
flutter test test/path/to/test.dart  # Single test file

# Analyze & format
flutter analyze
flutter format lib/

# Code generation (json_serializable, hive_generator)
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch
```

## Architecture

The app uses **Clean Architecture** organized by feature under `lib/features/`. Each feature follows this layering:

```
feature/
├── data/
│   ├── datasources/     # Remote/Local data access (abstract + impl)
│   ├── models/          # JSON-serializable models (extend domain entities)
│   └── repositories/    # Concrete repository implementations
├── domain/
│   ├── entities/        # Pure Dart business objects
│   ├── repositories/    # Abstract repository contracts
│   └── usecases/        # (optional) Use case classes
└── presentation/
    ├── bloc/            # BLoC: event, state, bloc files
    └── screens/         # Widgets and screens
```

**Core modules** in `lib/core/`:
- `di/injection_container.dart` — GetIt service locator; all BLoCs, repos, datasources registered here; call `init()` at startup
- `navigation/app_router.dart` — GoRouter config with named routes; auth redirect logic; shell routes wrap bottom-nav tabs
- `network/api_client.dart` — Dio wrapper; base URL `https://www.ajiriwa.net/api/v1`; adds Bearer token and `candidate_id` query param automatically; maps DioException to custom exceptions
- `error/failures.dart` & `exceptions.dart` — Failure hierarchy used with `Either<Failure, T>` (dartz) throughout the data layer
- `theme/app_theme.dart` — Emerald Green branding (#10B981)

## Key Patterns

**State management**: `flutter_bloc` v8. All BLoCs registered as factories in the DI container. Pattern: Event → BLoC → State → UI rebuild via `BlocBuilder`/`BlocListener`.

**Error handling**: Repository methods return `Either<Failure, T>`. BLoCs convert failures to error states. Never throw directly from repositories.

**Auth**: Token stored in `FlutterSecureStorage`. `AuthBloc` manages auth state app-wide. Unauthenticated users are redirected to `/login` via GoRouter's `redirect` callback. Multi-profile support via `candidate_id` (stored in SharedPreferences, injected per-request).

**Navigation**: GoRouter with named routes. Bottom nav (Dashboard, Jobs, Applications, Saved, Profile) uses `ShellRoute`. Auth screens (login, register, forgot password) are outside the shell.

**Data persistence**: Hive for local NoSQL, SharedPreferences for simple key-value, FlutterSecureStorage for tokens.

## Features

| Feature | Path |
|---|---|
| Auth | `lib/features/auth/` |
| Dashboard | `lib/features/dashboard/` |
| Jobs (browse, search, apply) | `lib/features/jobs/` |
| My Applications | `lib/features/applications/` |
| Resume/CV editing | `lib/features/resume/` |
| CV Optimization (AI) | `lib/features/cv_optimization/` |
| Saved Jobs | `lib/features/saved_jobs/` |
| Profile & Settings | `lib/features/profile/` |

## Known Issues / Notes

- Firebase Crashlytics and Google Sign-In are currently commented out due to dependency/build issues
- Apple Sign-In is integrated
- `mobile-app-prompt.md` in the repo root contains the detailed design spec with API contracts and UX patterns — consult it when implementing new features
