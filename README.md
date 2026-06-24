# Al Mubarak Quotation — Flutter (Offline Android App)

Pure-offline Flutter port of the web Quotation Calculator. Same formulas as
`src/lib/calculations.ts`. No network, no backend. Last quotation is saved
locally with `shared_preferences`.

## What's inside

```
flutter_app/
├── pubspec.yaml
├── analysis_options.yaml
├── assets/logo.png
└── lib/
    ├── main.dart              # App entry
    ├── quotation_screen.dart  # Form UI (same fields as web)
    ├── result_card.dart       # Result UI + Copy / Share / PDF buttons
    ├── calculations.dart      # Calculation logic (1:1 port)
    ├── storage.dart           # Offline save/load
    └── pdf_generator.dart     # Landscape A4 PDF
```

## Build the APK (VS Code or Android Studio)

### One-time setup
1. Install **Flutter SDK** → https://docs.flutter.dev/get-started/install (3.19+)
2. Install **Android Studio** (just for SDK + emulator)
   - Open it once → SDK Manager → install **Android SDK Platform 34** and
     **Android SDK Command-line Tools**
3. Accept licenses:
   ```bash
   flutter doctor --android-licenses
   flutter doctor
   ```
4. (VS Code) Install the **Flutter** and **Dart** extensions.

### Build steps
Open a terminal in the `flutter_app/` folder and run:

```bash
# Generate the android/ ios/ platform folders (one-time)
flutter create --org com.almubarak --project-name almubarak_quotation .

# Install dependencies
flutter pub get

# Debug APK (fast, larger)
flutter build apk --debug
# → build/app/outputs/flutter-apk/app-debug.apk

# Release APK (smaller, what you ship)
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk

# Split per-architecture (smallest size)
flutter build apk --release --split-per-abi
```

In **VS Code**: open the `flutter_app` folder, press `F5` to run on a connected
device/emulator, or run **Command Palette → Flutter: Build APK**.

In **Android Studio**: open the `flutter_app` folder, then
**Build → Flutter → Build APK**.

## Notes
- The app is fully offline. The PDF is generated on-device.
- The "PDF" button opens the system print dialog — choose **Save as PDF** or
  print to a connected printer. Share/Copy use the OS share sheet and clipboard.
- All calculation formulas (depth × 150/75, basement +1200, full-basement
  ÷3 depth effect, plinth beam Rs. 150/Sqft, single storey +600) are
  identical to the web version.
