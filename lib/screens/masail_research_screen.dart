import 'package:flutter/material.dart';
import '../services/ai_research_service.dart';
import 'pdf_reader_screen.dart';

class MasailResearchScreen extends StatefulWidget {
  const MasailResearchScreen({super.key});

  @override
  State<MasailResearchScreen> createState() => _MasailResearchScreenState();
}

class _MasailResearchScreenState extends State<MasailResearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  final AiResearchService _aiService = AiResearchService();

  bool _isLoading = false;
  Map<String, dynamic>? _aiResponse;

  final List> _availableBooks = [
    {
      'title': 'Radd al-Muhtar (Fatawa Shami)',
      'author': 'Allama Ibn Abidin',
      'pdfUrl': 'https://example.com/books/shami.pdf',
    },
    {
      'title': 'Al-Hidayah',
      'author': 'Allama Marghinani',
      'pdfUrl': 'https://example.com/books/hidayah.pdf',
    },
    {
      'title': 'Fatawa Alamgiri (Al-Hindiyyah)',
      'author': 'Majlis Ulama',
      'pdfUrl': 'https://example.com/books/alamgiri.pdf',
    },
    {
      'title': 'Bahar-e-Shariat',
      'author': 'Mufti Amjad Ali Azmi',
      'pdfUrl': 'https://example.com/books/bahar.pdf',
    },
  ];

  void _searchMasla() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _aiResponse = null;
    });

    final result = await _aiService.queryMasla(query);

    setState(() {
      _isLoading = false;
      _aiResponse = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tehqeeq Masail o Fatawa', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7C3AED),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: TextField(
                controller: _queryController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Apna masla yahan darj karein (e.g. Sajda sahw ka bayan)...',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF7C3AED)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF7C3AED)),
                    onPressed: _searchMasla,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF7C3AED)),
                      SizedBox(height: 12),
                      Text('Server kutub scan ho rahi hain...', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            if (_aiResponse != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC084FC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified, color: Color(0xFF7C3AED)),
                        SizedBox(width: 8),
                        Text(
                          'Tehqeeq o Tashreeh (AI Powered):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF581C87)),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      _aiResponse!['explanation'] ?? '',
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.menu_book, color: Color(0xFF7C3AED), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Daleel: ${_aiResponse!['bookTitle']} (Jild: ${_aiResponse!['volume']}, Safha: ${_aiResponse!['pageNumber']})',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Usi Kitaab Ka Yeh Safha Kholein'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfReaderScreen(
                              pdfUrl: _aiResponse!['pdfUrl'],
                              initialPage: _aiResponse!['pageNumber'],
                              bookTitle: _aiResponse!['bookTitle'],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Server Par Maujood Fiqh o Fatawa Kutub:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _availableBooks.length,
              itemBuilder: (context, index) {
                final b = _availableBooks[index];
                return Card(
                  elevation: 0.5,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                    title: Text(b['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(b['author']!),
                    trailing: const Text('Read', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfReaderScreen(
                            pdfUrl: b['pdfUrl']!,
                            initialPage: 1,
                            bookTitle: b['title']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
