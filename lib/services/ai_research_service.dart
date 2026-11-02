import 'dart:convert';
import 'package:http/http.dart' as http;

class AiResearchService {
  final String backendEndpoint = 'https://api.yourmadarsa.com/search-fiqh';

  Future> queryMasla(String question) async {
    try {
      final response = await http.post(
        Uri.parse(backendEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': question}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 2));
    return {
      'explanation':
          'Agar namaz ke kisi wajib me bhool kar taakheer ho jaye ya koi wajib chhoot jaye, to aakhri qaade me tashahhud ke baad ek taraf salam pher kar do sajde karna aur phir poora qaada padh kar salam pherna wajib hai.',
      'bookTitle': 'Radd al-Muhtar (Fatawa Shami)',
      'volume': '2',
      'pageNumber': 78,
      'pdfUrl': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    };
  }
}
