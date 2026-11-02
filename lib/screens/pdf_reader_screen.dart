import 'package:flutter/material.dart';

class PdfReaderScreen extends StatelessWidget {
  final String pdfUrl;
  final int initialPage;
  final String bookTitle;

  const PdfReaderScreen({
    super.key,
    required this.pdfUrl,
    required this.initialPage,
    required this.bookTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$bookTitle (Safha: $initialPage)', style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF0F5132),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              child: Text(
                'AI Verified Daleel Page: Safha $initialPage',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[100],
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Book Reader View: Safha $initialPage\nResource: $pdfUrl',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
