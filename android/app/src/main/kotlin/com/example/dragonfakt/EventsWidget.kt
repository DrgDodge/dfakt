package com.example.dragonfakt

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.app.PendingIntent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import androidx.core.content.res.ResourcesCompat

class EventsWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.events_widget)
            
            val titleBitmap = buildTitleBitmap(context, "Events")
            views.setImageViewBitmap(R.id.widget_title_image, titleBitmap)
            
            val intent = Intent(context, EventsWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(this.toUri(Intent.URI_INTENT_SCHEME))
            }

            views.setRemoteAdapter(R.id.events_list, intent)
            views.setEmptyView(R.id.events_list, R.id.empty_events_view)

            // PendingIntent for the header/empty view to launch Categories
            val appIntent = Intent(context, MainActivity::class.java)
            appIntent.action = "es.antonborri.home_widget.action.LAUNCH"
            appIntent.data = Uri.parse("dragonfakt://categories")
            val pendingIntent = PendingIntent.getActivity(context, 0, appIntent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            
            views.setOnClickPendingIntent(R.id.widget_title_image, pendingIntent)
            views.setOnClickPendingIntent(R.id.empty_events_view, pendingIntent)

            // PendingIntent template for list items
            val itemIntent = Intent(context, MainActivity::class.java)
            itemIntent.action = "es.antonborri.home_widget.action.LAUNCH"
            // Use mutable flag for fill-in intents on Android 12+
            val flags = if (android.os.Build.VERSION.SDK_INT >= 31) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val itemPendingIntent = PendingIntent.getActivity(context, 1, itemIntent, flags)
            views.setPendingIntentTemplate(R.id.events_list, itemPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.events_list)
        super.onUpdate(context, appWidgetManager, appWidgetIds)
    }

    private fun buildTitleBitmap(context: Context, text: String): Bitmap {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        // 22sp to pixels
        paint.textSize = 22f * context.resources.displayMetrics.scaledDensity
        paint.color = Color.parseColor("#80CBC4")
        paint.textAlign = Paint.Align.LEFT
        
        try {
            val typeface = ResourcesCompat.getFont(context, R.font.bungee)
            paint.typeface = typeface
        } catch (e: Exception) {
            paint.typeface = Typeface.DEFAULT_BOLD
        }

        val baseline = -paint.ascent()
        val width = (paint.measureText(text) + 0.5f).toInt()
        val height = (baseline + paint.descent() + 0.5f).toInt()
        
        val image = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(image)
        canvas.drawText(text, 0f, baseline, paint)
        return image
    }
}