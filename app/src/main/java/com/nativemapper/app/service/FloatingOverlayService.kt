package com.nativemapper.app.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.FrameLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import com.nativemapper.app.data.ActionType
import com.nativemapper.app.data.KeyMapping

class FloatingOverlayService : Service() {

    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        startForegroundService()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        initOverlay()
    }

    private fun startForegroundService() {
        val channelId = "overlay_service_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Keymapper Overlay",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        val notification: Notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Keymapper Running")
            .setContentText("Overlay HUD Active")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()

        startForeground(101, notification)
    }

    private fun initOverlay() {
        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }

        val rootLayout = FrameLayout(this)
        overlayView = rootLayout

        addNewMappingAnchor(rootLayout, 500f, 500f, KeyEvent.KEYCODE_BUTTON_A)

        windowManager.addView(rootLayout, params)
    }

    private fun addNewMappingAnchor(root: FrameLayout, initialX: Float, initialY: Float, boundKeyCode: Int) {
        val node = TextView(this).apply {
            text = KeyEvent.keyCodeToString(boundKeyCode).replace("KEYCODE_", "")
            setTextColor(Color.BLACK)
            setBackgroundColor(Color.argb(200, 255, 204, 0))
            setPadding(24, 24, 24, 24)
            isFocusable = true
            isFocusableInTouchMode = true
        }

        val nodeParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            leftMargin = initialX.toInt()
            topMargin = initialY.toInt()
        }

        node.setOnTouchListener(object : View.OnTouchListener {
            var dX = 0f
            var dY = 0f
            override fun onTouch(view: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        dX = view.x - event.rawX
                        dY = view.y - event.rawY
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        view.animate()
                            .x(event.rawX + dX)
                            .y(event.rawY + dY)
                            .setDuration(0)
                            .start()
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        commitCoordinates(boundKeyCode, view.x, view.y)
                        return true
                    }
                }
                return false
            }
        })

        node.setOnKeyListener { view, keyCode, event ->
            if (event.action == KeyEvent.ACTION_DOWN) {
                val step = 20f
                when (keyCode) {
                    KeyEvent.KEYCODE_DPAD_UP -> view.y -= step
                    KeyEvent.KEYCODE_DPAD_DOWN -> view.y += step
                    KeyEvent.KEYCODE_DPAD_LEFT -> view.x -= step
                    KeyEvent.KEYCODE_DPAD_RIGHT -> view.x += step
                    KeyEvent.KEYCODE_DPAD_CENTER, KeyEvent.KEYCODE_ENTER -> {
                        commitCoordinates(boundKeyCode, view.x, view.y)
                        return@setOnKeyListener true
                    }
                    else -> return@setOnKeyListener false
                }
                commitCoordinates(boundKeyCode, view.x, view.y)
                return@setOnKeyListener true
            }
            false
        }

        root.addView(node, nodeParams)
    }

    private fun commitCoordinates(keyCode: Int, x: Float, y: Float) {
        CustomAccessibilityService.instance?.let { service ->
            val mapping = KeyMapping(
                keyCode = keyCode,
                targetX = x,
                targetY = y,
                actionType = ActionType.SINGLE_TAP
            )
            service.updateMappings(listOf(mapping))
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        overlayView?.let { windowManager.removeView(it) }
    }
}
