package com.iacula.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class IaculaWidgetProvider : HomeWidgetProvider() {
    companion object {
        private const val TAG = "IaculaWidgetProvider"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.iacula_widget)

            // Determine widget size category from options
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 110)
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)

            val imageKey = when {
                minWidth > 250 && minHeight > 250 -> "widget_image_large"
                minWidth > 250 -> "widget_image_medium"
                else -> "widget_image_small"
            }

            val candidateKeys = when (imageKey) {
                "widget_image_large" -> listOf("widget_image_large", "widget_image_medium", "widget_image_small")
                "widget_image_medium" -> listOf("widget_image_medium", "widget_image_large", "widget_image_small")
                else -> listOf("widget_image_small", "widget_image_medium", "widget_image_large")
            }

            var bitmap: Bitmap? = null
            for (key in candidateKeys) {
                val path = widgetData.getString(key, null) ?: continue
                val file = File(path)
                if (!file.exists()) {
                    Log.w(TAG, "Widget image path for $key does not exist: $path")
                    continue
                }
                bitmap = BitmapFactory.decodeFile(file.absolutePath)
                if (bitmap == null) {
                    Log.w(TAG, "Widget image for $key could not be decoded: $path")
                    continue
                }
                break
            }

            if (bitmap != null) {
                views.setImageViewBitmap(R.id.widget_image, bitmap)
            } else {
                Log.w(TAG, "No valid widget image found for widgetId=$appWidgetId")
                views.setImageViewResource(R.id.widget_image, android.R.color.transparent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
