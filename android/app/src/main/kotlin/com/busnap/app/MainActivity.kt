package com.busnap.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val METHOD_CHANNEL  = "com.busnap.app/location_service"
    private val EVENT_CHANNEL   = "com.busnap.app/location_events"

    private var eventSink: EventChannel.EventSink? = null
    private var broadcastReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Method channel: start / stop service ─────────────────────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startBackgroundTracking" -> {
                    startService(LocationBackgroundService.ACTION_START)
                    result.success(true)
                }
                "stopBackgroundTracking" -> {
                    startService(LocationBackgroundService.ACTION_STOP)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // ── Event channel: stream location + stopped events to Flutter ────────
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                registerReceiver()
            }
            override fun onCancel(arguments: Any?) {
                unregisterReceiver()
                eventSink = null
            }
        })
    }

    override fun onDestroy() {
        unregisterReceiver()
        super.onDestroy()
    }

    // ── Broadcast receiver ────────────────────────────────────────────────────

    private fun registerReceiver() {
        val filter = IntentFilter().apply {
            addAction(LocationBackgroundService.ACTION_LOCATION)
            addAction(LocationBackgroundService.ACTION_STOPPED)
        }
        broadcastReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    LocationBackgroundService.ACTION_LOCATION -> {
                        val lat = intent.getDoubleExtra("lat", 0.0)
                        val lng = intent.getDoubleExtra("lng", 0.0)
                        val speed = intent.getFloatExtra("speed", 0f)
                        eventSink?.success(mapOf("type" to "location", "lat" to lat, "lng" to lng, "speed" to speed))
                    }
                    LocationBackgroundService.ACTION_STOPPED -> {
                        eventSink?.success(mapOf("type" to "stopped"))
                    }
                }
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(broadcastReceiver, filter, RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(broadcastReceiver, filter)
        }
    }

    private fun unregisterReceiver() {
        try { broadcastReceiver?.let { unregisterReceiver(it) } } catch (_: Exception) {}
        broadcastReceiver = null
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private fun startService(action: String) {
        val intent = Intent(this, LocationBackgroundService::class.java).apply {
            this.action = action
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
}
