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
            const SizedBox(height: 20),

            // 1. Gallery Tile
            _buildCustomTile(
              bgColor: const Color(0xFFE8F5E9),
              titleColor: const Color(0xFF0F5132),
              leadingWidget: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F5132).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icons/gallery_icon.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => const Icon(
                      Icons.collections,
                      color: Color(0xFF0F5132),
                      size: 26,
                    ),
                  ),
                ),
              ),
              title: 'Gallery',
              subtitle: 'View photos and videos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GallerySwipeScreen()),
                );
              },
            ),

            // 2. Syllabus Darse Nizami Tile
            _buildCustomTile(
              bgColor: const Color(0xFFFFF9E6),
              titleColor: const Color(0xFFB78103),
              leadingWidget: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFB78103).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icons/syllabus_icon.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => const Icon(
                      Icons.auto_stories,
                      color: Color(0xFFB78103),
                      size: 26,
                    ),
                  ),
                ),
              ),
              title: 'Syllabus Darse Nizami',
              subtitle: 'Classes & syllabus PDF documents',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SyllabusClassesScreen()),
                );
              },
            ),

            // 3. Rules & Regulations Tile
            _buildCustomTile(
              bgColor: Colors.white,
              titleColor: Colors.black87,
              leadingWidget: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F5132).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.list_alt, color: Color(0xFF0F5132), size: 26),
              ),
              title: 'Rules & Regulations',
              subtitle: 'Academic guidelines and policies',
              onTap: () {},
            ),

            // 4. About Institution Tile
            _buildCustomTile(
              bgColor: Colors.white,
              titleColor: Colors.black87,
              leadingWidget: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F5132).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFF0F5132), size: 26),
              ),
              title: 'About Institution',
              subtitle: 'Contact details and overview',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCustomTile({
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

// ================== SYLLABUS ==================

class SyllabusClassesScreen extends StatefulWidget {
  const SyllabusClassesScreen({super.key});

  @override
  State<SyllabusClassesScreen> createState() => _SyllabusClassesScreenState();
}

class _SyllabusClassesScreenState extends State<SyllabusClassesScreen> {
  bool _loading = true;
  String? _error;
  List _classes = [];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$BASE_API_URL/api/syllabus/classes'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _classes = data['classes'] ?? [];
            _loading = false;
          });
          return;
        }
      }
      setState(() {
        _error = 'Could not load classes';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Internet connection error';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syllabus Darse Nizami', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F5132),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F5132)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchClasses,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5132)),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                )
              : _classes.isEmpty
                  ? const Center(child: Text('Abhi tak koi class upload nahi hui hai.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: _classes.length,
                      itemBuilder: (context, index) {
                        final c = _classes[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF0F5132),
                              child: Icon(Icons.folder, color: Colors.white),
                            ),
                            title: Text(
                              c['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text('${c['pdf_count'] ?? 0} PDF(s) available'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClassPdfsScreen(
                                    classId: c['id'],
                                    className: c['name'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

class ClassPdfsScreen extends StatefulWidget {
  final int classId;
  final String className;
  const ClassPdfsScreen({super.key, required this.classId, required this.className});

  @override
  State<ClassPdfsScreen> createState() => _ClassPdfsScreenState();
}

class _ClassPdfsScreenState extends State<ClassPdfsScreen> {
  bool _loading = true;
  String? _error;
  List _pdfs = [];

  @override
  void initState() {
    super.initState();
    _fetchPdfs();
  }

  Future<void> _fetchPdfs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$BASE_API_URL/api/syllabus/class/${widget.classId}/pdfs'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _pdfs = data['pdfs'] ?? [];
            _loading = false;
          });
          return;
        }
      }
      setState(() {
        _error = 'Could not load syllabus files';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Check internet connection';
        _loading = false;
      });
    }
  }

  void _openInAppPdfViewer(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NativeInAppPdfViewer(pdfUrl: url, title: title),
      ),
    );
  }

  void _downloadPdfDirectly(String url, String title) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF0F5132)),
                SizedBox(height: 16),
                Text('Saving PDF to Phone...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 35));
      if (!mounted) return;
      Navigator.pop(context);

      if (res.statusCode == 200) {
        String cleanTitle = title.replaceAll(RegExp(r'[^\w\s\.-]'), '_').trim();
        if (!cleanTitle.toLowerCase().endsWith('.pdf')) {
          cleanTitle = '$cleanTitle.pdf';
        }

        final downloadDir = Directory('/storage/emulated/0/Download');
        if (!downloadDir.existsSync()) {
          downloadDir.createSync(recursive: true);
        }

        final file = File('${downloadDir.path}/$cleanTitle');
        await file.writeAsBytes(res.bodyBytes);

        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'کامیابی',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0F5132)),
            ),
            content: Text(
              '$title پی ڈی ایف مکمل ڈاؤنلوڈ ہو گیا',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('ٹھیک ہے', style: TextStyle(color: Color(0xFF0F5132), fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${res.statusCode}')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F5132),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F5132)))
          : _error != null
              ? Center(child: Text(_error!))
              : _pdfs.isEmpty
                  ? const Center(child: Text('Is class me koi PDF file nahi mili.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _pdfs.length,
                      itemBuilder: (context, index) {
                        final p = _pdfs[index];
                        final String title = p['title'] ?? 'Syllabus PDF';
                        final String fileUrl = p['file_url'] ?? '';

                        return Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Uploaded: ${p['uploaded_at']}',
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.visibility, size: 16),
                                      label: const Text('Open'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF0F5132),
                                      ),
                                      onPressed: () {
                                        _openInAppPdfViewer(fileUrl, title);
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.download, size: 16),
                                      label: const Text('Download'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F5132),
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        _downloadPdfDirectly(fileUrl, title);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

// Full In-App PDF Viewer Screen
class NativeInAppPdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String title;
  const NativeInAppPdfViewer({super.key, required this.pdfUrl, required this.title});

  @override
  State<NativeInAppPdfViewer> createState() => _NativeInAppPdfViewerState();
}

class _NativeInAppPdfViewerState extends State<NativeInAppPdfViewer> {
  String? _localPath;
  bool _loading = true;
  String? _error;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
  }

  Future<void> _downloadAndLoadPdf() async {
    try {
      final res = await http.get(Uri.parse(widget.pdfUrl)).timeout(const Duration(seconds: 35));
      if (res.statusCode == 200) {
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(res.bodyBytes);
        if (mounted) {
          setState(() {
            _localPath = file.path;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() { _error = 'PDF load nahi ho saki: ${res.statusCode}'; _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Check internet connection'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF0F5132),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${_currentPage + 1}/$_totalPages',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0F5132)),
                  SizedBox(height: 14),
                  Text('Opening PDF Document...', style: TextStyle(color: Colors.black54)),
                ],
              ),
            )
          : _error != null
              ? Center(child: Text(_error!))
              : _localPath != null
                  ? PDFView(
                      filePath: _localPath!,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: true,
                      onRender: (pages) {
                        setState(() {
                          _totalPages = pages ?? 0;
                        });
                      },
                      onPageChanged: (page, total) {
                        setState(() {
                          _currentPage = page ?? 0;
                        });
                      },
                    )
                  : const Center(child: Text('Document nahi mila')),
    );
  }
}

// Gallery & Player
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

  void _openExoPlayer(BuildContext context, String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsAppStylePlayerScreen(videoUrl: videoUrl),
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
      return const Center(
        child: Text('No items available yet', style: TextStyle(color: Colors.grey)),
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
                  if (widget.resourceType == 'image') {
                    _openImageViewer(context, url);
                  } else {
                    _openExoPlayer(context, url);
                  }
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

class WhatsAppStylePlayerScreen extends StatefulWidget {
  final String videoUrl;
  const WhatsAppStylePlayerScreen({super.key, required this.videoUrl});

  @override
  State<WhatsAppStylePlayerScreen> createState() => _WhatsAppStylePlayerScreenState();
}

class _WhatsAppStylePlayerScreenState extends State<WhatsAppStylePlayerScreen> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _startHideTimer();
      });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) _startHideTimer();
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(color: Color(0xFFFFCC00)),
            ),
            if (_showControls) ...[
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Center(
                child: IconButton(
                  iconSize: 64,
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white.withOpacity(0.85),
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                      _startHideTimer();
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFFFFCC00),
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
