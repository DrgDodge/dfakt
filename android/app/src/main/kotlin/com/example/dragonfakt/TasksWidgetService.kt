package com.example.dragonfakt

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import android.graphics.Color

class TasksWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TasksRemoteViewsFactory(this.applicationContext)
    }
}

class TasksRemoteViewsFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var tasks: List<JSONObject> = listOf()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        try {
            val widgetData = HomeWidgetPlugin.getData(context)
            val jsonString = widgetData.getString("tasks_json", "[]") ?: "[]"
            val jsonArray = JSONArray(jsonString)
            
            val tempTasks = mutableListOf<JSONObject>()
            for (i in 0 until jsonArray.length()) {
                tempTasks.add(jsonArray.getJSONObject(i))
            }
            tasks = tempTasks
        } catch (e: Exception) {
            tasks = listOf()
        }
    }

    override fun onDestroy() {
        tasks = listOf()
    }

    override fun getCount(): Int = tasks.size

    override fun getViewAt(position: Int): RemoteViews? {
        if (position < 0 || position >= tasks.size) return null

        try {
            val task = tasks[position]
            val views = RemoteViews(context.packageName, R.layout.widget_item)
            
            views.setTextViewText(R.id.task_title, task.optString("title", ""))
            views.setTextViewText(R.id.task_date, task.optString("date", ""))
            
            val isEventStr = task.optString("isEvent", "false")
            val isEvent = isEventStr.toBoolean()
            
            // Using Color.parseColor for safer color handling
            val color = if (isEvent) Color.parseColor("#80CBC4") else Color.parseColor("#448AFF")
            views.setInt(R.id.task_indicator, "setBackgroundColor", color)

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
