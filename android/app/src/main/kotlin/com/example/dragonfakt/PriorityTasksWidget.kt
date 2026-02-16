package com.example.dragonfakt

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.app.PendingIntent

class PriorityTasksWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.priority_tasks_widget)
            
            val intent = Intent(context, TasksWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(this.toUri(Intent.URI_INTENT_SCHEME))
            }

            views.setRemoteAdapter(R.id.tasks_list, intent)
            views.setEmptyView(R.id.tasks_list, R.id.empty_view)

            // Create a PendingIntent to launch the app when the widget is clicked
            val appIntent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(context, 0, appIntent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            views.setPendingIntentTemplate(R.id.tasks_list, pendingIntent)
            views.setOnClickPendingIntent(R.id.empty_view, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.tasks_list)
        super.onUpdate(context, appWidgetManager, appWidgetIds)
    }
}
