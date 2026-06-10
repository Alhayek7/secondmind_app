import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class SmartAnalyzerService {
  final _textRecognizer = TextRecognizer();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. تحليل صورة
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognized = await _textRecognizer.processImage(inputImage);
      return analyzeText(recognized.text);
    } catch (e) {
      debugPrint('❌ خطأ في تحليل الصورة: $e');
      return _emptyResult();
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. تحليل نص مباشر
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Map<String, dynamic> analyzeText(String text) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📋 بدء تحليل النص...');
    debugPrint('النص الخام:\n$text');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final result = {
      'title': _extractTitle(text),
      'date': _extractDate(text),
      'time': _extractTime(text),
      'location': _extractLocation(text),
      'organizer': _extractOrganizer(text),
      'attendance_type': _extractAttendanceType(text),
      'registration_link': _extractLink(text),
      'fee': _extractFee(text),
      'notes': _extractNotes(text),
      'raw_text': text,
    };

    debugPrint('📊 النتيجة المستخرجة:');
    result.forEach((k, v) => debugPrint('  🔹 $k: $v'));
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return result;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // استخراج العنوان
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
String? _extractTitle(String text) {
  final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();

  // قائمة الكلمات المفتاحية للعناوين
  final titleKeywords = [
    'ورشة', 'دورة', 'محاضرة', 'مؤتمر', 'فعالية', 'تدريب', 'bootcamp',
    'Flutter', 'AI', 'Tech', 'برمجة', 'تطوير', 'workshop', 'course',
    'webinar', 'seminar', 'training', 'hackathon', 'meetup', 'summit',
    'generation', 'club', 'session', 'talk', 'مهارات', 'تقنية'
  ];

  // البحث عن سطر يحتوي على كلمة مفتاحية
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.length < 5 || trimmed.length > 100) continue;
    
    for (final kw in titleKeywords) {
      if (trimmed.toLowerCase().contains(kw.toLowerCase())) {
        // تنظيف النص من الرموز الغريبة
        final cleaned = _cleanTitle(trimmed);
        if (cleaned.isNotEmpty) return cleaned;
      }
    }
  }

  // البحث عن أول سطر يبدو كعنوان (لا يحتوي على أرقام كثيرة)
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.length >= 8 && trimmed.length <= 60) {
      // تجاهل الأسطر التي تحتوي على روابط أو تواريخ
      if (!trimmed.contains('http') && 
          !RegExp(r'^\d+[/\-]?\d*$').hasMatch(trimmed) &&
          RegExp(r'[أ-يa-zA-Z]').hasMatch(trimmed)) {
        final cleaned = _cleanTitle(trimmed);
        if (cleaned.isNotEmpty) return cleaned;
      }
    }
  }

  return null;
}

