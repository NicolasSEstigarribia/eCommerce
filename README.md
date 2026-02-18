# eCommerce – Flutter Technical Challenge

A Flutter application that displays a list of posts with search functionality, post detail with comments, and like persistence. Built following **Clean Architecture** principles.

---

## Architecture

The project is organized in 4 layers with strict dependency rules (outer layers depend on inner layers, never the reverse):

```
lib/
├── core/           # Constants, exceptions, failures (no dependencies)
├── domain/         # Entities, repository interfaces, data source interfaces
├── data/           # Repository & data source implementations, models
├── injector/       # Dependency injection (GetIt)
└── presentation/   # BLoC, pages, widgets
```

### Dependency Rule

`presentation` → `domain` ← `data`

The `domain` layer has **zero** Flutter/external dependencies. The `data` layer implements the interfaces defined in `domain`.

### Key Decisions

- **BLoC** for state management — clear separation of events/states, testable.
- **Comments via MethodChannel** — fetched natively on iOS (Swift) and Android (Kotlin), as required.
- **Posts via Dio** — fetched from Flutter with timeout and retry logic.
- **Likes persisted** with `SharedPreferences` — survives app restarts.
- **Debounce (500ms)** on the search field to avoid excessive BLoC events.
- **Retry logic** — `getPosts` retries up to 2 times on network failure before returning an error.
- **Barrel files** per layer (`barrel_core.dart`, `barrel_domain.dart`, etc.) to simplify imports.

---

## Features

- 📋 Post list with search/filter
- 🔍 Debounced search (500ms)
- ❤️ Like/unlike posts (persisted locally)
- 💬 Comments loaded natively per platform
- ⚠️ Loading, error (with retry), and empty states
- 🔄 Automatic retry on network failure (up to 2 retries)

---

## Dependencies

| Package              | Purpose                                        |
| -------------------- | ---------------------------------------------- |
| `flutter_bloc`       | State management                               |
| `get_it`             | Dependency injection                           |
| `equatable`          | Value equality for entities/states             |
| `dartz`              | Functional types (`Either`) for error handling |
| `dio`                | HTTP client for REST API                       |
| `shared_preferences` | Local persistence for likes                    |
| `bloc_test`          | BLoC unit testing utilities                    |
| `mocktail`           | Mocking for unit and widget tests              |

---

## Running the Project

### Prerequisites

- Flutter SDK ≥ 3.9.2
- Xcode (for iOS) or Android Studio (for Android)

### Steps

```bash
# 1. Clone the repository
git clone <repo-url>
cd ecommerce

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run

# 4. Run tests
flutter test
```

---

## APIs Used

| Resource | URL                                                         |
| -------- | ----------------------------------------------------------- |
| Posts    | `https://jsonplaceholder.typicode.com/posts`                |
| Comments | `https://jsonplaceholder.typicode.com/comments?postId={id}` |

> **Note:** Comments are fetched natively via `MethodChannel` (`com.example.ecommerce/comments`). The Flutter side calls the native layer, which performs the HTTP request in Swift (iOS) and Kotlin (Android).

---

## Testing

The project includes **unit tests** and **widget tests**:

```
test/
├── data/
│   ├── datasources/   # PostRemoteDataSource, PostLocalDataSource
│   └── repositories/  # PostRepositoryImpl
└── presentation/
    ├── bloc/          # PostBloc, CommentBloc
    └── pages/         # PostListPage widget tests
```

Run all tests:

```bash
flutter test
```
