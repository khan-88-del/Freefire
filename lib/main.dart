import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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

  void _showGallerySelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Jamia Samadiya Gallery',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F5132),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.photo_library, color: Color(0xFF0F5132)),
                ),
                title: const Text('Photo Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Madarsa ke tasweeraat (madarsa_809047)'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MediaGridScreen(
                        resourceType: 'image',
                        title: 'Photo Gallery',
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFF8E1),
                  child: Icon(Icons.video_library, color: Colors.orange),
                ),
                title: const Text('Video Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Madarsa ke videos aur programs'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MediaGridScreen(
                        resourceType: 'video',
                        title: 'Video Gallery',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Madarsa Portal', style: TextStyle(color: Colors.white)),
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
                    'Online & Offline Student Portal',
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
                  'Gallery (Photos & Videos)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F5132)),
                ),
                subtitle: const Text('Photos aur Videos dekhein (madarsa_809047)'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF0F5132)),
                onTap: () => _showGallerySelection(context),
              ),
            ),
            _buildTile(Icons.library_books, 'Darse Nizami Kitabein', 'Sabhi darjo ki kitabein'),
            _buildTile(Icons.list_alt, 'Nisab wa Qawaneen', 'Syllabus aur zaroori niyam'),
            _buildTile(Icons.info_outline, 'Madarsa Maloomat', 'Rabta wa zaroori record'),
          ],
        ),
      ),
    );
  }

  static Widget _buildTile(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0F5132).withOpacity(0.12),
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

class MediaGridScreen extends StatefulWidget {
  final String resourceType;
  final String title;

  const MediaGridScreen({
    super.key,
    required this.resourceType,
    required this.title,
  });

  @override
  State<MediaGridScreen> createState() => _MediaGridScreenState();
}

class _MediaGridScreenState extends State<MediaGridScreen> {
  bool _loading = true;
  String? _error;
  List<String> _mediaUrls = [];

  final String cloudName = "zufwpc7e";
  final String apiKey = "388794978456266";
  final String apiSecret = "8PSkiOY-CtKiRECNldZz_Y6v2-A";

  @override
  void initState() {
    super.initState();
    _fetchCloudinaryMedia();
  }

  Future<void> _fetchCloudinaryMedia() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authCredentials = base64Encode(utf8.encode('$apiKey:$apiSecret'));
      
      // Cloudinary Admin API: Search via prefix/folder madarsa_809047
      final endpoint = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/resources/${widget.resourceType}/upload?prefix=madarsa_809047&max_results=50',
      );

      final response = await http.get(
        endpoint,
        headers: {
          'Authorization': 'Basic $authCredentials',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final resources = data['resources'] as List? ?? [];
        final urls = resources.map<String>((item) => item['secure_url'] as String).toList();

        setState(() {
          _mediaUrls = urls;
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Response: ${response.statusCode}\nFolder madarsa_809047 load nahi hua.";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Network error: Connection check karein.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F5132),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F5132)),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchCloudinaryMedia,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F5132),
                          ),
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Dobara Koshish Karein', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                )
              : _mediaUrls.isEmpty
                  ? const Center(
                      child: Text(
                        'Is folder me koi media nahi mila.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _mediaUrls.length,
                      itemBuilder: (context, index) {
                        final url = _mediaUrls[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: widget.resourceType == 'image'
                              ? Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(color: Color(0xFF0F5132)),
                                    );
                                  },
                                  errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.broken_image, size: 40),
                                )
                              : Container(
                                  color: Colors.black87,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.play_circle_fill, size: 48, color: Colors.amber),
                                        const SizedBox(height: 8),
                                        Text('Video ${index + 1}', style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                        );
                      },
                    ),
    );
  }
}
