package com.metavisionrs.clean_droid

import android.app.ActivityManager
import android.app.usage.StorageStatsManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.os.storage.StorageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

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

                    "getStorageInfo" -> {
                        try {
                            val stat = StatFs(Environment.getDataDirectory().path)
                            val totalBytes = stat.totalBytes
                            val freeBytes = stat.freeBytes
                            result.success(
                                mapOf(
                                    "totalMB" to (totalBytes / 1024 / 1024).toInt(),
                                    "freeMB"  to (freeBytes  / 1024 / 1024).toInt(),
                                    "usedMB"  to ((totalBytes - freeBytes) / 1024 / 1024).toInt()
                                )
                            )
                        } catch (e: Exception) {
                            result.error("STORAGE_ERROR", e.message, null)
                        }
                    }

                    "getAllAppsCacheSize" -> {
                        // Returns total cache size of all installed apps (bytes)
                        // Uses StorageStatsManager on API 26+
                        try {
                            var totalCacheBytes = 0L
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                val storageManager = getSystemService(StorageManager::class.java)
                                val storageStatsManager = getSystemService(StorageStatsManager::class.java)
                                val pm = packageManager
                                val packages = pm.getInstalledPackages(0)
                                for (pkg in packages) {
                                    try {
                                        val uuid = storageManager.getUuidForPath(
                                            dataDir ?: filesDir
                                        )
                                        val stats = storageStatsManager.queryStatsForPackage(
                                            uuid,
                                            pkg.packageName,
                                            android.os.Process.myUserHandle()
                                        )
                                        totalCacheBytes += stats.cacheBytes
                                    } catch (_: Exception) {}
                                }
                            } else {
                                // Fallback: read each app's cache dir size
                                val pm = packageManager
                                val packages = pm.getInstalledPackages(0)
                                for (pkg in packages) {
                                    try {
                                        val appInfo = pm.getApplicationInfo(pkg.packageName, 0)
                                        val cacheDir = File(appInfo.dataDir, "cache")
                                        if (cacheDir.exists()) {
                                            totalCacheBytes += cacheDir.walkBottomUp()
                                                .filter { it.isFile }
                                                .sumOf { it.length() }
                                        }
                                    } catch (_: Exception) {}
                                }
                            }
                            result.success(mapOf("cacheBytes" to totalCacheBytes))
                        } catch (e: Exception) {
                            result.success(mapOf("cacheBytes" to 0L))
                        }
                    }

                    "getDownloadsFolderSize" -> {
                        try {
                            val downloadsDir = Environment.getExternalStoragePublicDirectory(
                                Environment.DIRECTORY_DOWNLOADS
                            )
                            var totalBytes = 0L
                            val filePaths = mutableListOf<String>()
                            if (downloadsDir.exists()) {
                                downloadsDir.walkBottomUp().filter { it.isFile }.forEach { f ->
                                    totalBytes += f.length()
                                    filePaths.add(f.absolutePath)
                                }
                            }
                            result.success(mapOf("bytes" to totalBytes, "paths" to filePaths))
                        } catch (e: Exception) {
                            result.success(mapOf("bytes" to 0L, "paths" to emptyList<String>()))
                        }
                    }

                    "scanJunkFiles" -> {
                        // Scans accessible dirs for real junk: APKs, .log, .tmp, large thumbnails
                        try {
                            val apkFiles = mutableListOf<String>()
                            var apkBytes = 0L
                            val logFiles = mutableListOf<String>()
                            var logBytes = 0L
                            val thumbFiles = mutableListOf<String>()
                            var thumbBytes = 0L

                            val externalDirs = mutableListOf<File>()
                            // Primary external storage
                            Environment.getExternalStorageDirectory()?.let { externalDirs.add(it) }
                            // App-specific external dirs (no permission needed)
                            getExternalCacheDirs()?.forEach { it?.let { d -> externalDirs.add(d) } }
                            getExternalFilesDirs(null)?.forEach { it?.let { d -> externalDirs.add(d) } }

                            for (dir in externalDirs) {
                                if (!dir.exists()) continue
                                try {
                                    dir.walkTopDown()
                                        .onEnter { !it.name.startsWith(".") }
                                        .filter { it.isFile }
                                        .forEach { f ->
                                            val ext = f.extension.lowercase()
                                            val len = f.length()
                                            when {
                                                ext == "apk" -> {
                                                    apkFiles.add(f.absolutePath)
                                                    apkBytes += len
                                                }
                                                ext in listOf("log", "txt") && f.name.contains("log", true) -> {
                                                    logFiles.add(f.absolutePath)
                                                    logBytes += len
                                                }
                                                ext in listOf("tmp", "temp") -> {
                                                    thumbFiles.add(f.absolutePath)
                                                    thumbBytes += len
                                                }
                                            }
                                        }
                                } catch (_: Exception) {}
                            }

                            // Thumbnails from DCIM/.thumbnails
                            val thumbDir = File(
                                Environment.getExternalStoragePublicDirectory(
                                    Environment.DIRECTORY_DCIM
                                ), ".thumbnails"
                            )
                            if (thumbDir.exists()) {
                                thumbDir.walkBottomUp().filter { it.isFile }.forEach { f ->
                                    thumbFiles.add(f.absolutePath)
                                    thumbBytes += f.length()
                                }
                            }

                            result.success(mapOf(
                                "apkBytes"   to apkBytes,
                                "apkPaths"   to apkFiles,
                                "logBytes"   to logBytes,
                                "logPaths"   to logFiles,
                                "thumbBytes" to thumbBytes,
                                "thumbPaths" to thumbFiles,
                            ))
                        } catch (e: Exception) {
                            result.success(mapOf(
                                "apkBytes" to 0L, "apkPaths" to emptyList<String>(),
                                "logBytes" to 0L, "logPaths" to emptyList<String>(),
                                "thumbBytes" to 0L, "thumbPaths" to emptyList<String>(),
                            ))
                        }
                    }

                    "deleteFiles" -> {
                        val paths = call.argument<List<String>>("paths") ?: emptyList()
                        var deleted = 0L
                        for (path in paths) {
                            try {
                                val f = File(path)
                                if (f.exists()) {
                                    deleted += f.length()
                                    f.delete()
                                }
                            } catch (_: Exception) {}
                        }
                        result.success(mapOf("deletedBytes" to deleted))
                    }

                    "getRunningProcesses" -> {
                        try {
                            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                            val runningProcs = am.runningAppProcesses ?: emptyList()

                            // Filter to background processes only (importance > 100 = not foreground)
                            val bgProcs = runningProcs.filter { proc ->
                                proc.importance > ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                                && !proc.processName.startsWith("com.android")
                                && !proc.processName.startsWith("android")
                                && proc.processName != packageName
                            }

                            val pids = bgProcs.map { it.pid }.toIntArray()
                            val memInfoArray = if (pids.isNotEmpty()) am.getProcessMemoryInfo(pids) else emptyArray()

                            val procList = bgProcs.mapIndexed { i, proc ->
                                val rssKb = if (i < memInfoArray.size) memInfoArray[i].totalPss else 0
                                mapOf(
                                    "name"    to proc.processName,
                                    "pid"     to proc.pid,
                                    "rssKB"   to rssKb,
                                    "importance" to proc.importance
                                )
                            }
                            result.success(procList)
                        } catch (e: Exception) {
                            result.success(emptyList<Map<String, Any>>())
                        }
                    }

                    "killBackgroundProcesses" -> {
                        try {
                            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                            val mi1 = ActivityManager.MemoryInfo()
                            am.getMemoryInfo(mi1)
                            val freeBefore = mi1.availMem

                            val packages = call.argument<List<String>>("packages") ?: emptyList()
                            for (pkg in packages) {
                                try { am.killBackgroundProcesses(pkg) } catch (_: Exception) {}
                            }

                            // Also force GC to reclaim our own memory
                            System.gc()
                            System.runFinalization()
                            Runtime.getRuntime().gc()

                            Thread.sleep(600) // let OS reclaim

                            val mi2 = ActivityManager.MemoryInfo()
                            am.getMemoryInfo(mi2)
                            val freeAfter = mi2.availMem

                            val freedMB = ((freeAfter - freeBefore) / 1024 / 1024).toInt()
                                .coerceAtLeast(0)

                            result.success(mapOf(
                                "freedMB"       to freedMB,
                                "availableMB"   to (mi2.availMem / 1024 / 1024).toInt(),
                                "totalMB"       to (mi2.totalMem / 1024 / 1024).toInt()
                            ))
                        } catch (e: Exception) {
                            result.error("BOOST_ERROR", e.message, null)
                        }
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
