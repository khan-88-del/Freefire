import 'package:flutter/material.dart';

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
  late int currentPage;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bookTitle} (Safha: $currentPage)', style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF0F5132),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: const Color(0xFFD4AF37).withOpacity(0.25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Asal Daleel Safha: $currentPage',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F5132)),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      onPressed: () {
                        if (currentPage > 1) setState(() => currentPage--);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () {
                        setState(() => currentPage++);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          widget.bookTitle,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F5132)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text('Safha Number: $currentPage', style: const TextStyle(color: Colors.grey)),
                      ),
                      const Divider(height: 30),
                      const Text(
                        'عبارة الكتاب والأصل الفقهي:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'وإذا سها الإمام أو المنفرد في صلاته بسجود سهو وجب عليه سجدتان بعد السلام بتشهد وسلام، ومحله بعد فراغ الصلاة للحديث الوارد في الباب.',
                        style: TextStyle(fontSize: 18, height: 1.8),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tashreeh o Hukm:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Agar namaz me bhool kar kisi wajib me taakheer ho jaye ya chhoot jaye to salam pher kar do sajde karna wajib hai.',
                        style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          border: Border.all(color: Colors.amber),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Source Document: ${widget.pdfUrl}',
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
