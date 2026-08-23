import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';
import '../models/form_config.dart';
import 'jalali_helper.dart';

class StorageService {
  static const String _keyPersonnel = 'personnel_list_v1';
  static const String _keyFormConfig = 'form_config_v1';

  static Future<List<Person>> loadPersonnel() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyPersonnel);
    if (jsonStr == null || jsonStr.trim().isEmpty) {
      return getSamplePersonnel();
    }
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) => Person.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return getSamplePersonnel();
    }
  }

  static Future<void> savePersonnel(List<Person> personnel) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(personnel.map((p) => p.toJson()).toList());
    await prefs.setString(_keyPersonnel, jsonStr);
  }

  static Future<FormConfig> loadFormConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyFormConfig);
    if (jsonStr == null || jsonStr.trim().isEmpty) {
      return FormConfig(
        year: JalaliHelper.currentYear(),
        month: JalaliHelper.currentMonth(),
      );
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return FormConfig.fromJson(map);
    } catch (_) {
      return FormConfig(
        year: JalaliHelper.currentYear(),
        month: JalaliHelper.currentMonth(),
      );
    }
  }

  static Future<void> saveFormConfig(FormConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(config.toJson());
    await prefs.setString(_keyFormConfig, jsonStr);
  }

  static List<Person> getSamplePersonnel() {
    return [
      Person(id: '1', name: 'محسن حسینی', role: 'سرپرست بخش'),
      Person(id: '2', name: 'روح اله عزیزی', role: 'مسئول کارگاه'),
      Person(id: '3', name: 'سیاوش طاهری', role: 'کارشناس فنی'),
      Person(id: '4', name: 'علی رضا کاظمی', role: 'تکنسین'),
      Person(id: '5', name: 'محمد مهدی کریمی', role: 'انباردار'),
      Person(id: '6', name: 'حسین جعفری', role: 'حراست'),
    ];
  }
}
