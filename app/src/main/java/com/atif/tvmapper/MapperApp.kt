package com.atif.tvmapper

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import android.view.View
import top.niunaijun.blackbox.BlackBoxCore
import top.niunaijun.blackbox.app.configuration.ClientConfiguration
import java.lang.ref.WeakReference

class MapperApp : Application() {

    companion object {
        var currentSandboxedView: WeakReference<View>? = null
        var activeMacroEngine: KeyMacroEngine? = null
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        try {
            BlackBoxCore.get().doAttachBaseContext(base, object : ClientConfiguration() {
                override fun getHostPackageName(): String = base.packageName
                override fun isEnableDaemonService(): Boolean = false
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

        // Sandbox ke andar khulne wale Game ke DecorView ko capture karna
        registerActivityLifecycleCallbacks(object : ActivityLifecycleCallbacks {
            override fun onActivityResumed(activity: Activity) {
                if (activity.javaClass.name != MainActivity::class.java.name) {
                    val decorView = activity.window?.decorView
                    if (decorView != null) {
                        currentSandboxedView = WeakReference(decorView)
                        activeMacroEngine?.updateTargetView(decorView)
                    }
                }
            }
            override fun onActivityCreated(a: Activity, b: Bundle?) {}
            override fun onActivityStarted(a: Activity) {}
            override fun onActivityPaused(a: Activity) {}
            override fun onActivityStopped(a: Activity) {}
            override fun onActivitySaveInstanceState(a: Activity, b: Bundle) {}
            override fun onActivityDestroyed(a: Activity) {}
        })
    }
}
