import 'package:flutter/material.dart';

class PrincipalProfileScreen extends StatelessWidget {
  const PrincipalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ta'aruf Principal Sahab", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0D9488)),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 45, backgroundColor: Color(0xFF0D9488), child: Icon(Icons.school, size: 45, color: Colors.white)),
            SizedBox(height: 16),
            Text('Hazrat Mufti [Principal Sahab]', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Sadar Mudarris & Shaykh-ul-Hadith', style: TextStyle(color: Colors.grey)),
            Divider(height: 32),
            Text('Taleemi Paighaam:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text('Talaba ke liye zaroori hai ki dars-e-nizami ke sath fiqhi tahqeeqat par tawajjoh dein.', style: TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}
