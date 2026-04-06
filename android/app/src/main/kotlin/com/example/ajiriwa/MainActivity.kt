package com.example.ajiriwa

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Explicitly register the webview_flutter plugin to fix the "unregistered type" error.
        flutterEngine.plugins.add(WebViewFlutterPlugin())
        super.configureFlutterEngine(flutterEngine)
    }
}
