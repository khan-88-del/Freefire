package com.atif.tvmapper

import android.app.Service
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import org.json.JSONArray
import org.json.JSONObject

class FloatingMapperService : Service() {

    private lateinit var windowManager: WindowManager
    private lateinit var logoView: TextView
    private lateinit var menuLayout: LinearLayout
    private var isMenuOpen = false
    private var isLocked = false

    private val macroEngine = KeyMacroEngine(null)
    private val activeNodes = mutableListOf<NodeHolder>()

    data class NodeHolder(
        val data: MappedButton,
        val rootView: FrameLayout,
        val params: WindowManager.LayoutParams,
        val indexBadge: TextView,
        val centerLabel: TextView,
        val closeBtn: TextView
    )

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        MapperApp.activeMacroEngine = macroEngine
        createFloatingLogo()
        createFloatingMenu()
        syncConfigToDisk()
    }

    private fun syncConfigToDisk() {
        try {
            val root = JSONObject()
            root.put("locked", isLocked)
            val arr = JSONArray()
            for (node in activeNodes) {
                val obj = JSONObject()
                obj.put("orderIndex", node.data.orderIndex)
                obj.put("type", node.data.type)
                obj.put("keyCode", node.data.keyCode)
                obj.put("x", node.data.x.toDouble())
                obj.put("y", node.data.y.toDouble())
                obj.put("endX", node.data.endX.toDouble())
                obj.put("endY", node.data.endY.toDouble())
                arr.put(obj)
            }
            root.put("buttons", arr)
            val file = MapperApp.getConfigFile(this)
            file.writeText(root.toString())
            file.setReadable(true, false)
        } catch (_: Exception) {}
    }

    private fun overlayType(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else
            WindowManager.LayoutParams.TYPE_PHONE
    }

    private fun createFloatingLogo() {
        val size = (50 * resources.displayMetrics.density).toInt()
        logoView = TextView(this).apply {
            text = "🎮"
            textSize = 20f
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#CC0F172A"))
                setStroke(3, Color.parseColor("#00E5FF"))
            }
        }

        val params = WindowManager.LayoutParams(
            size, size, overlayType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 40
            y = 40
        }

        var initX = 0; var initY = 0; var touchX = 0f; var touchY = 0f
        logoView.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initX = params.x; initY = params.y
                    touchX = event.rawX; touchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    params.x = initX + (event.rawX - touchX).toInt()
                    params.y = initY + (event.rawY - touchY).toInt()
                    windowManager.updateViewLayout(logoView, params)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (Math.abs(event.rawX - touchX) < 10 && Math.abs(event.rawY - touchY) < 10) {
                        toggleMenu()
                    }
                    true
                }
                else -> false
            }
        }

        windowManager.addView(logoView, params)
    }

    private fun createFloatingMenu() {
        menuLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(16, 12, 16, 12)
            visibility = View.GONE
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#E60F172A"))
                setStroke(2, Color.parseColor("#00E5FF"))
                cornerRadius = 24f
            }
        }

        val btnTap = makeMenuBtn("+ Tap") { addNode("TAP") }
        val btn10x = makeMenuBtn("+ 10x Tap") { addNode("TAP_10X") }
        val btnSwipe = makeMenuBtn("+ Swipe") { addNode("SWIPE") }
        lateinit var btnLock: TextView
        btnLock = makeMenuBtn("🔓 Lock") {
            isLocked = !isLocked
            btnLock.text = if (isLocked) "🔒 Edit" else "🔓 Lock"
            updateNodesLockState()
            syncConfigToDisk()
        }

        menuLayout.addView(btnTap)
        menuLayout.addView(btn10x)
        menuLayout.addView(btnSwipe)
        menuLayout.addView(btnLock)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            overlayType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            y = 40
        }

        windowManager.addView(menuLayout, params)
    }

    private fun makeMenuBtn(label: String, onClick: () -> Unit): TextView {
        return TextView(this).apply {
            text = label
            setTextColor(Color.WHITE)
            textSize = 13f
            setPadding(20, 12, 20, 12)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#3300E5FF"))
                cornerRadius = 14f
            }
            val lp = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { setMargins(8, 0, 8, 0) }
            layoutParams = lp
            setOnClickListener { onClick() }
        }
    }

    private fun toggleMenu() {
        isMenuOpen = !isMenuOpen
        menuLayout.visibility = if (isMenuOpen) View.VISIBLE else View.GONE
    }

    private fun addNode(type: String) {
        if (isLocked) return
        val orderNum = activeNodes.size + 1
        val data = MappedButton(orderIndex = orderNum, type = type, x = 500f, y = 300f)
        macroEngine.mappedButtons.add(data)

        val sizePx = (68 * resources.displayMetrics.density).toInt()
        var isScanning = false

        val container = object : FrameLayout(this) {
            override fun dispatchKeyEvent(event: KeyEvent): Boolean {
                if (event.action == KeyEvent.ACTION_DOWN) {
                    if (isScanning && !isLocked) {
                        data.keyCode = event.keyCode
                        val keyName = KeyEvent.keyCodeToString(event.keyCode).removePrefix("KEYCODE_")
                        (getChildAt(0) as TextView).text = "$type\n[$keyName]"
                        isScanning = false
                        setNodeFocusable(this, false)
                        syncConfigToDisk()
                        return true
                    }
                }
                return super.dispatchKeyEvent(event)
            }
        }

        container.background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(Color.parseColor("#B30F172A"))
            setStroke(3, Color.parseColor("#00E5FF"))
        }

        val centerLabel = TextView(this).apply {
            text = "SCAN"
            setTextColor(Color.WHITE)
            textSize = 10f
            gravity = Gravity.CENTER
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }
        container.addView(centerLabel)

        val indexBadge = TextView(this).apply {
            text = "$orderNum"
            setTextColor(Color.BLACK)
            textSize = 9f
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#00E5FF"))
            }
            val bSize = (18 * resources.displayMetrics.density).toInt()
            layoutParams = FrameLayout.LayoutParams(bSize, bSize, Gravity.TOP or Gravity.START)
        }
        container.addView(indexBadge)

        val closeBtn = TextView(this).apply {
            text = "×"
            setTextColor(Color.WHITE)
            textSize = 12f
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#EF4444"))
            }
            val cSize = (20 * resources.displayMetrics.density).toInt()
            layoutParams = FrameLayout.LayoutParams(cSize, cSize, Gravity.TOP or Gravity.END)
        }
        container.addView(closeBtn)

        val params = WindowManager.LayoutParams(
            sizePx, sizePx, overlayType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 500
            y = 300
        }

        val holder = NodeHolder(data, container, params, indexBadge, centerLabel, closeBtn)
        activeNodes.add(holder)

        closeBtn.setOnClickListener {
            if (!isLocked) {
                windowManager.removeView(container)
                activeNodes.remove(holder)
                macroEngine.mappedButtons.remove(data)
                reindexNodes()
                syncConfigToDisk()
            }
        }

        var initX = 0; var initY = 0; var touchX = 0f; var touchY = 0f
        container.setOnTouchListener { _, event ->
            if (isLocked) return@setOnTouchListener false
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initX = params.x; initY = params.y
                    touchX = event.rawX; touchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    params.x = initX + (event.rawX - touchX).toInt()
                    params.y = initY + (event.rawY - touchY).toInt()
                    val loc = IntArray(2); container.getLocationOnScreen(loc); data.x = loc[0] + (sizePx / 2f)
                    data.y = loc[1] + (sizePx / 2f)
                    data.endX = data.x + 180f
                    data.endY = data.y
                    windowManager.updateViewLayout(container, params)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    syncConfigToDisk()
                    if (Math.abs(event.rawX - touchX) < 10 && Math.abs(event.rawY - touchY) < 10) {
                        isScanning = true
                        centerLabel.text = "PRESS KEY"
                        centerLabel.setTextColor(Color.parseColor("#00E5FF"))
                        setNodeFocusable(container, true)
                    }
                    true
                }
                else -> false
            }
        }

        windowManager.addView(container, params)
        syncConfigToDisk()
    }

    private fun setNodeFocusable(view: View, focusable: Boolean) {
        val holder = activeNodes.find { it.rootView == view } ?: return
        holder.params.flags = if (focusable) {
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
        } else {
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
        }
        windowManager.updateViewLayout(view, holder.params)
        if (focusable) view.requestFocus()
    }

    private fun updateNodesLockState() {
        for (node in activeNodes) {
            node.closeBtn.visibility = if (isLocked) View.GONE else View.VISIBLE
            node.rootView.alpha = if (isLocked) 0.4f else 1.0f
            node.params.flags = if (isLocked) {
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
            } else {
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
            }
            windowManager.updateViewLayout(node.rootView, node.params)
        }
    }

    private fun reindexNodes() {
        activeNodes.forEachIndexed { index, holder ->
            holder.data.orderIndex = index + 1
            holder.indexBadge.text = "${index + 1}"
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
