package com.example.dragonfakt

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import android.graphics.Color

class EventsWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return EventsRemoteViewsFactory(this.applicationContext)
    }
}

class EventsRemoteViewsFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var events: List<JSONObject> = listOf()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        try {
            val widgetData = HomeWidgetPlugin.getData(context)
            val jsonString = widgetData.getString("events_json", "[]") ?: "[]"
            val jsonArray = JSONArray(jsonString)
            
            val tempEvents = mutableListOf<JSONObject>()
            for (i in 0 until jsonArray.length()) {
                tempEvents.add(jsonArray.getJSONObject(i))
            }
            events = tempEvents
        } catch (e: Exception) {
            events = listOf()
        }
    }

    override fun onDestroy() {
        events = listOf()
    }

    override fun getCount(): Int = events.size

    override fun getViewAt(position: Int): RemoteViews? {
        if (position < 0 || position >= events.size) return null

        try {
            val event = events[position]
            val views = RemoteViews(context.packageName, R.layout.widget_item)
            
            views.setTextViewText(R.id.task_title, event.optString("title", ""))
            views.setTextViewText(R.id.task_date, event.optString("date", ""))
            
            // Get color from JSON, default to teal
            val colorStr = event.optString("color", "4286611396") // 0xFF80CBC4
            val colorInt = colorStr.toLongOrNull()?.toInt() ?: Color.parseColor("#80CBC4")
            
            views.setInt(R.id.task_indicator, "setColorFilter", colorInt)

            // Fill-in Intent for click
            val fillInIntent = Intent()
            fillInIntent.data = Uri.parse("dragonfakt://task?categoryId=${event.optInt("categoryId")}&reminderId=${event.optInt("id")}")
            views.setOnClickFillInIntent(R.id.widget_item_root, fillInIntent)

            return views
        } catch (e: Exception) {
            return null
        }
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
}