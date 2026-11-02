import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfReaderScreen extends StatefulWidget {
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
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bookTitle} (Safha: ${widget.initialPage})', style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF0F5132),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            child: Text(
              'AI Verified Daleel Page: Safha ${widget.initialPage}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SfPdfViewer.network(
              widget.pdfUrl,
              controller: _pdfViewerController,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                if (widget.initialPage > 0) {
                  _pdfViewerController.jumpToPage(widget.initialPage);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
