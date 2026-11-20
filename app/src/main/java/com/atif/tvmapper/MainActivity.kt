package com.atif.tvmapper

import android.app.AlertDialog
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import top.niunaijun.blackbox.BlackBoxCore

class MainActivity : AppCompatActivity() {

    data class GameItem(val name: String, val packageName: String, val apkPath: String)
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

    private fun loadSandboxedApps() {
        sandboxedGames.clear()
        try {
            val installedInBox = BlackBoxCore.get().getInstalledApplications(0, 0)
            for (info in installedInBox) {
                val label = info.loadLabel(packageManager).toString()
                sandboxedGames.add(GameItem(label, info.packageName, info.sourceDir))
            }
        } catch (_: Exception) {}
        adapter.notifyDataSetChanged()
    }

    private fun showInstalledAppsDialog() {
        val pm = packageManager
        val allApps = pm.getInstalledApplications(0)
            .filter { (it.flags and ApplicationInfo.FLAG_SYSTEM) == 0 && it.packageName != packageName }
            .map { GameItem(it.loadLabel(pm).toString(), it.packageName, it.sourceDir) }
            .sortedBy { it.name }

        val names = allApps.map { it.name }.toTypedArray()
        AlertDialog.Builder(this)
            .setTitle("Select Game to Clone into Sandbox")
            .setItems(names) { _, which ->
                val selected = allApps[which]
                Toast.makeText(this, "Cloning ${selected.name} into Sandbox...", Toast.LENGTH_SHORT).show()
                Thread {
                    try {
                        BlackBoxCore.get().installPackageAsUser(selected.apkPath, 0)
                        runOnUiThread {
                            loadSandboxedApps()
                            Toast.makeText(this, "${selected.name} Added!", Toast.LENGTH_SHORT).show()
                        }
                    } catch (e: Exception) {
                        runOnUiThread {
                            Toast.makeText(this, "Error: ${e.message}", Toast.LENGTH_LONG).show()
                        }
                    }
                }.start()
            }
            .show()
    }

    private fun checkOverlayAndLaunch(game: GameItem) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            Toast.makeText(this, "Please grant Display Over Other Apps permission", Toast.LENGTH_LONG).show()
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
            startActivity(intent)
            return
        }

        // Start Floating Logo & Key Mapper Overlay
        startService(Intent(this, FloatingMapperService::class.java))

        // Launch Game inside Sandbox
        Toast.makeText(this, "Launching ${game.name} in Sandbox...", Toast.LENGTH_SHORT).show()
        BlackBoxCore.get().launchApk(game.packageName, 0)
    }

    inner class GameAdapter(
        private val items: List<GameItem>,
        private val onClick: (GameItem) -> Unit
    ) : RecyclerView.Adapter<GameAdapter.VH>() {

        inner class VH(v: View) : RecyclerView.ViewHolder(v) {
            val tv: TextView = v.findViewById(android.R.id.text1)
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
            val tv = TextView(parent.context).apply {
                id = android.R.id.text1
                setBackgroundResource(R.drawable.glass_button)
                setTextColor(0xFFFFFFFF.toInt())
                textSize = 15f
                setPadding(24, 36, 24, 36)
                isFocusable = true
                val lp = ViewGroup.MarginLayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply { setMargins(12, 12, 12, 12) }
                layoutParams = lp
            }
            return VH(tv)
        }

        override fun onBindViewHolder(holder: VH, position: Int) {
            val item = items[position]
            holder.tv.text = "🎮 ${item.name}"
            holder.tv.setOnClickListener { onClick(item) }
        }

        override fun getItemCount() = items.size
    }
}
