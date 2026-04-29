# MCBE Modpack Manager - Build Guide

## Prerequisites

- **Flutter SDK**: >=3.4.0 <4.0.0
- **Android SDK**: Compile API 35, Min API 21
- **Android Studio** (or VS Code with Flutter extension)
- **Java JDK**: 17+ (for AGP 8.x)

## Setup

```bash
# Clone the repository
git clone https://github.com/your-org/modpack_mcbe_flutter.git
cd modpack_mcbe_flutter

# Install dependencies
flutter pub get

# Copy signing config (for release builds only)
cp key.properties.example android/key.properties
# Edit android/key.properties with your keystore details
```

## Development

```bash
# Run in debug mode
flutter run

# Run on specific device
flutter run -d <device_id>

# Run with release optimizations
flutter run --release
```

## Building

### Android APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs by ABI
flutter build apk --split-per-abi --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Linting

```bash
flutter analyze
```

## CI/CD

This project uses GitHub Actions for automated builds:

- **Build** (`.github/workflows/build.yml`): Triggered on push/PR/tag
- **Release** (`.github/workflows/release.yml`): Manual trigger for version bump
- **Nightly** (`.github/workflows/nightly.yml`): Daily canary builds

## Project Structure

```
lib/
├── main.dart          # App entry point
├── app.dart            # MaterialApp configuration
├── models/             # Data models
├── services/           # API, auth, modpack services
├── screens/            # UI screens
├── widgets/            # Reusable components
└── theme/              # App theme configuration
```

## Troubleshooting

### Gradle Build Failures
- Ensure you have the correct Android SDK installed (API 35)
- Run `flutter clean` and `flutter pub get`
- Delete `android/.gradle` and rebuild

### Keystore Issues
- Ensure `key.properties` is properly configured in `android/`
- Verify the keystore file path is absolute

### Network Issues (CurseForge API)
- The API uses CurseForge's public endpoints
- Rate limits apply; add appropriate delays if needed
