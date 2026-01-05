# Quick Start Guide - SDHS Bible Android

Get the Android Bible reader running in 5 minutes!

## 🚀 Quick Setup

### Option 1: Android Studio (Recommended)

1. **Clone the repo**
   ```bash
   git clone https://github.com/DieLewe/SDHS-Bible.git
   cd SDHS-Bible
   ```

2. **Open in Android Studio**
   - File → Open → Select the `SDHS-Bible` folder
   - Wait for Gradle sync (automatic)

3. **Run the app**
   - Click the green "Run" button (▶️)
   - Select your device/emulator
   - Done! 🎉

### Option 2: Command Line

```bash
# Clone
git clone https://github.com/DieLewe/SDHS-Bible.git
cd SDHS-Bible

# Build
./gradlew assembleDebug

# Install (device connected via USB)
adb install app/build/outputs/apk/debug/app-debug.apk
```

## 📱 What You Get

- ✅ Full Bible reader with 4 translations
- ✅ Hebrew, Yiddish, and English support
- ✅ Swipe to navigate chapters
- ✅ Pinch to adjust text size
- ✅ Bookmarks with persistence
- ✅ RTL text support

## 🎯 Key Features to Try

1. **Swipe Left/Right** - Navigate between chapters
2. **Pinch** - Zoom text in/out (20-45pt)
3. **Star Button** - Add/remove bookmarks
4. **Menu → Select Chapter** - Jump to any book/chapter
5. **Menu → Bookmarks** - View saved locations
6. **Menu → Select Translation** - Switch languages

## 📂 Project Structure

```
app/src/main/
├── java/org/sdhs/bible/
│   ├── MainActivity.kt          👈 Main reading screen
│   ├── BookmarkActivity.kt      👈 Bookmark list
│   ├── ChapterPickerActivity.kt 👈 Navigation picker
│   ├── DatabaseHelper.kt        👈 Bible data access
│   └── ConfigManager.kt         👈 Settings storage
└── assets/
    └── sdhs_bible.db           👈 Bible database (23MB)
```

## 🔧 Common Tasks

### Change App Icon
```
app/src/main/res/mipmap-*/ic_launcher.png
```

### Add New Translation
1. Add table to `sdhs_bible.db`
2. Update `ConfigManager.getTranslationConfig()`
3. Add to translation picker in `MainActivity`

### Modify Colors/Theme
```
app/src/main/res/values/colors.xml
app/src/main/res/values/themes.xml
```

## 🐛 Troubleshooting

**Build fails?**
- Run: `./gradlew clean build`
- Check: Java 8+ installed
- Verify: Android SDK API 21+ available

**App crashes?**
- Check: Database file in assets folder
- Enable: USB Debugging on device
- View: LogCat in Android Studio

**Gestures not working?**
- Test on physical device (not emulator)
- Check: Touch listener on scroll view
- Try: Different gesture speed/distance

## 📚 Documentation

- **README.md** - Overview and features
- **INSTALL.md** - Detailed build instructions
- **FEATURES.md** - iOS vs Android comparison
- **PROJECT-SUMMARY.md** - Complete technical summary

## 🎓 Development Tips

1. **Live Reload**: Use Android Studio's "Apply Changes" (⚡)
2. **Layout Preview**: Android Studio shows XML layouts visually
3. **Debugging**: Set breakpoints, use LogCat, inspect variables
4. **Testing**: Use emulators or physical devices

## 📦 Building Release APK

```bash
# Generate signing key (first time only)
keytool -genkey -v -keystore release.keystore -alias sdhs -keyalg RSA -keysize 2048 -validity 10000

# Build signed release
./gradlew assembleRelease

# Find APK
app/build/outputs/apk/release/app-release.apk
```

## 🌐 Tech Stack

- **Language**: Kotlin
- **UI**: Material Design Components
- **Database**: SQLite
- **Storage**: SharedPreferences + Gson
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 33 (Android 13)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing`
5. Submit pull request

## 📝 License

Copyright © 2012-2024 The Society for Distributing Hebrew Scriptures

## 💬 Support

Need help? Open an issue on GitHub with:
- Device model and Android version
- Steps to reproduce the problem
- Screenshots if applicable
- LogCat output (if crash)

---

**Happy Coding! 🎉**

For detailed information, see [INSTALL.md](INSTALL.md) and [FEATURES.md](FEATURES.md)
