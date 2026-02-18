package com.example.ecommerce

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.URL
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.ecommerce/comments"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getComments") {
                val postId = call.argument<Int>("postId")
                if (postId != null) {
                    fetchComments(postId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Post ID is missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun fetchComments(postId: Int, result: MethodChannel.Result) {
        thread {
            try {
                val url = URL("https://jsonplaceholder.typicode.com/comments?postId=$postId")
                val response = url.readText()
                runOnUiThread {
                    result.success(response)
                }
            } catch (e: Exception) {
                runOnUiThread {
                    result.error("FETCH_ERROR", e.message, null)
                }
            }
        }
    }
}
