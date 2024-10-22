package com.example.mobile
import android.database.Cursor
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.mobile/images"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Ensure flutterEngine is non-null and the MethodChannel is set up correctly
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL).setMethodCallHandler { 
            call, result ->
            if (call.method == "getAllImagePathsNative") {
                // Retrieve image paths, ids, and timestamps
                val imagePaths = getAllImagePathsNative()
                // Return the paths, ids, and timestamps to Flutter
                result.success(imagePaths)
            } else {
                result.notImplemented()
            }
        }
    }

    // Function to get all image paths, MediaStore IDs, and timestamps
    private fun getAllImagePathsNative(): List<List<String>> {
        val imagePaths = mutableListOf<List<String>>()
        // Specify the columns to retrieve: _ID (MediaStore ID), DATA (file path), DATE_TAKEN (timestamp), DATE_MODIFIED (last modified date)
        val projection = arrayOf(
            MediaStore.Images.Media._ID,           // MediaStore ID
            MediaStore.Images.Media.DATA,          // File path
            MediaStore.Images.Media.DATE_TAKEN,    // Timestamp (date taken)
            MediaStore.Images.Media.DATE_MODIFIED  // Last modified timestamp
        )

        // Query MediaStore to get image file paths, IDs, and timestamps
        val cursor: Cursor? = contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            null
        )

        // Safely use the cursor and retrieve image paths, IDs, and timestamps
        cursor?.use {
            val idColumnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val dataColumnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            val dateModifiedColumnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_MODIFIED)

            val dateTakenColumnIndex = it.getColumnIndex(MediaStore.Images.Media.DATE_TAKEN) // Use getColumnIndex which returns -1 if column doesn't exist
            
            while (it.moveToNext()) {
                val imageId = it.getString(idColumnIndex)        // Get the MediaStore ID
                val imagePath = it.getString(dataColumnIndex)    // Get the file path
                val dateTaken = if (dateTakenColumnIndex != -1) it.getLong(dateTakenColumnIndex) else null // Get the DATE_TAKEN value, can be null

                // Check if dateTaken is null, if so, fallback to DATE_MODIFIED or file metadata
                val finalTimestamp = dateTaken ?: it.getLong(dateModifiedColumnIndex)

                // Add MediaStore ID, file path, and timestamp to the list
                imagePaths.add(listOf(imagePath, imageId, finalTimestamp.toString()))
            }
        }

        return imagePaths
    }

}
