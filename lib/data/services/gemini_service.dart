import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:secondmind/core/constants/app_constants.dart';
import 'dart:convert';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<Map<String, dynamic>> extractTaskDetails(String text) async {
    final prompt = '''
أنت مساعد ذكي لاستخراج تفاصيل الفعاليات والورشات.
أخرج JSON فقط بدون أي نص إضافي.

النص:
$text

التنسيق المطلوب:
{
  "title": "عنوان الفعالية",
  "date": "YYYY-MM-DD أو null",
  "time": "HH:MM أو null",
  "location": "المكان أو null",
  "organizer": "الجهة المنظمة أو null",
  "attendance_type": "online أو in_person أو hybrid أو null",
  "registration_link": "رابط التسجيل أو null",
  "fee": "الرسوم أو null",
  "topics": "محاور الفعالية مرقمة بشكل واضح، كل محور في سطر"
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final result = response.text ?? '{}';
      final parsed = jsonDecode(result) as Map<String, dynamic>;

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📋 النتيجة المستخرجة من Gemini:');
      parsed.forEach((key, value) => print('  🔹 $key: $value'));
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return parsed;
    } catch (e) {
      print('❌ خطأ في Gemini: $e');
      return {'error': e.toString()};
    }
  }
}