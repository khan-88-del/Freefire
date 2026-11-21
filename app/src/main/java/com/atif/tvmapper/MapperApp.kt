package com.atif.tvmapper

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.*
import org.json.JSONArray
import top.niunaijun.blackbox.BlackBoxCore
import top.niunaijun.blackbox.app.configuration.AppLifecycleCallback
import top.niunaijun.blackbox.app.configuration.ClientConfiguration
import java.io.File
import java.lang.ref.WeakReference

class MapperApp : Application() {

    companion object {
        var currentSandboxedView: WeakReference<View>? = null
        var activeMacroEngine: KeyMacroEngine? = null

        fun getConfigFile(context: Context): File {
            val dir = context.filesDir
            if (!dir.exists()) dir.mkdirs()
            return File(dir, "mapper_nodes.json")
        }
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        try {
            BlackBoxCore.get().doAttachBaseContext(base, object : ClientConfiguration() {
                override fun getHostPackageName(): String = base.packageName
                override fun isEnableDaemonService(): Boolean = true
                override fun isHideRoot(): Boolean = true
            })
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onCreate() {
        super.onCreate()
        try {
            BlackBoxCore.get().doCreate()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        try {
            BlackBoxCore.get().addAppLifecycleCallback(object : AppLifecycleCallback() {
                override fun onActivityResumed(activity: Activity) {
                    super.onActivityResumed(activity)
                    val decor = activity.window?.decorView
                    if (decor != null) {
                        currentSandboxedView = WeakReference(decor)
                    }
                    hookWindowCallback(activity)
                }
            })
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun hookWindowCallback(activity: Activity) {
        val window = activity.window ?: return
        val originalCallback = window.callback ?: return
        if (originalCallback is SandboxWindowCallback) return
        window.callback = SandboxWindowCallback(activity, originalCallback)
    }

    inner class SandboxWindowCallback(
        private val activity: Activity,
        private val baseCallback: Window.Callback
    ) : Window.Callback by baseCallback {

        private val handler = Handler(Looper.getMainLooper())

        override fun dispatchKeyEvent(event: KeyEvent): Boolean {
            if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
                if (handleMappedKeyFromConfig(activity, event.keyCode)) {
                    return true
                }
            }
            return baseCallback.dispatchKeyEvent(event)
        }

        private fun handleMappedKeyFromConfig(act: Activity, keyCode: Int): Boolean {
            try {
                val cfgFile = getConfigFile(act)
                if (!cfgFile.exists()) return false
                val text = cfgFile.readText()
                if (text.isBlank()) return false

                val root = org.json.JSONObject(text)
                if (!root.optBoolean("locked", false)) return false

                val arr: JSONArray = root.optJSONArray("buttons") ?: return false
                val matched = mutableListOf<MappedButton>()

                for (i in 0 until arr.length()) {
                    val obj = arr.getJSONObject(i)
                    if (obj.getInt("keyCode") == keyCode) {
                        matched.add(
                            MappedButton(
                                orderIndex = obj.getInt("orderIndex"),
                                type = obj.getString("type"),
                                keyCode = keyCode,
                                x = obj.getDouble("x").toFloat(),
                                y = obj.getDouble("y").toFloat(),
                                endX = obj.optDouble("endX", obj.getDouble("x") + 180.0).toFloat(),
                                endY = obj.optDouble("endY", obj.getDouble("y")).toFloat()
                            )
                        )
                    }
                }

                if (matched.isEmpty()) return false
                matched.sortBy { it.orderIndex }

                val decorView = act.window?.decorView ?: return false
                matched.forEachIndexed { idx, btn ->
                    handler.postDelayed({
                        executeOnDecorView(decorView, btn)
                    }, idx * 20L)
                }
                return true
            } catch (_: Exception) {
                return false
            }
        }

        private fun executeOnDecorView(view: View, btn: MappedButton) {
            when (btn.type) {
                "TAP" -> sendTouch(view, btn.x, btn.y)
                "TAP_10X" -> {
                    for (i in 0 until 10) {
                        handler.postDelayed({ sendTouch(view, btn.x, btn.y) }, i * 20L)
                    }
                }
                "SWIPE" -> sendSwipe(view, btn.x, btn.y, btn.endX, btn.endY)
            }
        }

        private fun sendTouch(view: View, x: Float, y: Float) {
            val downTime = SystemClock.uptimeMillis()
            val down = MotionEvent.obtain(downTime, downTime, MotionEvent.ACTION_DOWN, x, y, 0)
            val up = MotionEvent.obtain(downTime, downTime + 15, MotionEvent.ACTION_UP, x, y, 0)
            view.dispatchTouchEvent(down)
            view.dispatchTouchEvent(up)
            down.recycle()
            up.recycle()
        }

        private fun sendSwipe(view: View, x1: Float, y1: Float, x2: Float, y2: Float) {
            val downTime = SystemClock.uptimeMillis()
            view.dispatchTouchEvent(MotionEvent.obtain(downTime, downTime, MotionEvent.ACTION_DOWN, x1, y1, 0))
            for (i in 1..5) {
                val t = i / 5f
                val cx = x1 + (x2 - x1) * t
                val cy = y1 + (y2 - y1) * t
                view.dispatchTouchEvent(MotionEvent.obtain(downTime, downTime + i * 8L, MotionEvent.ACTION_MOVE, cx, cy, 0))
            }
            view.dispatchTouchEvent(MotionEvent.obtain(downTime, downTime + 48L, MotionEvent.ACTION_UP, x2, y2, 0))
        }
    }
}
