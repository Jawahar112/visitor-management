# Visitor Management

A Flutter mobile application for registering, tracking, and managing visitors. The app provides a dashboard for daily visitor activity, searchable visitor records, QR-code visitor passes, and check-in/check-out workflows.

## Features

- Dashboard with total visitors, currently checked-in visitors, and checked-out visitors for today
- Register and edit visitor details
- Visitor types: Customer, Vendor, and Other
- Project selection and visit-purpose tracking
- Search visitors by name or mobile number
- Filter visitors by status
- Generate a QR code for each visitor
- Scan a visitor QR code to open their record
- Check visitors in and out
- Delete visitor records
- Loading, empty, validation, and error states
- Configurable REST API base URL

## Tech stack

- Flutter and Dart
- Riverpod for state management
- Dio for HTTP requests
- GoRouter for navigation
- `qr_flutter` for QR-code generation
- `mobile_scanner` for QR-code scanning
- Shared Preferences for the local data-source implementation

## Requirements

- Flutter SDK 3.47.0
- Dart SDK 3.9.0 or later
- Android Studio or VS Code with the Flutter and Dart extensions
- An Android or iOS device/emulator for camera-based QR scanning

Check the installed Flutter version with:

```bash
flutter --version
```

The project is configured for Dart `^3.9.0` in [`pubspec.yaml`](pubspec.yaml).

## Getting started

1. Clone the repository and enter the project directory:

   ```bash
   git clone https://github.com/Jawahar112/visitor-management.git
   cd visitor-management
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the application:

   ```bash
   flutter run
   ```

   To run on a specific device, list available devices and pass the device ID:

   ```bash
   flutter devices
   flutter run -d <device-id>
   ```

## API configuration

The app uses a REST API with the following visitor endpoints:

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/visitors` | List visitors |
| `GET` | `/visitors/{id}` | Get one visitor |
| `POST` | `/visitors` | Register a visitor |
| `PUT` | `/visitors/{id}` | Update a visitor |
| `DELETE` | `/visitors/{id}` | Delete a visitor |

By default, the app uses the following MockAPI endpoint configured in [`lib/core/app_config.dart`](lib/core/app_config.dart):

```text
https://6ae2b589bbb54129229a4f5a.mockapi.io/api/v1
```

The visitor collection is:

```text
https://6ae2b589bbb54129229a4f5a.mockapi.io/api/v1/visitors
```

The app uses this MockAPI resource for development and demonstration. MockAPI generates visitor IDs when records are created. Override the base URL at runtime with `--dart-define`:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://example.com/api/v1
```

The API must support the visitor resource and return JSON objects compatible with the visitor model.

## State management

The app uses **Riverpod** for state management.

- `visitorListProvider` is the primary `NotifierProvider` for loading and maintaining visitor records.
- `VisitorListNotifier` handles registration, updates, deletion, QR-code lookup, check-in, check-out, loading, and refresh operations.
- `visitorRepositoryProvider` provides the repository abstraction between the UI and the data source.
- `visitorDataSourceProvider` supplies the remote MockAPI data source.
- `filteredVisitorsProvider` derives the visible visitor list from the current search query and status filter.
- `dashboardStatsProvider` derives dashboard totals from the current visitor state.
- `busyVisitorIdsProvider` prevents duplicate check-in/check-out operations for the same visitor.

The data flow is:

```text
Screen
  ↓ watches or updates
Riverpod provider / notifier
  ↓ calls
Repository
  ↓ calls
Remote data source
  ↓
MockAPI
```

`AsyncValue` is used to represent loading, success, and error states. This keeps loading indicators, retry actions, and error messages consistent across the dashboard and visitor list screens.

## QR scanning permissions

QR scanning requires camera permission. Android declares the camera permission in `android/app/src/main/AndroidManifest.xml`; the user must also grant permission when prompted by the operating system.

For reliable scanning, run the app on a physical device or an emulator with camera support.

## Project structure

```text
lib/
├── common/          Reusable widgets and utilities
├── core/            App configuration, routing, theme, networking, errors
├── data/            Data sources, models, and repository implementations
├── domain/          Entities and repository contracts
├── presentation/    Screens, providers, and feature widgets
└── main.dart        Application entry point
```

The application follows a layered structure:

```text
Presentation → Domain → Data → REST API
```

## Development commands

Format Dart files:

```bash
dart format lib
```

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build an Android APK:

```bash
flutter build apk
```

## Notes

- The QR code contains the visitor ID used to retrieve the visitor record.
- The scanner accepts QR values containing letters, numbers, underscores, and hyphens.
- The default API is remote, so the device or emulator needs network access.
- The local data-source implementation is available for offline or development use, but the default provider currently uses the remote data source.

## License

No license has been specified for this project yet.
