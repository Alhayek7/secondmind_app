// lib/data/services/smart_analyzer.dart
import 'package:flutter/foundation.dart';

class SmartAnalyzer {
  
  // نقاط الأنماط (Patterns) المختلفة
  final Map<String, List<RegExp>> patterns = {
    'date': [
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'), // 6-6-2026
      RegExp(r'(\d{1,2})\s*/\s*(\d{1,2})\s*/\s*(\d{2,4})'), // 6 / 6 / 2026
      RegExp(r'(\d{1,2})\s+(\d{1,2})\s+(\d{4})'), // 6 6 2026
    ],
    'time': [
      RegExp(r'(\d{1,2})\s*[-–]\s*(\d{1,2})\s*(مساء|صباح|م|ص)?'), // 9-7 مساءً
      RegExp(r'(\d{1,2}):(\d{2})\s*(مساء|صباح)?'), // 21:00
      RegExp(r'(\d{1,2})\s*(مساء|صباح|م|ص)'), // 9 مساءً
    ],
    'arabicNumbers': [
      RegExp(r'[٠-٩]'), // الأرقام العربية
    ],
  };
  
  // قائمة الكلمات المفتاحية
  final Map<String, List<String>> keywords = {
    'online': ['أونلاين', 'اونلاين', 'online', 'عن بعد', 'عن بُعد'],
    'in_person': ['وجاهي', 'حضوري', 'في المكان'],
    'free': ['مجاني', 'مجانا', 'free', 'بدون رسوم'],
    'urgent': ['عاجل', 'هام جداً', 'urgent', 'ASAP'],
    'high': ['مرتفع', 'عالية', 'high'],
    'medium': ['متوسط', 'medium'],
    'low': ['منخفض', 'low', 'بسيط'],
  };
  
  // معالجة وتحليل النص الرئيسية
  Map<String, dynamic> analyzeText(String text) {
    debugPrint('🔍 بدء تحليل النص...');
    
    final result = <String, dynamic>{};
    
    // تنظيف النص
    final cleanedText = _cleanText(text);
    debugPrint('📝 النص بعد التنظيف:\n$cleanedText');
    
    // استخراج البيانات
    result['title'] = _extractTitle(cleanedText);
    result['date'] = _extractDate(cleanedText);
    result['time'] = _extractTime(cleanedText);
    result['location'] = _extractLocation(cleanedText);
    result['organizer'] = _extractOrganizer(cleanedText);
    result['attendance_type'] = _extractAttendanceType(cleanedText);
    result['fee'] = _extractFee(cleanedText);
    result['priority'] = _extractPriority(cleanedText);
    result['registration_link'] = _extractUrl(cleanedText);
    result['notes'] = cleanedText.substring(0, cleanedText.length > 300 ? 300 : cleanedText.length);
    
    // التأكد من وجود عنوان
    if (result['title'].isEmpty) {
      final lines = cleanedText.split('\n');
      for (var line in lines) {
        if (line.trim().isNotEmpty && line.length > 5 && line.length < 100) {
          result['title'] = line.trim();
          break;
        }
      }
    }
    
    debugPrint('✅ اكتمل التحليل');
    return result;
  }
  
  // تنظيف النص العربي
  String _cleanText(String text) {
    // إزالة المسافات الزائدة
    var cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // تحويل الأرقام العربية إلى إنجليزية
    final arabicNumbers = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9'
    };
    arabicNumbers.forEach((arabic, english) {
      cleaned = cleaned.replaceAll(arabic, english);
    });
    
