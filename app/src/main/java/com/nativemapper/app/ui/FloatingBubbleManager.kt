package com.nativemapper.app.ui

import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.view.*
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import com.nativemapper.app.data.ActionType
import com.nativemapper.app.data.KeyMapping
import com.nativemapper.app.service.CustomAccessibilityService

class FloatingBubbleManager(private val context: Context) {

    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var bubbleView: View? = null
    private var menuPanel: LinearLayout? = null
    private val overlayNodes = mutableListOf<View>()

    fun showBubble() {
        if (bubbleView != null) return

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val bubbleParams = WindowManager.LayoutParams(
            160, 160, layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 80
            y = 300
        }

        // Circular Octopus Style Floating Icon
        val bubble = FrameLayout(context).apply {
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#FF6D00"))
                setStroke(4, Color.WHITE)
            }
        }

        val iconText = TextView(context).apply {
            text = "🎮"
            textSize = 24f
            gravity = Gravity.CENTER
        }
        bubble.addView(iconText, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))

        // Draggable bubble logic
        bubble.setOnTouchListener(object : View.OnTouchListener {
            var initialX = 0
            var initialY = 0
            var initialTouchX = 0f
            var initialTouchY = 0f
            var isClick = false

            override fun onTouch(v: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = bubbleParams.x
                        initialY = bubbleParams.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        isClick = true
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val diffX = (event.rawX - initialTouchX).toInt()
                        val diffY = (event.rawY - initialTouchY).toInt()
                        if (Math.abs(diffX) > 10 || Math.abs(diffY) > 10) isClick = false
                        bubbleParams.x = initialX + diffX
                        bubbleParams.y = initialY + diffY
                        windowManager.updateViewLayout(bubble, bubbleParams)
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        if (isClick) toggleOptionMenu(bubbleParams.x, bubbleParams.y + 180)
                        return true
                    }
                }
                return false
            }
        })

        bubbleView = bubble
        windowManager.addView(bubble, bubbleParams)
    }

    private fun toggleOptionMenu(posX: Int, posY: Int) {
        if (menuPanel != null) {
            windowManager.removeView(menuPanel)
            menuPanel = null
            return
        }

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val menuParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = posX
            y = posY
        }

        menuPanel = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.argb(230, 20, 20, 20))
            setPadding(30, 30, 30, 30)
            elevation = 16f
        }

        // Tap Option
        val btnAddTap = createMenuBtn("+ Add Tap Key") {
            spawnKeyButton(ActionType.SINGLE_TAP, "Tap")
            toggleOptionMenu(0, 0)
        }

        // Turbo 10x Tap Option
        val btnAddTurbo = createMenuBtn("⚡ Add Turbo (10x)") {
            spawnKeyButton(ActionType.TURBO_TAP, "Turbo")
            toggleOptionMenu(0, 0)
        }

        // Lock / Continuous Hold Option
        val btnAddLock = createMenuBtn("🔒 Add Lock Key") {
            spawnKeyButton(ActionType.CONTINUOUS_HOLD, "Hold")
            toggleOptionMenu(0, 0)
        }

        menuPanel?.addView(btnAddTap)
        menuPanel?.addView(btnAddTurbo)
        menuPanel?.addView(btnAddLock)
        windowManager.addView(menuPanel, menuParams)
    }

    private fun createMenuBtn(title: String, onClick: () -> Unit): TextView {
        return TextView(context).apply {
            text = title
            setTextColor(Color.WHITE)
            textSize = 15f
            setPadding(20, 16, 20, 16)
            setOnClickListener { onClick() }
        }
    }

    private fun spawnKeyButton(type: ActionType, label: String) {
        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val btnParams = WindowManager.LayoutParams(
            120, 120, layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 400
            y = 600
        }

        val keyNode = TextView(context).apply {
            text = label
            setTextColor(Color.BLACK)
            textSize = 13f
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(when (type) {
                    ActionType.SINGLE_TAP -> Color.parseColor("#FFD54F")
                    ActionType.TURBO_TAP -> Color.parseColor("#FF5252")
                    ActionType.CONTINUOUS_HOLD -> Color.parseColor("#448AFF")
                    else -> Color.WHITE
                })
                setStroke(3, Color.BLACK)
            }
        }

        keyNode.setOnTouchListener(object : View.OnTouchListener {
            var dX = 0f
            var dY = 0f
            override fun onTouch(v: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        dX = btnParams.x - event.rawX
                        dY = btnParams.y - event.rawY
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        btnParams.x = (event.rawX + dX).toInt()
                        btnParams.y = (event.rawY + dY).toInt()
                        windowManager.updateViewLayout(keyNode, btnParams)
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        // Default to Gamepad Button A / Space
                        CustomAccessibilityService.instance?.let { service ->
                            service.updateMappings(listOf(
                                KeyMapping(
                                    keyCode = KeyEvent.KEYCODE_BUTTON_A,
                                    targetX = btnParams.x.toFloat() + 60f,
                                    targetY = btnParams.y.toFloat() + 60f,
                                    actionType = type
                                )
                            ))
                        }
                        return true
                    }
                }
                return false
            }
        })

        overlayNodes.add(keyNode)
        windowManager.addView(keyNode, btnParams)
    }

    fun removeAll() {
        bubbleView?.let { windowManager.removeView(it) }
        menuPanel?.let { windowManager.removeView(it) }
        overlayNodes.forEach { windowManager.removeView(it) }
    }
}
