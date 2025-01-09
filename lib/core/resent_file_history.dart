import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentFileHistoryNotifier extends ChangeNotifier {
  static const _key = "recent_history";
  static const historyCache = 10;

  Future<SharedPreferences> _getPrefs() async => SharedPreferences.getInstance();

  Future<List<String>> findAll() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => item as String).toList();
    } catch (e) {
      // パースエラー時は空リストを返す
      return [];
    }
  }

  Future<void> _updateHistory(List<String> newHistory) async {
    final prefs = await _getPrefs();
    await prefs.setString(_key, json.encode(newHistory));
  }

  Future<void> add(String fileName) async {
    final currentHistory = await findAll();
    if (currentHistory.contains(fileName)) return;

    currentHistory.insert(0, fileName);
    if (currentHistory.length > historyCache) {
      currentHistory.removeLast();
    }
    await _updateHistory(currentHistory);
    notifyListeners();
  }

  Future<void> removeAt(int index) async {
    final currentHistory = await findAll();
    if (index < 0 || index >= currentHistory.length) return;

    currentHistory.removeAt(index);
    await _updateHistory(currentHistory);
    notifyListeners();
  }

  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.remove(_key);
  }
}

final recentFileHistoryProvider = ChangeNotifierProvider((ref) => RecentFileHistoryNotifier());
