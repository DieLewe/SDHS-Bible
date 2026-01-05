package org.sdhs.bible

import android.content.Intent
import android.os.Bundle
import android.view.GestureDetector
import android.view.Menu
import android.view.MenuItem
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.GestureDetectorCompat
import com.google.android.material.floatingactionbutton.FloatingActionButton
import kotlin.math.abs

class MainActivity : AppCompatActivity() {

    private lateinit var bibleTextView: TextView
    private lateinit var locationLabel: TextView
    private lateinit var bookmarkFab: FloatingActionButton
    
    private lateinit var databaseHelper: DatabaseHelper
    private lateinit var configManager: ConfigManager
    private lateinit var gestureDetector: GestureDetectorCompat
    private lateinit var scaleGestureDetector: ScaleGestureDetector
    
    private var currentLocation: BibleLocation? = null
    private var currentTranslation: Translation? = null
    private var fontSize = 20

    companion object {
        private const val SWIPE_THRESHOLD = 100
        private const val SWIPE_VELOCITY_THRESHOLD = 100
        const val REQUEST_CODE_PICKER = 1
        const val REQUEST_CODE_BOOKMARK = 2
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Initialize views
        bibleTextView = findViewById(R.id.bibleTextView)
        locationLabel = findViewById(R.id.locationLabel)
        bookmarkFab = findViewById(R.id.bookmarkFab)

        // Set up toolbar
        setSupportActionBar(findViewById(R.id.toolbar))

        // Initialize helpers
        databaseHelper = DatabaseHelper(this)
        configManager = ConfigManager(this)
        
        // Load saved configuration
        loadConfiguration()
        
        // Set up gesture detectors
        setupGestureDetectors()
        
        // Set up bookmark FAB
        bookmarkFab.setOnClickListener {
            toggleBookmark()
        }
        
        // Load initial text
        loadCurrentChapter()
    }

    private fun loadConfiguration() {
        val translationName = configManager.getCurrentTranslation()
        currentTranslation = configManager.getTranslationConfig(translationName)
        fontSize = configManager.getFontSize()
        
        val locationString = configManager.getCurrentLocation()
        currentLocation = BibleLocation.fromLocationString(locationString)
    }

    private fun setupGestureDetectors() {
        // Swipe gesture detector
        gestureDetector = GestureDetectorCompat(this, object : GestureDetector.SimpleOnGestureListener() {
            override fun onFling(
                e1: MotionEvent?,
                e2: MotionEvent,
                velocityX: Float,
                velocityY: Float
            ): Boolean {
                if (e1 == null) return false
                
                val diffX = e2.x - e1.x
                val diffY = e2.y - e1.y
                
                if (abs(diffX) > abs(diffY) && 
                    abs(diffX) > SWIPE_THRESHOLD && 
                    abs(velocityX) > SWIPE_VELOCITY_THRESHOLD) {
                    
                    if (diffX > 0) {
                        // Swipe right - previous chapter
                        navigateChapter(false)
                    } else {
                        // Swipe left - next chapter
                        navigateChapter(true)
                    }
                    return true
                }
                return false
            }
        })
        
        // Pinch gesture detector for font size
        scaleGestureDetector = ScaleGestureDetector(this, object : ScaleGestureDetector.SimpleOnScaleGestureListener() {
            override fun onScale(detector: ScaleGestureDetector): Boolean {
                val scaleFactor = detector.scaleFactor
                
                if (scaleFactor > 1.0f) {
                    fontSize++
                } else if (scaleFactor < 1.0f) {
                    fontSize--
                }
                
                // Clamp font size
                fontSize = fontSize.coerceIn(20, 45)
                
                // Update text view
                bibleTextView.textSize = fontSize.toFloat()
                configManager.setFontSize(fontSize)
                
                return true
            }
        })
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        gestureDetector.onTouchEvent(event)
        scaleGestureDetector.onTouchEvent(event)
        return super.onTouchEvent(event)
    }

    private fun loadCurrentChapter() {
        val location = currentLocation ?: return
        val translation = currentTranslation ?: return
        
        val useJewishOrder = configManager.getUseJewishOrder()
        val bookOrder = databaseHelper.getBookOrder(location.bookNumber, useJewishOrder)
        
        // Get chapter text
        val text = databaseHelper.getChapterText(
            translation.tableName,
            bookOrder,
            location.chapterNumber,
            translation.alignRight
        )
        
        // Update UI
        bibleTextView.text = text
        bibleTextView.textSize = fontSize.toFloat()
        bibleTextView.textAlignment = if (translation.alignRight) {
            View.TEXT_ALIGNMENT_VIEW_END
        } else {
            View.TEXT_ALIGNMENT_VIEW_START
        }
        
        // Update location label
        val bookName = databaseHelper.getBookName(location.bookNumber)
        locationLabel.text = "$bookName ${location.chapterNumber}"
        
        // Update bookmark indicator
        updateBookmarkIndicator()
        
        // Update locations for navigation
        updateNavigationLocations()
    }

