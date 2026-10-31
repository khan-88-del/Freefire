package com.nativemapper.app.engine

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.os.Build
import androidx.annotation.RequiresApi

class GestureDispatcherEngine(private val service: AccessibilityService) {

    private val callback = object : AccessibilityService.GestureResultCallback() {
        override fun onCompleted(gestureDescription: GestureDescription?) { super.onCompleted(gestureDescription) }
        override fun onCancelled(gestureDescription: GestureDescription?) { super.onCancelled(gestureDescription) }
    }

    fun dispatchTap(x: Float, y: Float, durationMs: Long = 16L): Boolean {
        val path = Path().apply { moveTo(x, y) }
        val stroke = GestureDescription.StrokeDescription(path, 0, durationMs)
        val gesture = GestureDescription.Builder().addStroke(stroke).build()
        return service.dispatchGesture(gesture, callback, null)
    }

    fun dispatchSwipe(startX: Float, startY: Float, endX: Float, endY: Float, durationMs: Long = 100L): Boolean {
        val path = Path().apply {
            moveTo(startX, startY)
            lineTo(endX, endY)
        }
        val stroke = GestureDescription.StrokeDescription(path, 0, durationMs)
        val gesture = GestureDescription.Builder().addStroke(stroke).build()
        return service.dispatchGesture(gesture, callback, null)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun buildHoldStroke(x: Float, y: Float, durationMs: Long, willContinue: Boolean): GestureDescription.StrokeDescription {
        val path = Path().apply { moveTo(x, y) }
        return GestureDescription.StrokeDescription(path, 0, durationMs, willContinue)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun dispatchContinuousHold(x: Float, y: Float, currentStroke: GestureDescription.StrokeDescription?): GestureDescription.StrokeDescription {
        val nextStroke = currentStroke?.continueStroke(Path().apply { moveTo(x, y) }, 0, 1000L, true)
            ?: buildHoldStroke(x, y, 1000L, true)
        val gesture = GestureDescription.Builder().addStroke(nextStroke).build()
        service.dispatchGesture(gesture, callback, null)
        return nextStroke
    }
}
