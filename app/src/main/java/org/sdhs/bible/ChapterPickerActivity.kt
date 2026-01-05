package org.sdhs.bible

import android.app.Activity
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.Spinner
import androidx.appcompat.app.AppCompatActivity

class ChapterPickerActivity : AppCompatActivity() {

    private lateinit var translationSpinner: Spinner
    private lateinit var bookSpinner: Spinner
    private lateinit var chapterSpinner: Spinner
    private lateinit var openButton: Button
    
    private lateinit var databaseHelper: DatabaseHelper
    private lateinit var configManager: ConfigManager
    
    private var selectedTranslation: String = ""
    private var selectedBookNumber: Int = 1
    private var selectedChapter: Int = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_chapter_picker)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        databaseHelper = DatabaseHelper(this)
        configManager = ConfigManager(this)

        translationSpinner = findViewById(R.id.translationSpinner)
        bookSpinner = findViewById(R.id.bookSpinner)
        chapterSpinner = findViewById(R.id.chapterSpinner)
        openButton = findViewById(R.id.openButton)

        setupTranslationSpinner()
        setupBookSpinner()
        
        openButton.setOnClickListener {
            openSelectedLocation()
        }
    }

    private fun setupTranslationSpinner() {
        val translations = arrayOf(
            "עִבְרִית תַּנַ״ךְ",
            "ייִדיש תנ״ך",
            "עִבְרִית הברית החדשה",
            "English"
        )
        
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, translations)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        translationSpinner.adapter = adapter
        
        val currentTranslation = configManager.getCurrentTranslation()
        val index = translations.indexOf(currentTranslation)
        if (index >= 0) {
            translationSpinner.setSelection(index)
        }
        
        translationSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                selectedTranslation = translations[position]
                configManager.setCurrentTranslation(selectedTranslation)
                setupBookSpinner()
            }

            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
    }

    private fun setupBookSpinner() {
        val books = (1..66).map { bookNum ->
            databaseHelper.getBookName(bookNum)
        }
        
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, books)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        bookSpinner.adapter = adapter
        
        // Set current book if available
        val currentLocation = BibleLocation.fromLocationString(configManager.getCurrentLocation())
        if (currentLocation.bookNumber in 1..66) {
            bookSpinner.setSelection(currentLocation.bookNumber - 1)
        }
        
        bookSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                selectedBookNumber = position + 1
                setupChapterSpinner()
            }

            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
    }

    private fun setupChapterSpinner() {
        val translation = configManager.getTranslationConfig(selectedTranslation)
        val useJewishOrder = configManager.getUseJewishOrder()
        val bookOrder = databaseHelper.getBookOrder(selectedBookNumber, useJewishOrder)
        val chapterCount = databaseHelper.getChapterCount(translation.tableName, bookOrder)
        
        val chapters = (1..chapterCount).map { it.toString() }
        
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, chapters)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        chapterSpinner.adapter = adapter
        
        chapterSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                selectedChapter = position + 1
            }

            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
    }

    private fun openSelectedLocation() {
        val testament = if (selectedBookNumber <= 39) "O" else "N"
        val location = BibleLocation(selectedBookNumber, testament, selectedChapter, 1)
        
        configManager.setCurrentLocation(location.toLocationString())
        setResult(Activity.RESULT_OK)
        finish()
    }

    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}
