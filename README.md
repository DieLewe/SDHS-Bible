# SDHS Bible - Android Bible Reader

An Android Bible reader application with support for multiple translations including Hebrew, Yiddish, and English texts.

## Features

- **Multiple Translations**: 
  - Hebrew Tanakh (עִבְרִית תַּנַ״ךְ)
  - Yiddish Tanakh (ייִדיש תנ״ך)
  - Hebrew New Testament (עִבְרִית הברית החדשה)
  - English (KJV)

- **Navigation**:
  - Swipe left/right to navigate between chapters
  - Chapter/Book picker for quick navigation
  - Smooth page transitions

- **Bookmarks**:
  - Save and manage bookmarks
  - Quick access to bookmarked chapters
  - Visual indicator for bookmarked locations

- **Text Customization**:
  - Pinch-to-zoom for font size adjustment
  - Right-to-left text support for Hebrew and Yiddish
  - Adjustable font size (20-45pt)

- **Jewish Book Order**:
  - Optional Jewish book ordering for Tanakh
  - Configurable in settings

## Building the App

### Requirements

- Android Studio Arctic Fox or later
- Android SDK API 21+ (Android 5.0 Lollipop)
- Kotlin 1.8.0+

### Build Instructions

1. Clone the repository
2. Open the project in Android Studio
3. Let Gradle sync the project
4. Build and run on your device or emulator

### Command Line Build

```bash
./gradlew assembleDebug
```

The APK will be generated in `app/build/outputs/apk/debug/`

## Project Structure

```
app/
├── src/main/
│   ├── java/org/sdhs/bible/
│   │   ├── MainActivity.kt              # Main reading activity
│   │   ├── BookmarkActivity.kt          # Bookmark management
│   │   ├── ChapterPickerActivity.kt     # Chapter selection
│   │   ├── DatabaseHelper.kt            # SQLite database access
│   │   ├── ConfigManager.kt             # Settings and preferences
│   │   └── BibleModels.kt               # Data models
│   ├── res/
│   │   ├── layout/                      # XML layouts
│   │   ├── values/                      # Strings, colors, themes
│   │   └── menu/                        # Menu definitions
│   └── assets/
│       └── sdhs_bible.db                # Bible text database
└── build.gradle                         # App dependencies
```

## Database Schema

The app uses an SQLite database with the following structure:

- Tables: `bibleHebrew`, `bibleYiddish`, `bibleHebrewSGNT2012`, `bibleKJV`
- Columns: `bookNr`, `chapterNr`, `verseNr`, `text`

## Technical Details

- **Language**: Kotlin
- **Minimum SDK**: 21 (Android 5.0)
- **Target SDK**: 33 (Android 13)
- **Architecture**: Single Activity with multiple screens
- **Database**: SQLite
- **UI Components**: Material Design Components, RecyclerView
- **Persistence**: SharedPreferences with Gson for complex data

## Original iOS Version

This Android app is a port of the original iOS application, maintaining all the same features and functionality.

## License

Copyright (c) 2012-2024 The Society for Distributing Hebrew Scriptures. All rights reserved.
