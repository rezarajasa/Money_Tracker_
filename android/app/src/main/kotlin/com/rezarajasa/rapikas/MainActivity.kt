package com.rezarajasa.rapikas

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channelName = "rapikas/local_store"
    private val prefsName = "rapikas_money_tracker"
    private val dataKey = "app_data_json"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            val prefs = getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            when (call.method) {
                "saveData" -> {
                    val json = call.argument<String>("json") ?: ""
                    prefs.edit().putString(dataKey, json).apply()
                    result.success(true)
                }
                "loadData" -> {
                    result.success(prefs.getString(dataKey, ""))
                }
                "clearData" -> {
                    prefs.edit().remove(dataKey).apply()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
