package com.atif.tvmapper

import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import top.niunaijun.blackbox.BlackBoxCore
import java.io.File

class MainActivity : AppCompatActivity() {

    data class GameItem(
        val name: String,
        val packageName: String,
        val apkPath: String,
        val icon: Drawable?
    )

    private val sandboxedGames = mutableListOf<GameItem>()
    private lateinit var adapter: GameAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val rv = findViewById<RecyclerView>(R.id.rvSandboxGames)
        rv.layoutManager = GridLayoutManager(this, 4)
        adapter = GameAdapter(sandboxedGames) { game ->
            checkOverlayAndLaunch(game)
        }
        rv.adapter = adapter

        loadSandboxedApps()

        findViewById<Button>(R.id.btnAddGame).setOnClickListener {
            showInstalledAppsDialog()
        }
    }

    private fun getSavedPackages(): MutableSet<String> {
        val prefs = getSharedPreferences("sandbox_games", Context.MODE_PRIVATE)
        return prefs.getStringSet("packages", emptySet())?.toMutableSet() ?: mutableSetOf()
    }

    private fun savePackage(pkg: String) {
        val prefs = getSharedPreferences("sandbox_games", Context.MODE_PRIVATE)
        val set = getSavedPackages()
        set.add(pkg)
        prefs.edit().putStringSet("packages", set).apply()
    }

    private fun loadSandboxedApps() {
        sandboxedGames.clear()
        val addedPkgs = mutableSetOf<String>()

        // 1. Load from BlackBoxCore
        try {
            val installedInBox = BlackBoxCore.get().getInstalledApplications(0, 0)
            for (info in installedInBox) {
                addedPkgs.add(info.packageName)
            }
        } catch (_: Exception) {}

        // 2. Merge with SharedPreferences saved packages
        addedPkgs.addAll(getSavedPackages())

        // 3. Resolve Icon & Label from Host PackageManager
        val pm = packageManager
        for (pkg in addedPkgs) {
            try {
                val appInfo = pm.getApplicationInfo(pkg, 0)
                val label = appInfo.loadLabel(pm).toString()
                val icon = appInfo.loadIcon(pm)
                sandboxedGames.add(GameItem(label, pkg, appInfo.sourceDir, icon))
            } catch (_: Exception) {}
        }

        adapter.notifyDataSetChanged()
    }

    private fun showInstalledAppsDialog() {
        val pm = packageManager
        val allApps = pm.getInstalledApplications(0)
            .filter { (it.flags and ApplicationInfo.FLAG_SYSTEM) == 0 && it.packageName != packageName }
            .map {
                GameItem(
                    it.loadLabel(pm).toString(),
                    it.packageName,
                    it.sourceDir,
                    it.loadIcon(pm)
                )
            }
            .sortedBy { it.name }

        if (allApps.isEmpty()) {
            Toast.makeText(this, "No user apps found on device", Toast.LENGTH_SHORT).show()
            return
        }

        val names = allApps.map { it.name }.toTypedArray()
        AlertDialog.Builder(this)
            .setTitle("Select Game to Add in Sandbox")
            .setItems(names) { _, which ->
                val selected = allApps[which]
                Toast.makeText(this, "Adding ${selected.name}...", Toast.LENGTH_SHORT).show()

                // Save immediately so it always shows in Home Grid
                savePackage(selected.packageName)
                loadSandboxedApps()

                Thread {
                    try {
                        val result = BlackBoxCore.get().installPackageAsUser(File(selected.apkPath), 0)
                        runOnUiThread {
                            loadSandboxedApps()
                            if (result.success) {
                                Toast.makeText(this, "${selected.name} Ready in Sandbox!", Toast.LENGTH_SHORT).show()
                            } else {
                                Toast.makeText(this, "Sandbox note: ${result.msg}", Toast.LENGTH_LONG).show()
                            }
                        }
                    } catch (e: Exception) {
                        runOnUiThread {
                            Toast.makeText(this, "Added to list (${e.message})", Toast.LENGTH_SHORT).show()
                        }
                    }
                }.start()
            }
            .show()
    }

    private fun checkOverlayAndLaunch(game: GameItem) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            Toast.makeText(this, "Grant Display Over Other Apps permission first", Toast.LENGTH_LONG).show()
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
            startActivity(intent)
            return
        }

        startService(Intent(this, FloatingMapperService::class.java))
        Toast.makeText(this, "Launching ${game.name}...", Toast.LENGTH_SHORT).show()

        Thread {
            try {
                if (!BlackBoxCore.get().isInstalled(game.packageName, 0)) {
                    BlackBoxCore.get().installPackageAsUser(File(game.apkPath), 0)
                }
                BlackBoxCore.get().launchApk(game.packageName, 0)
            } catch (e: Exception) {
                runOnUiThread {
                    Toast.makeText(this, "Launch failed: ${e.message}", Toast.LENGTH_LONG).show()
                }
            }
        }.start()
    }

    inner class GameAdapter(
        private val items: List<GameItem>,
        private val onClick: (GameItem) -> Unit
    ) : RecyclerView.Adapter<GameAdapter.VH>() {

        inner class VH(val card: LinearLayout, val iconView: ImageView, val titleView: TextView) :
            RecyclerView.ViewHolder(card)

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
            val card = LinearLayout(parent.context).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                setBackgroundResource(R.drawable.glass_button)
                setPadding(20, 28, 20, 28)
                isFocusable = true
                layoutParams = ViewGroup.MarginLayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply { setMargins(12, 12, 12, 12) }
            }

            val iconSize = (56 * resources.displayMetrics.density).toInt()
            val iconView = ImageView(parent.context).apply {
                layoutParams = LinearLayout.LayoutParams(iconSize, iconSize)
            }

            val titleView = TextView(parent.context).apply {
                setTextColor(0xFFFFFFFF.toInt())
                textSize = 14f
                gravity = Gravity.CENTER
                maxLines = 1
                setPadding(0, 12, 0, 0)
            }

            card.addView(iconView)
            card.addView(titleView)
            return VH(card, iconView, titleView)
        }

        override fun onBindViewHolder(holder: VH, position: Int) {
            val item = items[position]
            holder.titleView.text = item.name
            if (item.icon != null) {
                holder.iconView.setImageDrawable(item.icon)
            } else {
                holder.iconView.setImageResource(android.R.drawable.sym_def_app_icon)
            }
            holder.card.setOnClickListener { onClick(item) }
        }

        override fun getItemCount() = items.size
    }
}
