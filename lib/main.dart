import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

const String BASE_API_URL = "https://app-itb0.onrender.com";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MadarsaApp());
}

class MadarsaApp extends StatelessWidget {
  const MadarsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madarsa Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        primaryColor: const Color(0xFF0F5132),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF0F5132),
        ),
      ),
      home: const SafeSplashScreen(),
    );
  }
}

class SafeSplashScreen extends StatefulWidget {
  const SafeSplashScreen({super.key});

  @override
  State<SafeSplashScreen> createState() => _SafeSplashScreenState();
}

class _SafeSplashScreenState extends State<SafeSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4650),
    )..forward();

    Timer(const Duration(milliseconds: 4650), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SafeHomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'Jamia Samadiya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: size.height * 0.68,
            left: size.width * 0.18,
            right: size.width * 0.18,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFCC00),
                          ),
                          minHeight: 12,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Loading Portal...',
                  style: TextStyle(
                    color: const Color(0xFFFFD700),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.9),
                        blurRadius: 6,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SafeHomeScreen extends StatelessWidget {
  const SafeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Madarsa Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F5132),
        centerTitle: true,
        elevation: 2,
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
              child: const Column(
                children: [
                  Icon(Icons.menu_book, size: 52, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Jamia Samadiya Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Student & Institution Portal',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              color: const Color(0xFFE8F5E9),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF0F5132),
                  child: Icon(Icons.collections, color: Colors.white),
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F5132)),
                ),
                subtitle: const Text('View photos and videos'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF0F5132)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GallerySwipeScreen(),
                    ),
                  );
                },
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              color: const Color(0xFFFFF9E6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFB78103),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icons/syllabus_icon.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => const Icon(Icons.auto_stories, color: Colors.white),
                    ),
                  ),
                ),
                title: const Text(
                  'Syllabus Darse Nizami',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB78103)),
                ),
                subtitle: const Text('Classes & syllabus PDF documents'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFB78103)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SyllabusClassesScreen(),
                    ),
                  );
                },
              ),
            ),
            _buildTile(Icons.list_alt, 'Rules & Regulations', 'Academic guidelines and policies'),
            _buildTile(Icons.info_outline, 'About Institution', 'Contact details and overview'),
          ],
        ),
      ),
    );
  }

    static Widget _buildCustomTile({
    required BuildContext context,
    required Color bgColor,
    required Color titleColor,
    required Widget leadingWidget,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1.8,
      color: bgColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              leadingWidget,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: titleColor == Colors.black87 ? Colors.black45 : titleColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

