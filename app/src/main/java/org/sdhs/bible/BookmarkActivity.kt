package org.sdhs.bible

import android.app.Activity
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class BookmarkActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var emptyView: TextView
    private lateinit var configManager: ConfigManager
    private lateinit var adapter: BookmarkAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_bookmark)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        configManager = ConfigManager(this)
        recyclerView = findViewById(R.id.bookmarksRecyclerView)
        emptyView = findViewById(R.id.emptyView)

        recyclerView.layoutManager = LinearLayoutManager(this)
        
        loadBookmarks()
    }

    private fun loadBookmarks() {
        val bookmarks = configManager.getBookmarks()
        
        if (bookmarks.isEmpty()) {
            recyclerView.visibility = View.GONE
            emptyView.visibility = View.VISIBLE
        } else {
            recyclerView.visibility = View.VISIBLE
            emptyView.visibility = View.GONE
            
            val bookmarkList = bookmarks.map { (location, displayText) ->
                Bookmark(location, displayText)
            }.sortedBy { it.displayText }
            
            adapter = BookmarkAdapter(bookmarkList) { bookmark ->
                // When bookmark is clicked, update location and finish
                configManager.setCurrentLocation(bookmark.location)
                setResult(Activity.RESULT_OK)
                finish()
            }
            
            recyclerView.adapter = adapter
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}

class BookmarkAdapter(
    private val bookmarks: List<Bookmark>,
    private val onItemClick: (Bookmark) -> Unit
) : RecyclerView.Adapter<BookmarkAdapter.BookmarkViewHolder>() {

    class BookmarkViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val bookmarkText: TextView = view.findViewById(R.id.bookmarkText)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BookmarkViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_bookmark, parent, false)
        return BookmarkViewHolder(view)
    }

    override fun onBindViewHolder(holder: BookmarkViewHolder, position: Int) {
        val bookmark = bookmarks[position]
        holder.bookmarkText.text = bookmark.displayText
        holder.itemView.setOnClickListener {
            onItemClick(bookmark)
        }
    }

    override fun getItemCount() = bookmarks.size
}
