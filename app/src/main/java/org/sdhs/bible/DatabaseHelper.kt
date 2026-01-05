package org.sdhs.bible

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import java.io.File
import java.io.FileOutputStream

class DatabaseHelper(private val context: Context) : SQLiteOpenHelper(context, DB_NAME, null, DB_VERSION) {

    companion object {
        private const val DB_NAME = "sdhs_bible.db"
        private const val DB_VERSION = 1
        
        private val BOOK_NAMES = arrayOf(
            "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy",
            "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
            "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra",
            "Nehemiah", "Esther", "Job", "Psalms", "Proverbs",
            "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations",
            "Ezekiel", "Daniel", "Hosea", "Joel", "Amos",
            "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
            "Zephaniah", "Haggai", "Zechariah", "Malachi",
            "Matthew", "Mark", "Luke", "John", "Acts of the Apostles",
            "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians",
            "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy",
            "2 Timothy", "Titus", "Philemon", "Hebrews", "James",
            "1 Peter", "2 Peter", "1 John", "2 John", "3 John",
            "Jude", "Revelation"
        )
        
        private val JEWISH_BOOK_ORDER = intArrayOf(
            0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 23, 24, 26, 28, 29, 30,
            31, 32, 33, 34, 35, 36, 37, 38, 39, 19, 20, 18, 22, 8, 25, 21,
            17, 27, 15, 16, 13, 14
        )
    }

    init {
        copyDatabaseIfNeeded()
    }

    private fun copyDatabaseIfNeeded() {
        val dbFile = context.getDatabasePath(DB_NAME)
        if (!dbFile.exists()) {
            dbFile.parentFile?.mkdirs()
            context.assets.open(DB_NAME).use { input ->
                FileOutputStream(dbFile).use { output ->
                    input.copyTo(output)
                }
            }
        }
    }

    override fun onCreate(db: SQLiteDatabase?) {
        // Database is copied from assets, no creation needed
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        // Handle future upgrades
    }

    fun getBookName(bookNumber: Int): String {
        return if (bookNumber in 1..BOOK_NAMES.size) {
            BOOK_NAMES[bookNumber - 1]
        } else {
            "Unknown"
        }
    }

    fun getBookOrder(bookNumber: Int, useJewishOrder: Boolean): Int {
        return if (useJewishOrder && bookNumber in 1..39) {
            JEWISH_BOOK_ORDER[bookNumber]
        } else {
            bookNumber
        }
    }

    fun getChapterText(tableName: String, bookNumber: Int, chapterNumber: Int, alignRight: Boolean): String {
        val db = readableDatabase
        val text = StringBuilder()
        
        val cursor = db.rawQuery(
            "SELECT verseNr, text FROM $tableName WHERE bookNr = ? AND chapterNr = ? ORDER BY verseNr",
            arrayOf(bookNumber.toString(), chapterNumber.toString())
        )
        
        cursor.use {
            while (it.moveToNext()) {
                val verseNr = it.getString(0)
                val verseText = it.getString(1)
                
                if (alignRight) {
                    text.append("\u202B$verseNr $verseText\r\n")
                } else {
                    text.append("$verseNr $verseText\r\n")
                }
            }
        }
        
        return if (text.isEmpty()) {
            val testament = if (bookNumber in 1..39) "Tanakh" else "New Testament"
            "Text not available in current translation. Please browse to $testament or load another language."
        } else {
            var result = text.toString()
            // Handle Yiddish special characters
            if (tableName == "bibleYiddish") {
                result = result.replace("{dn", "").replace("}", "").replace("  ", " ")
            }
            result
        }
    }

    fun getChapterCount(tableName: String, bookNumber: Int): Int {
        val db = readableDatabase
        var count = 0
        
        val cursor = db.rawQuery(
            "SELECT DISTINCT chapterNr FROM $tableName WHERE bookNr = ?",
            arrayOf(bookNumber.toString())
        )
        
        cursor.use {
            count = it.count
        }
        
        return count
    }
}
