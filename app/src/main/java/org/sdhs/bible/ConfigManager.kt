package org.sdhs.bible

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class ConfigManager(context: Context) {
    
    private val prefs: SharedPreferences = context.getSharedPreferences("bible_config", Context.MODE_PRIVATE)
    private val gson = Gson()
    
    companion object {
        private const val KEY_CURRENT_LOCATION = "current_location"
        private const val KEY_PREVIOUS_LOCATION = "previous_location"
        private const val KEY_NEXT_LOCATION = "next_location"
        private const val KEY_CURRENT_TRANSLATION = "current_translation"
        private const val KEY_FONT_SIZE = "font_size"
        private const val KEY_BOOKMARKS = "bookmarks"
        private const val KEY_USE_JEWISH_ORDER = "use_jewish_order"
        
        const val DEFAULT_TRANSLATION = "עִבְרִית תַּנַ״ךְ"
        const val DEFAULT_FONT_SIZE = 20
    }
    
    fun getCurrentLocation(): String {
        return prefs.getString(KEY_CURRENT_LOCATION, "01Otabkey1tabkey1") ?: "01Otabkey1tabkey1"
    }
    
    fun setCurrentLocation(location: String) {
        prefs.edit().putString(KEY_CURRENT_LOCATION, location).apply()
    }
    
    fun getPreviousLocation(): String {
        return prefs.getString(KEY_PREVIOUS_LOCATION, "01Otabkey1tabkey1") ?: "01Otabkey1tabkey1"
    }
    
    fun setPreviousLocation(location: String) {
        prefs.edit().putString(KEY_PREVIOUS_LOCATION, location).apply()
    }
    
    fun getNextLocation(): String {
        return prefs.getString(KEY_NEXT_LOCATION, "01Otabkey2tabkey1") ?: "01Otabkey2tabkey1"
    }
    
    fun setNextLocation(location: String) {
        prefs.edit().putString(KEY_NEXT_LOCATION, location).apply()
    }
    
    fun setLocations(previous: String, current: String, next: String) {
        prefs.edit()
            .putString(KEY_PREVIOUS_LOCATION, previous)
            .putString(KEY_CURRENT_LOCATION, current)
            .putString(KEY_NEXT_LOCATION, next)
            .apply()
    }
    
    fun getCurrentTranslation(): String {
        return prefs.getString(KEY_CURRENT_TRANSLATION, DEFAULT_TRANSLATION) ?: DEFAULT_TRANSLATION
    }
    
    fun setCurrentTranslation(translation: String) {
        prefs.edit().putString(KEY_CURRENT_TRANSLATION, translation).apply()
    }
    
    fun getFontSize(): Int {
        return prefs.getInt(KEY_FONT_SIZE, DEFAULT_FONT_SIZE)
    }
    
    fun setFontSize(size: Int) {
        prefs.edit().putInt(KEY_FONT_SIZE, size).apply()
    }
    
    fun getBookmarks(): MutableMap<String, String> {
        val json = prefs.getString(KEY_BOOKMARKS, null)
        return if (json != null) {
            val type = object : TypeToken<MutableMap<String, String>>() {}.type
            gson.fromJson(json, type)
        } else {
            mutableMapOf()
        }
    }
    
    fun setBookmarks(bookmarks: Map<String, String>) {
        val json = gson.toJson(bookmarks)
        prefs.edit().putString(KEY_BOOKMARKS, json).apply()
    }
    
    fun addBookmark(location: String, displayText: String) {
        val bookmarks = getBookmarks()
        bookmarks[location] = displayText
        setBookmarks(bookmarks)
    }
    
    fun removeBookmark(location: String) {
        val bookmarks = getBookmarks()
        bookmarks.remove(location)
        setBookmarks(bookmarks)
    }
    
    fun hasBookmark(location: String): Boolean {
        return getBookmarks().containsKey(location)
    }
    
    fun getUseJewishOrder(): Boolean {
        return prefs.getBoolean(KEY_USE_JEWISH_ORDER, true)
    }
    
    fun setUseJewishOrder(use: Boolean) {
        prefs.edit().putBoolean(KEY_USE_JEWISH_ORDER, use).apply()
    }
    
    fun getTranslationConfig(translationName: String): Translation {
        return when (translationName) {
            "עִבְרִית תַּנַ״ךְ" -> Translation(translationName, "bibleHebrew", true, "Times New Roman", getFontSize())
            "ייִדיש תנ״ך" -> Translation(translationName, "bibleYiddish", true, "Times New Roman", getFontSize())
            "עִבְרִית הברית החדשה" -> Translation(translationName, "bibleHebrewSGNT2012", true, "Times New Roman", getFontSize())
            "English" -> Translation(translationName, "bibleKJV", false, "Times New Roman", getFontSize())
            else -> Translation(DEFAULT_TRANSLATION, "bibleHebrew", true, "Times New Roman", getFontSize())
        }
    }
}
