package com.atif.tvmapper

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Environment
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
            // Save config in shared external storage so both host service & sandbox :p0 process read exact same file
            val sharedDir = File(Environment.getExternalStorageDirectory(), "TVSandboxMapper")
            if (!sharedDir.exists()) sharedDir.mkdirs()
            return File(sharedDir, "mapper_nodes.json")
        }

        fun prepareGuestStorage() {
            try {
                // Keep Garena Guest ID folder directly in /storage/emulated/0/com.garena.msdk (NOT inside Android/data)
                val msdkDir = File(Environment.getExternalStorageDirectory(), "com.garena.msdk")
                if (!msdkDir.exists()) msdkDir.mkdirs()
            } catch (_: Exception) {}
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
        prepareGuestStorage()

        try {
            BlackBoxCore.get().doCreate()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        try {
            BlackBoxCore.get().addAppLifecycleCallback(object : AppLifecycleCallback() {
                override fun onActivityResumed(activity: Activity) {
                    super.onActivityResumed(activity)
                    prepareGuestStorage()
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

        override fun onWindowFocusChanged(hasFocus: Boolean) {
            baseCallback.onWindowFocusChanged(hasFocus)
            if (hasFocus) hookWindowCallback(activity)
        }

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

                val decor = act.window?.decorView ?: return false
                matched.forEachIndexed { idx, btn ->
                    handler.postDelayed({
                        executeTouch(decor, btn)
                    }, idx * 20L)
                }
                return true
            } catch (_: Exception) {
                return false
            }
        }

        private fun executeTouch(view: View, btn: MappedButton) {
            when (btn.type) {
                "TAP" -> dispatchSingleTap(view, btn.x, btn.y)
                "TAP_10X" -> {
                    for (i in 0 until 10) {
                        handler.postDelayed({ dispatchSingleTap(view, btn.x, btn.y) }, i * 20L)
                    }
                }
                "SWIPE" -> dispatchSwipeGesture(view, btn.x, btn.y, btn.endX, btn.endY)
            }
        }

        private fun dispatchSingleTap(view: View, x: Float, y: Float) {
            val downTime = SystemClock.uptimeMillis()
            val down = MotionEvent.obtain(downTime, downTime, MotionEvent.ACTION_DOWN, x, y, 0)
            val up = MotionEvent.obtain(downTime, downTime + 20, MotionEvent.ACTION_UP, x, y, 0)
            down.source = InputDevice.SOURCE_TOUCHSCREEN
            up.source = InputDevice.SOURCE_TOUCHSCREEN
            view.dispatchTouchEvent(down)
            view.dispatchTouchEvent(up)
            down.recycle()
            up.recycle()
        }

        private fun dispatchSwipeGesture(view: View, x1: Float, y1: Float, x2: Float, y2: Float) {
            val downTime = SystemClock.uptimeMillis()
            val down = MotionEvent.obtain(downTime, downTime, MotionEvent.ACTION_DOWN, x1, y1, 0)
            down.source = InputDevice.SOURCE_TOUCHSCREEN
            view.dispatchTouchEvent(down)
            down.recycle()

            for (i in 1..5) {
                val t = i / 5f
                val cx = x1 + (x2 - x1) * t
                val cy = y1 + (y2 - y1) * t
                val move = MotionEvent.obtain(downTime, downTime + i * 8L, MotionEvent.ACTION_MOVE, cx, cy, 0)
                move.source = InputDevice.SOURCE_TOUCHSCREEN
                view.dispatchTouchEvent(move)
                move.recycle()
            }

            val up = MotionEvent.obtain(downTime, downTime + 48L, MotionEvent.ACTION_UP, x2, y2, 0)
            up.source = InputDevice.SOURCE_TOUCHSCREEN
            view.dispatchTouchEvent(up)
            up.recycle()
        }
    }
}
