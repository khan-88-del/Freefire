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
            _buildTile(Icons.library_books, 'Curriculum & Books', 'Explore syllabus and study books'),
            _buildTile(Icons.list_alt, 'Rules & Regulations', 'Academic guidelines and policies'),
            _buildTile(Icons.info_outline, 'About Institution', 'Contact details and overview'),
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

class GallerySwipeScreen extends StatelessWidget {
  const GallerySwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF0F5132),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 2,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFCC00),
            indicatorWeight: 3.5,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.photo_library), text: 'Photos'),
              Tab(icon: Icon(Icons.video_library), text: 'Videos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MediaTabContent(resourceType: 'image', pageSize: 25),
            MediaTabContent(resourceType: 'video', pageSize: 20),
          ],
        ),
      ),
    );
  }
}

class MediaTabContent extends StatefulWidget {
  final String resourceType;
  final int pageSize;
  const MediaTabContent({super.key, required this.resourceType, required this.pageSize});

  @override
  State<MediaTabContent> createState() => _MediaTabContentState();
}

class _MediaTabContentState extends State<MediaTabContent> {
  bool _loading = true;
  String? _error;
  List _allMedia = [];
  int _currentPage = 0;

  final String cloudName = "zufwpc7e";
  final String apiKey = "388794978456266";
  final String apiSecret = "8PSkiOY-CtKiRECNldZz_Y6v2-A";

  @override
  void initState() {
    super.initState();
    _fetchMedia();
  }

  Future<void> _fetchMedia() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authCredentials = base64Encode(utf8.encode('$apiKey:$apiSecret'));
      final endpoint = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/resources/${widget.resourceType}/upload?prefix=madarsa_809047&max_results=500',
      );

      final response = await http.get(
        endpoint,
        headers: {'Authorization': 'Basic $authCredentials'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map parsed = json.decode(response.body);
        final List resources = parsed['resources'] ?? [];
        final List items = [];

        for (var item in resources) {
          final String publicId = item['public_id'].toString();
          final String secureUrl = item['secure_url'].toString();
          final String thumbUrl = widget.resourceType == 'video'
              ? 'https://res.cloudinary.com/$cloudName/video/upload/so_0,q_auto,f_jpg/$publicId.jpg'
              : 'https://res.cloudinary.com/$cloudName/image/upload/q_auto,f_auto/$publicId.jpg';
          items.add({
            'url': secureUrl,
            'thumb': thumbUrl,
          });
        }

        setState(() {
          _allMedia = items;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Unable to load items. Status: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Please check your internet connection.';
        _loading = false;
      });
    }
  }

  void _openImageViewer(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const CircularProgressIndicator(color: Color(0xFF0F5132));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0F5132)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchMedia,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5132)),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Try Again', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    if (_allMedia.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.resourceType == 'image' ? Icons.photo_library_outlined : Icons.video_library_outlined,
              size: 56,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 10),
            Text(
              'No items available yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final int totalPages = (_allMedia.length / widget.pageSize).ceil();
    final int startIndex = _currentPage * widget.pageSize;
    final int endIndex = (startIndex + widget.pageSize > _allMedia.length)
        ? _allMedia.length
        : startIndex + widget.pageSize;
    final List currentList = _allMedia.sublist(startIndex, endIndex);

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: currentList.length,
            itemBuilder: (context, index) {
              final Map item = currentList[index] as Map;
              final String url = item['url'].toString();
              final String thumb = item['thumb'].toString();

              return InkWell(
                onTap: () {
                  _openImageViewer(context, url);
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        thumb,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF0F5132)));
                        },
                        errorBuilder: (context, error, stack) =>
                            const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      ),
                      if (widget.resourceType == 'video')
                        Container(
                          color: Colors.black26,
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 46,
                              color: Color(0xFFFFCC00),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5132),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Previous'),
                ),
                Text(
                  'Page ${_currentPage + 1} of $totalPages',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F5132)),
                ),
                ElevatedButton.icon(
                  onPressed: _currentPage < totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5132),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
