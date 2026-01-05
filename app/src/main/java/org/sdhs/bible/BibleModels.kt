package org.sdhs.bible

data class BibleLocation(
    val bookNumber: Int,
    val testament: String, // "O" for Old Testament, "N" for New Testament
    val chapterNumber: Int,
    val verseNumber: Int
) {
    fun toLocationString(): String {
        return String.format("%02d%stabkey%dtabkey%d", bookNumber, testament, chapterNumber, verseNumber)
    }

    companion object {
        fun fromLocationString(location: String): BibleLocation {
            val parts = location.replace("tabkey", "\t").split("\t")
            val bookStr = parts[0]
            val bookNumber = bookStr.substring(0, 2).toInt()
            val testament = if (bookStr.length > 2) bookStr.substring(2) else "O"
            val chapterNumber = if (parts.size > 1) parts[1].toInt() else 1
            val verseNumber = if (parts.size > 2) parts[2].toInt() else 1
            return BibleLocation(bookNumber, testament, chapterNumber, verseNumber)
        }
    }
}

data class BibleVerse(
    val bookNumber: Int,
    val chapterNumber: Int,
    val verseNumber: Int,
    val text: String
)

data class Translation(
    val name: String,
    val tableName: String,
    val alignRight: Boolean,
    val fontName: String,
    val fontSize: Int
)

data class Bookmark(
    val location: String,
    val displayText: String
)
