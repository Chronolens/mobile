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
                // Retrieve image paths and ids
                val imagePaths = getAllImagePathsNative()
                // Return the paths and ids to Flutter
                result.success(imagePaths)
            } else {
                result.notImplemented()
            }
        }
    }

    // Function to get all image paths and MediaStore IDs
    private fun getAllImagePathsNative(): List<List<String>> {
        val imagePaths = mutableListOf<List<String>>()
        // Specify the columns to retrieve: _ID (MediaStore ID) and DATA (file path)
        val projection = arrayOf(
            MediaStore.Images.Media._ID,    // MediaStore ID
            MediaStore.Images.Media.DATA    // File path
        )

        // Query MediaStore to get image file paths and IDs
        val cursor: Cursor? = contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            null
        )

        // Safely use the cursor and retrieve image paths and IDs
        cursor?.use {
            val idColumnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val dataColumnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            
            while (it.moveToNext()) {
                val imageId = it.getString(idColumnIndex)        // Get the MediaStore ID
                val imagePath = it.getString(dataColumnIndex)    // Get the file path

                // Add both MediaStore ID and image path to the list
                imagePaths.add(listOf(imagePath,imageId))
            }
        }

        return imagePaths
    }
}