package com.atif.tvmapper

import android.app.Activity
import android.app.Application
import android.app.Instrumentation
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
            val sharedDir = File(Environment.getExternalStorageDirectory(), "TVSandboxMapper")
            if (!sharedDir.exists()) sharedDir.mkdirs()
            return File(sharedDir, "mapper_nodes.json")
        }

        fun prepareGuestStorage() {
            try {
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
        private val inst = Instrumentation()

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

                matched.forEachIndexed { idx, btn ->
                    handler.postDelayed({
                        executeTouch(act, btn)
                    }, idx * 20L)
                }
                return true
            } catch (_: Exception) {
                return false
            }
        }

        private fun executeTouch(act: Activity, btn: MappedButton) {
            when (btn.type) {
                "TAP" -> injectPointerTap(act, btn.x, btn.y)
                "TAP_10X" -> {
                    for (i in 0 until 10) {
                        handler.postDelayed({ injectPointerTap(act, btn.x, btn.y) }, i * 20L)
                    }
                }
                "SWIPE" -> injectPointerSwipe(act, btn.x, btn.y, btn.endX, btn.endY)
            }
        }

        private fun injectPointerTap(act: Activity, x: Float, y: Float) {
            // 1. Direct Activity & DecorView dispatch
            val downTime = SystemClock.uptimeMillis()
            val down = MotionEvent.obtain(downTime, downTime, MotionEvent.ACTION_DOWN, x, y, 0)
            val up = MotionEvent.obtain(downTime, downTime + 18, MotionEvent.ACTION_UP, x, y, 0)
            down.source = InputDevice.SOURCE_TOUCHSCREEN
            up.source = InputDevice.SOURCE_TOUCHSCREEN
            act.dispatchTouchEvent(down)
            act.dispatchTouchEvent(up)
            down.recycle()
            up.recycle()

            // 2. Instrumentation pointer sync on background thread for SurfaceView/OpenGL games
            Thread {
                try {
                    val t = SystemClock.uptimeMillis()
                    val d = MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, x, y, 0).apply {
                        source = InputDevice.SOURCE_TOUCHSCREEN
                    }
                    val u = MotionEvent.obtain(t, t + 18, MotionEvent.ACTION_UP, x, y, 0).apply {
                        source = InputDevice.SOURCE_TOUCHSCREEN
                    }
                    inst.sendPointerSync(d)
                    inst.sendPointerSync(u)
                    d.recycle()
                    u.recycle()
                } catch (_: Exception) {}
            }.start()
        }

        private fun injectPointerSwipe(act: Activity, x1: Float, y1: Float, x2: Float, y2: Float) {
            Thread {
                try {
                    val t = SystemClock.uptimeMillis()
                    val d = MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, x1, y1, 0).apply {
                        source = InputDevice.SOURCE_TOUCHSCREEN
                    }
                    inst.sendPointerSync(d)
                    d.recycle()

                    for (i in 1..5) {
                        val frac = i / 5f
                        val cx = x1 + (x2 - x1) * frac
                        val cy = y1 + (y2 - y1) * frac
                        val m = MotionEvent.obtain(t, t + i * 8L, MotionEvent.ACTION_MOVE, cx, cy, 0).apply {
                            source = InputDevice.SOURCE_TOUCHSCREEN
                        }
                        inst.sendPointerSync(m)
                        m.recycle()
                    }

                    val u = MotionEvent.obtain(t, t + 48L, MotionEvent.ACTION_UP, x2, y2, 0).apply {
                        source = InputDevice.SOURCE_TOUCHSCREEN
                    }
                    inst.sendPointerSync(u)
                    u.recycle()
                } catch (_: Exception) {}
            }.start()
        }
    }
}
