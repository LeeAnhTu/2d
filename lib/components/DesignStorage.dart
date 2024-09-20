import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'design.dart';

class DesignStorage {
  static const String _key = 'saved_designs';

  static Future<void> saveDesign(Design design) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedDesigns = prefs.getStringList(_key) ?? [];
    savedDesigns.add(jsonEncode(design.toJson()));
    await prefs.setStringList(_key, savedDesigns);
  }

  static Future<List<Design>> loadDesigns() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedDesigns = prefs.getStringList(_key) ?? [];
    return savedDesigns.map((jsonString) => Design.fromJson(jsonDecode(jsonString))).toList();
  }

  static Future<void> deleteDesign(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedDesigns = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < savedDesigns.length) {
      savedDesigns.removeAt(index);
      await prefs.setStringList(_key, savedDesigns);
    }
  }
}