// دالة مساعدة لتنظيف العنوان من الرموز الغريبة
String _cleanTitle(String text) {
  // إزالة الرموز الغريبة والمسافات الزائدة
  var cleaned = text.replaceAll(RegExp(r'[^\u0621-\u064A\u0660-\u0669a-zA-Z0-9\s]'), ' ');
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  
  // إزالة الكلمات القصيرة جداً
  if (cleaned.length < 3) return '';
  
  return cleaned;
}

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // استخراج التاريخ
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
String? _extractDate(String text) {
  // تنظيف النص أولاً
  final cleaned = text.replaceAll(RegExp(r'[^\u0621-\u064A\u0660-\u0669a-zA-Z0-9/\-\s]'), ' ');
  
  final patterns = [
    RegExp(r'\b(\d{4})[-/](\d{1,2})[-/](\d{1,2})\b'), // 2026-6-15
    RegExp(r'\b(\d{1,2})[-/](\d{1,2})[-/](\d{4})\b'), // 15-6-2026
    RegExp(r'\b(\d{1,2})[-/](\d{1,2})[-/](\d{2})\b'),  // 15-6-26
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(cleaned);
    if (match != null) {
      var year = match.group(1) ?? '';
      var month = match.group(2) ?? '';
      var day = match.group(3) ?? '';
      
      // تحديد أي جزء هو السنة
      if (year.length == 4 || (year.length == 2 && int.parse(year) > 30)) {
        // year هو السنة
      } else if (day.length == 4 || (day.length == 2 && int.parse(day) > 30)) {
        // swap
        final temp = year;
        year = day;
        day = temp;
      }
      
      if (year.length == 2) year = '20$year';
      if (month.length == 1) month = '0$month';
      if (day.length == 1) day = '0$day';
      
      return '$year-$month-$day';
    }
  }
  
  return null;
}

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // استخراج الوقت
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  String? _extractTime(String text) {
    final patterns = [
      // 11:00 أو 7:30
      RegExp(r'\b(\d{1,2}:\d{2})\b'),
      // 7-9 مساءً أو 9-7
      RegExp(
          r'\b(\d{1,2})\s*[-–]\s*(\d{1,2})\s*(مساءً|صباحاً|مساء|صباح|PM|AM)?\b'),
      // 7:00 PM
      RegExp(r'\b(\d{1,2}:\d{2})\s*(PM|AM|مساءً|صباحاً|مساء|صباح)\b'),
      // 7 مساءً
      RegExp(r'\b(\d{1,2})\s*(مساءً|صباحاً|مساء|صباح)\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final t = match.group(0)?.trim();
        // تجاهل التاريخ مثل 6-6-2026
        if (t != null &&
            !RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}').hasMatch(t)) {
          return t;
        }
      }
    }
    return null;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // استخراج المكان
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  String? _extractLocation(String text) {
    final patterns = [
      RegExp(r'(المكان|الموقع|العنوان|location|venue|place)\s*[:\-]?\s*(.+)',
          caseSensitive: false),
      RegExp(r'(في|at|@)\s+([أ-يa-zA-Z0-9\s]{3,40})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final loc = match.group(2)?.trim();
        if (loc != null && loc.isNotEmpty) return loc;
      }
    }

    // كلمات تدل على المكان
    final locationKeywords = [
      'قاعة',
      'مركز',
      'فندق',
      'مسرح',
      'hall',
      'center',
      'hotel'
    ];
    for (final line in text.split('\n')) {
      for (final kw in locationKeywords) {
        if (line.toLowerCase().contains(kw)) return line.trim();
      }
    }

    return null;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // استخراج الجهة المنظمة
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  String? _extractOrganizer(String text) {
    final patterns = [
      RegExp(
          r'(تقديم|يقدم|بإشراف|المنظم|organized by|presented by|by)\s*[:\-]?\s*(.+)',
          caseSensitive: false),
      RegExp(r'(المهندس|الدكتور|د\.|م\.|eng\.|dr\.)\s+([أ-يa-zA-Z\s]{3,30})',
          caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final org = match.group(2)?.trim();
        if (org != null && org.isNotEmpty) return org;
      }
    }
    return null;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // استخراج نوع الحضور
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  String _extractAttendanceType(String text) {
    final lower = text.toLowerCase();

    final onlineKeywords = [
      'أونلاين',
      'online',
      'عن بعد',
      'zoom',
      'meet',
      'teams',
      'افتراضي',
      'virtual',
      'google',
      'docs.google',
      'instagram',
      'facebook',
      'youtube',
      'live',
      'qafza',
      'qafzafortech',
    ];
    final hybridKeywords = ['هجين', 'hybrid', 'حضوري وأونلاين', 'مزيج'];
    final offlineKeywords = ['حضوري', 'in person', 'in-person', 'وجاهي'];

    if (hybridKeywords.any((k) => lower.contains(k))) return 'hybrid';
    if (onlineKeywords.any((k) => lower.contains(k))) return 'online';
    if (offlineKeywords.any((k) => lower.contains(k))) return 'in_person';

    return 'unknown';
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // استخراج رابط التسجيل
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  String? _extractLink(String text) {
    final pattern = RegExp(
      r'https?://[^\s\n]+',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);
    return match?.group(0)?.trim();
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // استخراج الرسوم
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
String? _extractFee(String text) {
  if (text.contains('مجاني') || text.contains('مجانا') || 
      text.contains('free') || text.contains('100') && text.contains('ريال')) {
    if (text.contains('100') && text.contains('ريال')) return '100 ريال';
    if (text.contains('مجاني')) return 'مجاني';
  }
  
  final patterns = [
    RegExp(r'(\d+)\s*(ريال|دولار|دينار|SAR|USD)', caseSensitive: false),
    RegExp(r'(مجان[اً]?|free|بالمجان)', caseSensitive: false),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(text);
    if (match != null) return match.group(0)?.trim();
  }
  return null;
}

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // استخراج ملاحظات إضافية
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  String? _extractNotes(String text) {
    final patterns = [
      RegExp(r'(ملاحظة|تنبيه|مهم|note|important)\s*[:\-]?\s*(.+)',
          caseSensitive: false),
      RegExp(r'(المستوى|level)\s*[:\-]?\s*(.+)', caseSensitive: false),
      RegExp(r'(متطلبات|requirements)\s*[:\-]?\s*(.+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final note = match.group(0)?.trim();
        if (note != null && note.isNotEmpty) return note;
      }
    }
    return null;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // نتيجة فارغة عند الخطأ
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Map<String, dynamic> _emptyResult() => {
        'title': null,
        'date': null,
        'time': null,
        'location': null,
        'organizer': null,
        'attendance_type': 'unknown',
        'registration_link': null,
        'fee': null,
        'notes': null,
        'raw_text': '',
      };

  void dispose() => _textRecognizer.close();
}