    private fun updateNavigationLocations() {
        val location = currentLocation ?: return
        val translation = currentTranslation ?: return
        
        // Calculate previous chapter
        var prevBook = location.bookNumber
        var prevChapter = location.chapterNumber - 1
        
        if (prevChapter < 1) {
            if (prevBook > 1) {
                prevBook--
                val useJewishOrder = configManager.getUseJewishOrder()
                val bookOrder = databaseHelper.getBookOrder(prevBook, useJewishOrder)
                prevChapter = databaseHelper.getChapterCount(translation.tableName, bookOrder)
            } else {
                prevChapter = 1
            }
        }
        
        // Calculate next chapter
        var nextBook = location.bookNumber
        var nextChapter = location.chapterNumber + 1
        
        val useJewishOrder = configManager.getUseJewishOrder()
        val bookOrder = databaseHelper.getBookOrder(location.bookNumber, useJewishOrder)
        val chapterCount = databaseHelper.getChapterCount(translation.tableName, bookOrder)
        
        if (nextChapter > chapterCount) {
            if (nextBook < 66) {
                nextBook++
                nextChapter = 1
            } else {
                nextChapter = location.chapterNumber
            }
        }
        
        // Save locations
        val prevLocation = BibleLocation(prevBook, if (prevBook <= 39) "O" else "N", prevChapter, 1)
        val nextLocation = BibleLocation(nextBook, if (nextBook <= 39) "O" else "N", nextChapter, 1)
        
        configManager.setLocations(
            prevLocation.toLocationString(),
            location.toLocationString(),
            nextLocation.toLocationString()
        )
    }

    private fun navigateChapter(forward: Boolean) {
        val locationString = if (forward) {
            configManager.getNextLocation()
        } else {
            configManager.getPreviousLocation()
        }
        
        currentLocation = BibleLocation.fromLocationString(locationString)
        loadCurrentChapter()
    }

    private fun toggleBookmark() {
        val location = currentLocation ?: return
        val locationString = location.toLocationString()
        
        if (configManager.hasBookmark(locationString)) {
            configManager.removeBookmark(locationString)
            Toast.makeText(this, R.string.bookmark_removed, Toast.LENGTH_SHORT).show()
        } else {
            val bookName = databaseHelper.getBookName(location.bookNumber)
            val displayText = "$bookName ${location.chapterNumber}"
            configManager.addBookmark(locationString, displayText)
            Toast.makeText(this, R.string.bookmark_added, Toast.LENGTH_SHORT).show()
        }
        
        updateBookmarkIndicator()
    }

    private fun updateBookmarkIndicator() {
        val location = currentLocation ?: return
        val locationString = location.toLocationString()
        val isBookmarked = configManager.hasBookmark(locationString)
        
        if (isBookmarked) {
            locationLabel.setTextColor(getColor(R.color.bookmark_highlight))
        } else {
            locationLabel.setTextColor(getColor(R.color.black))
        }
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.main_menu, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_select_chapter -> {
                val intent = Intent(this, ChapterPickerActivity::class.java)
                startActivityForResult(intent, REQUEST_CODE_PICKER)
                true
            }
            R.id.action_bookmarks -> {
                val intent = Intent(this, BookmarkActivity::class.java)
                startActivityForResult(intent, REQUEST_CODE_BOOKMARK)
                true
            }
            R.id.action_select_translation -> {
                showTranslationPicker()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun showTranslationPicker() {
        val translations = arrayOf(
            "עִבְרִית תַּנַ״ךְ",
            "ייִדיש תנ״ך",
            "עִבְרִית הברית החדשה",
            "English"
        )
        
        val currentName = currentTranslation?.name ?: translations[0]
        val currentIndex = translations.indexOf(currentName)
        
        AlertDialog.Builder(this)
            .setTitle(R.string.select_translation)
            .setSingleChoiceItems(translations, currentIndex) { dialog, which ->
                val selectedTranslation = translations[which]
                configManager.setCurrentTranslation(selectedTranslation)
                currentTranslation = configManager.getTranslationConfig(selectedTranslation)
                loadCurrentChapter()
                dialog.dismiss()
            }
            .setNegativeButton(android.R.string.cancel, null)
            .show()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (resultCode == RESULT_OK) {
            when (requestCode) {
                REQUEST_CODE_PICKER, REQUEST_CODE_BOOKMARK -> {
                    // Reload configuration and current chapter
                    loadConfiguration()
                    loadCurrentChapter()
                }
            }
        }
    }
}
