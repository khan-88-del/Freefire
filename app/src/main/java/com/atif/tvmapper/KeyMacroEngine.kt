package com.atif.tvmapper

import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View

data class MappedButton(
    var orderIndex: Int,      // 1, 2, 3...
    val type: String,         // "TAP", "TAP_10X", "SWIPE"
    var keyCode: Int = -1,
    var x: Float,
    var y: Float,
    var endX: Float = x + 180f,
    var endY: Float = y
)

class KeyMacroEngine(private var targetGameView: View?) {
    private val handler = Handler(Looper.getMainLooper())
    val mappedButtons = mutableListOf<MappedButton>()

    fun updateTargetView(view: View) {
        targetGameView = view
    }

    fun onHardwareKeyPressed(keyCode: Int): Boolean {
        val matchingButtons = mappedButtons
            .filter { it.keyCode == keyCode }
            .sortedBy { it.orderIndex }

        if (matchingButtons.isEmpty()) return false

        // Same key assigned to multiple nodes -> execute in 1, 2, 3 order with exact 20ms interval
        matchingButtons.forEachIndexed { idx, button ->
            handler.postDelayed({
                executeButtonAction(button)
            }, idx * 20L)
        }
        return true
    }

    private fun executeButtonAction(btn: MappedButton) {
        when (btn.type) {
            "TAP" -> injectTap(btn.x, btn.y)
            "TAP_10X" -> {
                for (i in 0 until 10) {
                    handler.postDelayed({ injectTap(btn.x, btn.y) }, i * 20L)
                }
            }
            "SWIPE" -> injectSwipe(btn.x, btn.y, btn.endX, btn.endY)
        }
    }

    private fun injectTap(x: Float, y: Float) {
        val view = targetGameView ?: MapperApp.currentSandboxedView?.get() ?: return
        val downTime = SystemClock.uptimeMillis()
        val down = MotionEvent.obtain(downTime, downTime, MotionEvent.ACTION_DOWN, x, y, 0)
        val up = MotionEvent.obtain(downTime, downTime + 12, MotionEvent.ACTION_UP, x, y, 0)
        view.dispatchTouchEvent(down)
        view.dispatchTouchEvent(up)
        down.recycle()
        up.recycle()
    }

    private fun injectSwipe(x1: Float, y1: Float, x2: Float, y2: Float) {
        val view = targetGameView ?: MapperApp.currentSandboxedView?.get() ?: return
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
