import 'package:flutter/material.dart';
import 'owner_profile_screen.dart';
import 'principal_profile_screen.dart';
import 'gallery_screen.dart';
import 'syllabus_books_screen.dart';
import 'masail_research_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Madarsa Portal', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F5132),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F5132),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: const Row(
                children: [
                  Icon(Icons.mosque, size: 48, color: Color(0xFFD4AF37)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'خوش آمدید',
                          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Ilm-o-Amal ka Azeem Markaz',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              context,
              title: "Mohtamim / Owner Ta'aruf",
              subtitle: "Madarse ke bani aur sarparast ki tehqeeq o khidmat",
              icon: Icons.person_pin,
              color: const Color(0xFF1E3A8A),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerProfileScreen())),
            ),
            _buildCard(
              context,
              title: "Sadar Mudarris / Principal Ta'aruf",
              subtitle: "Ilmi silsila, mansab aur paighaam",
              icon: Icons.school,
              color: const Color(0xFF0D9488),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalProfileScreen())),
            ),
            _buildCard(
              context,
              title: "Photo & Video Gallery",
              subtitle: "Madarse ki imarat, darsgaah aur jalson ke manazir",
              icon: Icons.photo_library,
              color: const Color(0xFFD97706),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
            ),
            _buildCard(
              context,
              title: "Syllabus & All Classes Books",
              subtitle: "Nisaab-e-Taleem aur darja-waar kutub (PDF)",
              icon: Icons.menu_book,
              color: const Color(0xFF059669),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SyllabusBooksScreen())),
            ),
            _buildCard(
              context,
              title: "Tehqeeq Masla Masail (AI + Kutub)",
              subtitle: "Apna masla likhein, AI fiqh kutub se dalil scan karega",
              icon: Icons.auto_stories,
              color: const Color(0xFF7C3AED),
              isSpecial: true,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MasailResearchScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isSpecial = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: isSpecial ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isSpecial ? const BorderSide(color: Color(0xFFD4AF37), width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
        onTap: onTap,
      ),
    );
  }
}
