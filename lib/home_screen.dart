import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('मदरसा पोर्टल', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F5132),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F5132),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  Icon(Icons.menu_book, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'जामिया समदिया पोर्टल',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'ऑफलाइन अध्ययन एवं मदरसा प्रबंधन',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTile(Icons.library_books, 'दर्से निज़ामी किताबें', 'सभी दर्जों की किताबें और सबक'),
            _buildTile(Icons.list_alt, 'सिलेबस (निशाब)', 'सालाना पाठ्यक्रम और नियम'),
            _buildTile(Icons.contact_phone, 'मदरसा जानकारी', 'राबता और आवश्यक विवरण'),
          ],
        ),
      ),
    );
  }

  static Widget _buildTile(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0F5132).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF0F5132)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
