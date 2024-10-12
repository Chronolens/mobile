package com.example.mobile
import android.database.Cursor
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.mobile/images"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Ensure flutterEngine is non-null and the MethodChannel is set up correctly
        // FIXME binaryMessenger!!
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL).setMethodCallHandler { 
            call, result ->
            if (call.method == "getAllImagePathsNative") {
                // Retrieve image paths
                val imagePaths = getAllImagePathsNative()
                // Return the paths to Flutter
                result.success(imagePaths)
            } else {
                result.notImplemented()
            }
        }
    }

    // Function to get all image paths
    private fun getAllImagePathsNative(): List<String> {
        val imagePaths = mutableListOf<String>()
        // Specify which column to retrieve (the file path in this case)
        val projection = arrayOf(MediaStore.Images.Media.DATA)

        // Query MediaStore to get image file paths
        val cursor: Cursor? = contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            null
        )

        // Safely use the cursor and retrieve image paths
        cursor?.use {
            val columnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            while (it.moveToNext()) {
                val imagePath = it.getString(columnIndex)
                imagePaths.add(imagePath)
            }
        }

        return imagePaths
    }
}