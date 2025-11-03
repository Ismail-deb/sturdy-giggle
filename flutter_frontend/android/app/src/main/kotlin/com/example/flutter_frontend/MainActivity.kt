package com.example.flutter_frontend

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_frontend/downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveToDownloads") {
                val filename = call.argument<String>("filename")
                val bytes = call.argument<ByteArray>("bytes")
                
                if (filename != null && bytes != null) {
                    try {
                        val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            // Android 10+ - Use MediaStore
                            val contentValues = ContentValues().apply {
                                put(MediaStore.MediaColumns.DISPLAY_NAME, filename)
                                put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")
                                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                            }
                            
                            val resolver = contentResolver
                            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
                            
                            uri?.let {
                                val outputStream: OutputStream? = resolver.openOutputStream(it)
                                outputStream?.write(bytes)
                                outputStream?.close()
                            }
                            
                            uri?.toString() ?: "Unknown"
                        } else {
                            // Android 9 and below - Direct file access
                            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                            val file = java.io.File(downloadsDir, filename)
                            file.writeBytes(bytes)
                            file.absolutePath
                        }
                        
                        result.success(uri)
                    } catch (e: Exception) {
                        result.error("SAVE_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGS", "Filename or bytes missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
