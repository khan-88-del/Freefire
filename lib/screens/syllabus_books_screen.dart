import 'package:flutter/material.dart';

class SyllabusBooksScreen extends StatelessWidget {
  const SyllabusBooksScreen({super.key});

  final List<String> classes = const [
    'Hifz-ul-Quran',
    'Darja Awwal (Idadiyah)',
    'Darja Saniyah',
    'Darja Salisah',
    'Darja Rabia',
    'Daura-e-Hadith',
    'Shoba-e-Ifta'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Syllabus & All Classes', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF059669)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          return ListTile(
            leading: const Icon(Icons.folder, color: Color(0xFF059669)),
            title: Text(classes[i], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Syllabus + Darsi Kutub PDF'),
            trailing: const Icon(Icons.download, color: Colors.grey),
            onTap: () {},
          );
        },
      ),
    );
  }
}
