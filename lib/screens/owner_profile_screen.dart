import 'package:flutter/material.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ta'aruf Bani / Mohtamim", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1E3A8A)),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 45, backgroundColor: Color(0xFF1E3A8A), child: Icon(Icons.person, size: 45, color: Colors.white)),
            SizedBox(height: 16),
            Text('Hazrat Maulana [Bani Sahab]', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Founder & Sarparast-e-Aala', style: TextStyle(color: Colors.grey)),
            Divider(height: 32),
            Text('Ilmi Khidmat o Tehqeeq:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text('Madarse ki tasees, dars-e-nizami ki tarweej aur shoba-e-tehqeeq ki ahem khidmat anjaam di hain.', style: TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}
