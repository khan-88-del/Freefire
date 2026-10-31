package com.nativemapper.app.data

import androidx.room.Entity
import androidx.room.PrimaryKey

enum class ActionType { SINGLE_TAP, TURBO_TAP, CONTINUOUS_HOLD, SWIPE }

@Entity(tableName = "key_mappings")
data class KeyMapping(
    @PrimaryKey val keyCode: Int,
    val targetX: Float,
    val targetY: Float,
    val actionType: ActionType,
    val turboIntervalMs: Long = 100L,
    val swipeDeltaX: Float = 0f,
    val swipeDeltaY: Float = 0f
)
