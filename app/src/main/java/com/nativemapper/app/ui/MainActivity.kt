package com.nativemapper.app.ui

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.Gravity
import android.view.ViewGroup
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import com.nativemapper.app.service.FloatingOverlayService

class MainActivity : AppCompatActivity() {

    private lateinit var gamesContainer: LinearLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val root = ScrollView(this).apply {
            setBackgroundColor(Color.parseColor("#121212"))
        }

        val mainLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(40, 60, 40, 60)
        }

        // Title Header
        val title = TextView(this).apply {
            text = "⚡ Sandboxed Keymapper Launcher"
            setTextColor(Color.WHITE)
            textSize = 22f
            paint.isFakeBoldText = true
        }

        val subtitle = TextView(this).apply {
            text = "Octopus-style container: Add game, launch inside sandbox with 🎮 HUD"
            setTextColor(Color.parseColor("#AAAAAA"))
            textSize = 13f
            setPadding(0, 10, 0, 40)
        }

        // Permission Trigger Banner
        val banner = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setBackgroundColor(Color.parseColor("#1E1E1E"))
            setPadding(30, 24, 30, 24)
        }
        val btnPerm = Button(this).apply {
            text = "Check Permissions"
            setBackgroundColor(Color.parseColor("#FF6D00"))
            setTextColor(Color.WHITE)
            setOnClickListener { checkPermissions() }
        }
        banner.addView(btnPerm)

        // Add Game Section
        val headerApps = TextView(this).apply {
            text = "INSTALLED GAMES IN SANDBOX"
            setTextColor(Color.parseColor("#FFD54F"))
            textSize = 14f
            setPadding(0, 50, 0, 20)
        }

        val btnAddApp = Button(this).apply {
            text = "+ Add Application To Sandbox"
            setTextColor(Color.WHITE)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#2979FF"))
                cornerRadius = 16f
            }
            setOnClickListener { openAppPicker() }
        }

        gamesContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(0, 20, 0, 40)
        }

        mainLayout.addView(title)
        mainLayout.addView(subtitle)
        mainLayout.addView(banner)
        mainLayout.addView(headerApps)
        mainLayout.addView(btnAddApp)
        mainLayout.addView(gamesContainer)

        root.addView(mainLayout)
        setContentView(root)
    }

    private fun checkPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
            startActivity(intent)
            return
        }
        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
    }

    private fun openAppPicker() {
        val pm = packageManager
        val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val appNames = mutableListOf<String>()
        val appPackages = mutableListOf<String>()

        for (app in packages) {
            if ((app.flags and ApplicationInfo.FLAG_SYSTEM) == 0) {
                appNames.add(pm.getApplicationLabel(app).toString())
                appPackages.add(app.packageName)
            }
        }

        val builder = android.app.AlertDialog.Builder(this)
        builder.setTitle("Select Game to Clone / Sandbox")
        builder.setItems(appNames.toTypedArray()) { _, which ->
            addGameCard(appNames[which], appPackages[which])
        }
        builder.show()
    }

    private fun addGameCard(appName: String, pkgName: String) {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(30, 30, 30, 30)
            setBackgroundColor(Color.parseColor("#242424"))
            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply { setMargins(0, 16, 0, 16) }
            layoutParams = params
        }

        val nameView = TextView(this).apply {
            text = appName
            setTextColor(Color.WHITE)
            textSize = 16f
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1.0f)
        }

        val btnLaunch = Button(this).apply {
            text = "Launch In Sandbox"
            setBackgroundColor(Color.parseColor("#00C853"))
            setTextColor(Color.WHITE)
            setOnClickListener {
                // 1. Start Circle Bubble Overlay
                val overlayIntent = Intent(this@MainActivity, FloatingOverlayService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(overlayIntent)
                } else {
                    startService(overlayIntent)
                }

                // 2. Launch Host Game App
                val launchIntent = packageManager.getLaunchIntentForPackage(pkgName)
                if (launchIntent != null) {
                    startActivity(launchIntent)
                } else {
                    Toast.makeText(this@MainActivity, "Cannot start app", Toast.LENGTH_SHORT).show()
                }
            }
        }

        card.addView(nameView)
        card.addView(btnLaunch)
        gamesContainer.addView(card)
    }
}
