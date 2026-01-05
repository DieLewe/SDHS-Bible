# Android Bible Reader - Installation and Build Guide

## For Users (Installing the App)

### Option 1: Install from APK
1. Download the APK file from the releases page
2. On your Android device, go to Settings > Security
3. Enable "Unknown Sources" or "Install from Unknown Sources"
4. Open the downloaded APK file
5. Follow the installation prompts

### Option 2: Build from Source
Follow the developer instructions below to build the app yourself.

## For Developers (Building from Source)

### Prerequisites
- **Android Studio**: Arctic Fox (2020.3.1) or later
- **Java Development Kit (JDK)**: Version 8 or later
- **Android SDK**: API Level 21 (Android 5.0) or higher
- **Gradle**: Version 8.0 (included via wrapper)

### Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/DieLewe/SDHS-Bible.git
   cd SDHS-Bible
   ```

2. **Open in Android Studio**
   - Launch Android Studio
   - Select "Open an Existing Project"
   - Navigate to the cloned repository folder
   - Click "OK"

3. **Sync Project with Gradle**
   - Android Studio will automatically prompt to sync Gradle
   - If not, click "File" > "Sync Project with Gradle Files"
   - Wait for the sync to complete

4. **Build the Project**
   
   **Option A: Using Android Studio**
   - Click "Build" > "Build Bundle(s) / APK(s)" > "Build APK(s)"
   - Wait for the build to complete
   - APK will be in `app/build/outputs/apk/debug/`

   **Option B: Using Command Line**
   ```bash
   # For Debug Build
   ./gradlew assembleDebug
   
   # For Release Build
   ./gradlew assembleRelease
   ```

5. **Run the App**
   
   **On an Emulator:**
   - Click "Run" > "Run 'app'"
   - Select an emulator or create a new one
   - Click "OK"

   **On a Physical Device:**
   - Enable Developer Options on your device
   - Enable USB Debugging
   - Connect device via USB
   - Click "Run" > "Run 'app'"
   - Select your device

### Project Structure

```
SDHS-Bible/
├── app/
│   ├── build.gradle              # App-level Gradle configuration
│   ├── src/
│   │   └── main/
│   │       ├── AndroidManifest.xml
│   │       ├── java/org/sdhs/bible/
│   │       │   ├── MainActivity.kt
│   │       │   ├── BookmarkActivity.kt
│   │       │   ├── ChapterPickerActivity.kt
│   │       │   ├── DatabaseHelper.kt
│   │       │   ├── ConfigManager.kt
│   │       │   └── BibleModels.kt
│   │       ├── res/              # Resources (layouts, strings, etc.)
│   │       └── assets/           # Database file
├── build.gradle                  # Project-level Gradle configuration
├── settings.gradle
└── gradle/wrapper/               # Gradle wrapper files
```

### Troubleshooting

**Issue: Gradle Sync Failed**
- Solution: Check your internet connection and try again
- Verify you have the correct version of Android Studio

**Issue: Database not found**
- Solution: Ensure `sdhs_bible.db` is in `app/src/main/assets/`
- Clean and rebuild the project: Build > Clean Project, then Build > Rebuild Project

**Issue: App crashes on startup**
- Solution: Check LogCat for error messages
- Verify minimum SDK version is compatible with your device

**Issue: Text not displaying correctly**
- Solution: Ensure font support is available on your device
- Hebrew/Yiddish text requires RTL (Right-to-Left) support

### Development Tips

1. **Testing on Different Devices**
   - Test on both phones and tablets
   - Test with different screen sizes and densities
   - Test RTL text support with Hebrew/Yiddish translations

2. **Debugging**
   - Use LogCat to view application logs
   - Set breakpoints in code for step-by-step debugging
   - Use Layout Inspector to debug UI issues

3. **Performance**
   - The database is loaded on first launch
   - Subsequent launches use the cached database
   - Font size changes are saved immediately

### Building a Release APK

1. **Generate a Signing Key** (first time only)
   ```bash
   keytool -genkey -v -keystore sdhs-bible.keystore -alias sdhs-bible -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **Configure Signing in `app/build.gradle`**
   ```gradle
   android {
       signingConfigs {
           release {
               storeFile file("path/to/sdhs-bible.keystore")
               storePassword "your-password"
               keyAlias "sdhs-bible"
               keyPassword "your-password"
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
               minifyEnabled false
               proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
           }
       }
   }
   ```

3. **Build Release APK**
   ```bash
   ./gradlew assembleRelease
   ```
   
   The signed APK will be in `app/build/outputs/apk/release/`

### Contributing

If you'd like to contribute to the project:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Support

For issues or questions:
- Open an issue on GitHub
- Provide device information and Android version
- Include LogCat output if applicable

### License

Copyright (c) 2012-2024 The Society for Distributing Hebrew Scriptures. All rights reserved.
