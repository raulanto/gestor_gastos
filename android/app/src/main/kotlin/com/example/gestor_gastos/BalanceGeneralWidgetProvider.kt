package com.example.gestor_gastos

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import kotlin.math.max

/**
 * El bitmap mostrado es una captura de uno de los `HomeWidgetTier` de Flutter
 * (`HomeWidgetSnapshot`), generada por `HomeWidgetService.updateSnapshot`.
 * Como el usuario puede redimensionar el widget libremente en Android, en
 * vez de estirar una sola imagen a cualquier tamaño (lo que deforma el
 * texto) se elige, según el tamaño real del widget, cuál de las variantes
 * pre-renderizadas ("compact", "medium", "expanded") mostrar.
 */
class BalanceGeneralWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      updateWidgetView(context, appWidgetManager, widgetId, widgetData)
    }
  }

  override fun onAppWidgetOptionsChanged(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetId: Int,
      newOptions: Bundle,
  ) {
    super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
    updateWidgetView(
        context,
        appWidgetManager,
        appWidgetId,
        HomeWidgetPlugin.getData(context),
        newOptions,
    )
  }

  private fun updateWidgetView(
      context: Context,
      appWidgetManager: AppWidgetManager,
      widgetId: Int,
      widgetData: SharedPreferences,
      options: Bundle = appWidgetManager.getAppWidgetOptions(widgetId),
  ) {
    val tier = tierFor(options)
    val snapshotPath = widgetData.getString("balance_general_snapshot_$tier", null)
    val bitmap = snapshotPath?.let { BitmapFactory.decodeFile(it) }

    val views = RemoteViews(context.packageName, R.layout.balance_general_widget)
    if (bitmap != null) {
      views.setImageViewBitmap(R.id.widget_image, bitmap)
    }
    appWidgetManager.updateAppWidget(widgetId, views)
  }

  /**
   * Estima cuántas celdas de la grilla del launcher ocupa el widget a partir
   * de su tamaño mínimo en dp, usando la fórmula recomendada por Android
   * (https://developer.android.com/guide/topics/appwidgets/layouts#anatomy_determining_size)
   * para decidir qué tanta información mostrar.
   */
  private fun tierFor(options: Bundle): String {
    val minWidthDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
    val minHeightDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)

    if (minWidthDp == 0 && minHeightDp == 0) return "expanded"

    val columns = max(1, (minWidthDp + 30) / 70)
    val rows = max(1, (minHeightDp + 30) / 70)

    return when {
      rows <= 2 -> "compact"
      rows == 3 -> "medium"
      else -> "expanded"
    }
  }
}