    return cleaned;
  }
  
  // استخراج العنوان
  String _extractTitle(String text) {
    final lines = text.split('\n');
    
    // البحث عن عنوان مناسب (أول سطر غير فارغ وقصير)
    for (var line in lines) {
      line = line.trim();
      if (line.isNotEmpty && line.length > 3 && line.length < 150) {
        // تجاهل الأسطر التي تبدو كروابط أو أرقام فقط
        if (!line.startsWith('http') && !RegExp(r'^\d+$').hasMatch(line)) {
          return line;
        }
      }
    }
    return '';
  }
  
  // استخراج التاريخ
  String? _extractDate(String text) {
    for (var pattern in patterns['date']!) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String day = match.group(1) ?? '';
        String month = match.group(2) ?? '';
        String year = match.group(3) ?? '';
        
        // معالجة الحالات المختلفة
        if (day.length == 1) day = '0$day';
        if (month.length == 1) month = '0$month';
        if (year.length == 2) year = '20$year';
        
        // التحقق من صحة التاريخ
        final intDay = int.tryParse(day) ?? 0;
        final intMonth = int.tryParse(month) ?? 0;
        if (intDay >= 1 && intDay <= 31 && intMonth >= 1 && intMonth <= 12) {
          return '$year-$month-$day';
        }
      }
    }
    
    // معالجة "غداً"
    if (text.contains('غداً') || text.contains('غدا')) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    }
    
    return null;
  }
  
  // استخراج الوقت
  String? _extractTime(String text) {
    for (var pattern in patterns['time']!) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String hour = match.group(1) ?? '';
        String minute = match.group(2) ?? '00';
        String period = match.group(3) ?? '';
        
        int hourInt = int.tryParse(hour) ?? 0;
        
        // معالجة الفترة (صباح/مساء)
        if (period.contains('مساء') || period.contains('م')) {
          if (hourInt < 12) hourInt += 12;
        } else if (period.contains('صباح') || period.contains('ص')) {
          if (hourInt == 12) hourInt = 0;
        }
        
        hour = hourInt.toString().padLeft(2, '0');
        minute = minute.padLeft(2, '0');
        
        return '$hour:$minute';
      }
    }
    return null;
  }
  
  // استخراج المكان
  String? _extractLocation(String text) {
    final locationKeywords = ['مكان', 'في', 'شارع', 'مبنى', 'مركز', 'جامعة', 'قاعة', 'عيادة', 'مستشفى'];
    final lines = text.split('\n');
    
    for (var line in lines) {
      for (var keyword in locationKeywords) {
        if (line.contains(keyword) && line.length > 10 && line.length < 150) {
          return line.trim();
        }
      }
    }
    return null;
  }
  
  // استخراج الجهة المنظمة
  String? _extractOrganizer(String text) {
    final organizerKeywords = ['المهندس', 'دكتور', 'د.', 'شركة', 'مؤسسة', 'مركز', 'منظمة', 'نادي'];
    final lines = text.split('\n');
    
    for (var line in lines) {
      for (var keyword in organizerKeywords) {
        if (line.contains(keyword) && line.length > 5 && line.length < 100) {
          return line.trim();
        }
      }
    }
    return null;
  }
  
  // استخراج نوع الحضور
  String _extractAttendanceType(String text) {
    for (var keyword in keywords['online']!) {
      if (text.contains(keyword)) return 'online';
    }
    for (var keyword in keywords['in_person']!) {
      if (text.contains(keyword)) return 'in_person';
    }
    return 'hybrid';
  }
  
  // استخراج الرسوم
  String? _extractFee(String text) {
    for (var keyword in keywords['free']!) {
      if (text.contains(keyword)) return 'مجاني';
    }
    
    final feePattern = RegExp(r'(\d+)\s*(ريال|دولار|دينار|دولار أمريكي)');
    final match = feePattern.firstMatch(text);
    if (match != null) {
      return '${match[1]} ${match[2]}';
    }
    return null;
  }
  
  // استخراج الأولوية
  String _extractPriority(String text) {
    if (_containsKeywords(text, keywords['urgent']!)) return 'urgent';
    if (_containsKeywords(text, keywords['high']!)) return 'high';
    if (_containsKeywords(text, keywords['medium']!)) return 'medium';
    return 'low';
  }
  
  // استخراج رابط التسجيل
  String? _extractUrl(String text) {
    final urlPattern = RegExp(r'https?://[^\s\n]+');
    final match = urlPattern.firstMatch(text);
    return match?.group(0);
  }
  
  bool _containsKeywords(String text, List<String> keywordsList) {
    for (var keyword in keywordsList) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }
}