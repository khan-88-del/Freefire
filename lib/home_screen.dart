import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Madarsa Portal',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F5132),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Banner
          Card(
            color: const Color(0xFF0F5132),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                children: [
                  Icon(Icons.mosque, size: 40, color: Color(0xFFFFD700)),
                  SizedBox(height: 8),
                  Text(
                    'خوش آمدید',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ilm-o-Amal ka Azeem Markaz',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Menu Options
          _buildMenuItem(
            icon: Icons.account_circle,
            iconColor: Colors.blue,
            title: "Mohtamim / Owner Ta'aruf",
            subtitle: "Madarse ke bani aur sarparast ki tehqeeq o khidmat",
          ),
          _buildMenuItem(
            icon: Icons.school,
            iconColor: Colors.teal,
            title: "Sadar Mudarris / Principal Ta'aruf",
            subtitle: "Ilmi silsila, mansab aur paighaam",
          ),
          _buildMenuItem(
            icon: Icons.photo_library,
            iconColor: Colors.orange,
            title: "Photo & Video Gallery",
            subtitle: "Madarse ki imarat, darsgaah aur jalson ke manazir",
          ),
          _buildMenuItem(
            icon: Icons.menu_book,
            iconColor: Colors.green,
            title: "Syllabus & All Classes Books",
            subtitle: "Nisaab-e-Taleem aur darja-waar kutub (PDF)",
          ),
          _buildMenuItem(
            icon: Icons.auto_stories,
            iconColor: Colors.purple,
            title: "Tehqeeq Masla Masail (AI + Kutub)",
            subtitle: "Apna masla likhein, Al fiqh kutub se dalil scan karega",
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
