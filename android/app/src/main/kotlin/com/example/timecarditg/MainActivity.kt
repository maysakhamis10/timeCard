package com.example.timecarditg

import android.content.Intent
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.myapp/intent"
        const val MAP_METHOD = "settings"
    }
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.getDartExecutor(), CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == MAP_METHOD) {
                startActivity(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS))
                Log.d("here kotlin === >" , "okay")
                result.success("ENABLED")
            } else {
                result.notImplemented()
            }
        }
    }

}
