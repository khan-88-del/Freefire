package com.nativemapper.app.service

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.os.Build
import android.view.KeyEvent
import com.nativemapper.app.data.ActionType
import com.nativemapper.app.data.KeyMapping
import com.nativemapper.app.engine.GestureDispatcherEngine
import com.nativemapper.app.engine.NativeInputBridge
import kotlinx.coroutines.*
import java.util.concurrent.ConcurrentHashMap

class CustomAccessibilityService : AccessibilityService() {

    private lateinit var gestureEngine: GestureDispatcherEngine
    private val serviceScope = CoroutineScope(Dispatchers.Default + SupervisorJob())

    private val activeMappings = ConcurrentHashMap<Int, KeyMapping>()
    private val turboJobs = ConcurrentHashMap<Int, Job>()
    private val holdStates = ConcurrentHashMap<Int, Boolean>()
    private var holdStrokeDesc: GestureDescription.StrokeDescription? = null

    companion object {
        var instance: CustomAccessibilityService? = null
            private set
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        gestureEngine = GestureDispatcherEngine(this)
    }

    fun updateMappings(mappings: List<KeyMapping>) {
        activeMappings.clear()
        mappings.forEach { activeMappings[it.keyCode] = it }
    }

    override fun onKeyEvent(event: KeyEvent): Boolean {
        val keyCode = event.keyCode

        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            return super.onKeyEvent(event)
        }

        val mapping = activeMappings[keyCode] ?: return false

        if (NativeInputBridge.shouldFilterKeyEvent(keyCode, event.action, 8L)) {
            return true
        }

        when (mapping.actionType) {
            ActionType.SINGLE_TAP -> {
                if (event.action == KeyEvent.ACTION_DOWN) {
                    gestureEngine.dispatchTap(mapping.targetX, mapping.targetY, 16L)
                }
            }

            ActionType.TURBO_TAP -> {
                if (event.action == KeyEvent.ACTION_DOWN) {
                    if (turboJobs[keyCode]?.isActive != true) {
                        turboJobs[keyCode] = serviceScope.launch {
                            while (isActive) {
                                gestureEngine.dispatchTap(mapping.targetX, mapping.targetY, 16L)
                                delay(mapping.turboIntervalMs)
                            }
                        }
                    }
                } else if (event.action == KeyEvent.ACTION_UP) {
                    turboJobs[keyCode]?.cancel()
                    turboJobs.remove(keyCode)
                }
            }

            ActionType.CONTINUOUS_HOLD -> {
                if (event.action == KeyEvent.ACTION_DOWN) {
                    val isLocked = holdStates[keyCode] ?: false
                    if (!isLocked) {
                        holdStates[keyCode] = true
                        startHoldLoop(keyCode, mapping)
                    } else {
                        holdStates[keyCode] = false
                        turboJobs[keyCode]?.cancel()
                        turboJobs.remove(keyCode)
                    }
                }
            }

            ActionType.SWIPE -> {
                if (event.action == KeyEvent.ACTION_DOWN) {
                    gestureEngine.dispatchSwipe(
                        mapping.targetX,
                        mapping.targetY,
                        mapping.targetX + mapping.swipeDeltaX,
                        mapping.targetY + mapping.swipeDeltaY,
                        120L
                    )
                }
            }
        }

        return true
    }

    private fun startHoldLoop(keyCode: Int, mapping: KeyMapping) {
        turboJobs[keyCode] = serviceScope.launch {
            while (isActive && holdStates[keyCode] == true) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    holdStrokeDesc = gestureEngine.dispatchContinuousHold(
                        mapping.targetX,
                        mapping.targetY,
                        holdStrokeDesc
                    )
                } else {
                    gestureEngine.dispatchTap(mapping.targetX, mapping.targetY, 950L)
                }
                delay(950L)
            }
        }
    }

    override fun onAccessibilityEvent(event: android.view.accessibility.AccessibilityEvent?) {}
    override fun onInterrupt() {
        turboJobs.values.forEach { it.cancel() }
        turboJobs.clear()
        holdStates.clear()
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
        instance = null
    }
}
