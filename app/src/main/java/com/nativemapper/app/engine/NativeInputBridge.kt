package com.nativemapper.app.engine

object NativeInputBridge {
    init {
        System.loadLibrary("nativeinput")
    }

    external fun shouldFilterKeyEvent(keyCode: Int, action: Int, minIntervalMs: Long): Boolean
}
