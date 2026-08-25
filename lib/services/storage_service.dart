import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';
import '../models/personnel_list.dart';
import '../models/form_config.dart';
import 'jalali_helper.dart';

class StorageService {
  static const String _keyPersonnel = 'personnel_list_v1';
  static const String _keyPersonnelLists = 'personnel_multi_lists_v1';
  static const String _keyActiveListId = 'active_personnel_list_id_v1';
  static const String _keyFormConfig = 'form_config_v1';

  /// Loads all saved personnel lists. Migrates legacy single list if found.
  static Future<List<PersonnelList>> loadAllPersonnelLists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyPersonnelLists);

    if (jsonStr != null && jsonStr.trim().isNotEmpty) {
      try {
        final List<dynamic> raw = jsonDecode(jsonStr);
        final lists = raw
            .map((item) =>
                PersonnelList.fromJson(item as Map<String, dynamic>))
            .toList();
        if (lists.isNotEmpty) {
          return lists;
        }
      } catch (_) {}
    }

    // Migration from legacy single list if exists
    final legacyJsonStr = prefs.getString(_keyPersonnel);
    List<Person> initialMembers = [];
    if (legacyJsonStr != null && legacyJsonStr.trim().isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(legacyJsonStr);
        initialMembers = list
            .map((item) => Person.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    final defaultList = PersonnelList(
      id: 'default_list',
      name: 'لیست اصلی',
      members: initialMembers,
    );

    final initialLists = [defaultList];
    await saveAllPersonnelLists(initialLists);
    return initialLists;
  }

  /// Saves all personnel lists to storage.
  static Future<void> saveAllPersonnelLists(
      List<PersonnelList> lists) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(lists.map((l) => l.toJson()).toList());
    await prefs.setString(_keyPersonnelLists, jsonStr);
  }

  /// Loads the ID of the currently selected active list.
  static Future<String?> loadActiveListId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActiveListId);
  }

  /// Saves the ID of the active list.
  static Future<void> saveActiveListId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveListId, id);
  }

  /// Loads the active personnel members.
  static Future<List<Person>> loadPersonnel() async {
    final lists = await loadAllPersonnelLists();
    final activeId = await loadActiveListId();
    if (lists.isEmpty) return [];
    if (activeId != null) {
      final found = lists.firstWhere(
        (l) => l.id == activeId,
        orElse: () => lists.first,
      );
      return found.members;
    }
    return lists.first.members;
  }

  /// Saves the given personnel into the active list.
  static Future<void> savePersonnel(List<Person> personnel) async {
    final lists = await loadAllPersonnelLists();
    final activeId = await loadActiveListId();
    final activeIndex = (activeId != null)
        ? lists.indexWhere((l) => l.id == activeId)
        : 0;

    final targetIndex = activeIndex >= 0 ? activeIndex : 0;
    if (lists.isNotEmpty) {
      lists[targetIndex] = lists[targetIndex].copyWith(members: personnel);
      await saveAllPersonnelLists(lists);
    } else {
      final newList = PersonnelList(
        id: 'default_list',
        name: 'لیست اصلی',
        members: personnel,
      );
      await saveAllPersonnelLists([newList]);
    }
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
}
