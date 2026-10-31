package com.nativemapper.app.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.nativemapper.app.ui.FloatingBubbleManager

class FloatingOverlayService : Service() {

    private lateinit var bubbleManager: FloatingBubbleManager

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        startForegroundService()
        bubbleManager = FloatingBubbleManager(this)
        bubbleManager.showBubble()
    }

    private fun startForegroundService() {
        val channelId = "keymapper_bubble_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Keymapper Bubble HUD",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }

        val notification: Notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Keymapper Sandbox Active")
            .setContentText("Tap 🎮 bubble to map buttons")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .build()

        startForeground(101, notification)
    }

    override fun onDestroy() {
        super.onDestroy()
        bubbleManager.removeAll()
    }
}
