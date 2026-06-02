package com.metavisionrs.clean_droid

import android.app.ActivityManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.metavisionrs.clean_droid/system"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getRamInfo" -> {
                        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val mi = ActivityManager.MemoryInfo()
                        am.getMemoryInfo(mi)
                        result.success(
                            mapOf(
                                "totalMB" to (mi.totalMem / 1024 / 1024).toInt(),
                                "availableMB" to (mi.availMem / 1024 / 1024).toInt()
                            )
                        )
                    }
                    "clearCache" -> {
                        try {
                            cacheDir.deleteRecursively()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("CACHE_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
