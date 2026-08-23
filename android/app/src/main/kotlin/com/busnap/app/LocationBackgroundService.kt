package com.busnap.app

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.os.PowerManager
import android.os.PowerManager.WakeLock
import androidx.core.app.NotificationCompat

/**
 * Foreground service that:
 *  - Shows a persistent notification (required to keep the process alive)
 *  - Holds a PARTIAL_WAKE_LOCK so the CPU stays on while screen is off
 *  - Registers a native LocationManager GPS listener (not Geolocator) so
 *    updates keep coming through Doze mode when the screen is off
 *  - Broadcasts location updates to MainActivity via a local broadcast
 *  - START_NOT_STICKY: stops cleanly on user force-close (intentional)
 */
class LocationBackgroundService : Service(), LocationListener {

    companion object {
        const val ACTION_START   = "START_TRACKING"
        const val ACTION_STOP    = "STOP_TRACKING"

        /** Broadcast sent when the service stops (notification Stop tap). */
        const val ACTION_STOPPED = "com.busnap.app.TRACKING_STOPPED"

        /** Broadcast sent on each GPS fix. Extras: lat, lng (both Double). */
        const val ACTION_LOCATION = "com.busnap.app.LOCATION_UPDATE"

        private const val CHANNEL_ID      = "busnap_tracking"
        private const val NOTIFICATION_ID = 10021
        private const val MIN_DISTANCE_M  = 20f   // metres between updates
        private const val MIN_TIME_MS     = 5000L  // 5 seconds between updates
    }

    private var wakeLock: WakeLock? = null
    private var locationManager: LocationManager? = null

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                startForeground(NOTIFICATION_ID, buildNotification())
                acquireWakeLock()
                startGps()
            }
            ACTION_STOP -> stopTracking()
        }
        // NOT_STICKY: don't restart automatically — user or OS killed it intentionally
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        stopGps()
        releaseWakeLock()
        cancelNotification()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ── GPS ───────────────────────────────────────────────────────────────────

    @SuppressLint("MissingPermission")
    private fun startGps() {
        locationManager =
            getSystemService(Context.LOCATION_SERVICE) as LocationManager
        try {
            locationManager?.requestLocationUpdates(
                LocationManager.GPS_PROVIDER,
                MIN_TIME_MS,
                MIN_DISTANCE_M,
                this
            )
        } catch (e: Exception) {
            // GPS provider unavailable on this device — Flutter stream is fallback
        }
    }

    private fun stopGps() {
        try { locationManager?.removeUpdates(this) } catch (_: Exception) {}
        locationManager = null
    }

    // LocationListener — called by native GPS even with screen off
    override fun onLocationChanged(location: Location) {
        sendBroadcast(
            Intent(ACTION_LOCATION).setPackage(packageName).apply {
                putExtra("lat", location.latitude)
                putExtra("lng", location.longitude)
                putExtra("speed", location.speed)
            }
        )
    }

    @Deprecated("Deprecated in API 29")
    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
    override fun onProviderEnabled(provider: String) {}
    override fun onProviderDisabled(provider: String) {}

    // ── WakeLock ──────────────────────────────────────────────────────────────

    private fun acquireWakeLock() {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "busnap:tracking"
        ).also { it.acquire() }
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) wakeLock?.release()
        } catch (_: Exception) {}
        wakeLock = null
    }

    // ── Stop ──────────────────────────────────────────────────────────────────

    private fun stopTracking() {
        // Tell Flutter to clean up journey state
        sendBroadcast(Intent(ACTION_STOPPED).setPackage(packageName))
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    // ── Notification ──────────────────────────────────────────────────────────

    private fun cancelNotification() {
        (getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager)
            ?.cancel(NOTIFICATION_ID)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mgr = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (mgr.getNotificationChannel(CHANNEL_ID) != null) return
            mgr.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    "Busnap Tracking",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Active while Busnap is tracking your journey"
                    setShowBadge(false)
                }
            )
        }
    }

    private fun buildNotification(): Notification {
        val flag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            PendingIntent.FLAG_IMMUTABLE else 0

        val stopIntent = PendingIntent.getService(
            this, 0,
            Intent(this, LocationBackgroundService::class.java)
                .apply { action = ACTION_STOP },
            PendingIntent.FLAG_UPDATE_CURRENT or flag
        )
        val openIntent = PendingIntent.getActivity(
            this, 1,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_UPDATE_CURRENT or flag
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setContentTitle("Busnap — Journey active")
            .setContentText("Tracking your location. Tap to open.")
            .setContentIntent(openIntent)
            .setOngoing(true)
            .setAutoCancel(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(0, "Stop", stopIntent)
            .build()
    }
}
