import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JsonStorageService {
  static const String _crimeKey = 'crimes';
  static const String _evidenceKey = 'evidences';
  static const String _witnessKey = 'witnesses';
  static const String _suspectKey = 'suspects';
  static const String _userKey = 'users';
  
  // Load initial data from assets
  Future<void> initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool('isDataInitialized') ?? false;
    
    if (!isInitialized) {
      await _loadInitialData();
      await prefs.setBool('isDataInitialized', true);
    }
  }
  
  Future<void> _loadInitialData() async {
    // Load crimes
    final crimesJson = await rootBundle.loadString('assets/data/crimes.json');
    await _saveData(_crimeKey, crimesJson);
    
    // Load evidences
    final evidencesJson = await rootBundle.loadString('assets/data/evidences.json');
    await _saveData(_evidenceKey, evidencesJson);
    
    // Load witnesses
    final witnessesJson = await rootBundle.loadString('assets/data/witnesses.json');
    await _saveData(_witnessKey, witnessesJson);
    
    // Load suspects
    final suspectsJson = await rootBundle.loadString('assets/data/suspects.json');
    await _saveData(_suspectKey, suspectsJson);
    
    // Load users
    final usersJson = await rootBundle.loadString('assets/data/users.json');
    await _saveData(_userKey, usersJson);
  }
  
  // Save data to local storage
  Future<void> _saveData(String key, String jsonData) async {
    if (kIsWeb) {
      // For web,  localStorage via shared_preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonData);
    } else {
      // For mobile, save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$key.json');
      await file.writeAsString(jsonData);
    }
  }
  
  // Load data from local storage
  Future<String> _loadData(String key) async {
    try {
      if (kIsWeb) {
        // For web, use localStorage via shared_preferences
        final prefs = await SharedPreferences.getInstance();
        final data = prefs.getString(key);
        if (data != null) {
          return data;
        }
      } else {
        // For mobile, load from file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$key.json');
        if (await file.exists()) {
          return await file.readAsString();
        }
      }
      
      // If no data found, load from assets
      return await rootBundle.loadString('assets/data/$key.json');
    } catch (e) {
      // If error or file doesn't exist, return empty array
      return '[]';
    }
  }
  
  // Generic methods for each data type
  Future<List<T>> loadItems<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    final jsonString = await _loadData(key);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => fromJson(item)).toList();
  }
  
  Future<void> saveItems<T>(String key, List<T> items, Map<String, dynamic> Function(T) toJson) async {
    final jsonList = items.map((item) => toJson(item)).toList();
    final jsonString = json.encode(jsonList);
    await _saveData(key, jsonString);
  }
  
  // Specific methods for each model
  Future<List<Map<String, dynamic>>> loadCrimes() async {
    final jsonString = await _loadData(_crimeKey);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }
  
  Future<List<Map<String, dynamic>>> loadEvidences() async {
    final jsonString = await _loadData(_evidenceKey);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }
  
  Future<List<Map<String, dynamic>>> loadWitnesses() async {
    final jsonString = await _loadData(_witnessKey);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }
  
  Future<List<Map<String, dynamic>>> loadSuspects() async {
    final jsonString = await _loadData(_suspectKey);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }
  
  Future<List<Map<String, dynamic>>> loadUsers() async {
    final jsonString = await _loadData(_userKey);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }
  
  Future<void> saveCrimes(List<Map<String, dynamic>> crimes) async {
    await _saveData(_crimeKey, json.encode(crimes));
  }
  
  Future<void> saveEvidences(List<Map<String, dynamic>> evidences) async {
    await _saveData(_evidenceKey, json.encode(evidences));
  }
  
  Future<void> saveWitnesses(List<Map<String, dynamic>> witnesses) async {
    await _saveData(_witnessKey, json.encode(witnesses));
  }
  
  Future<void> saveSuspects(List<Map<String, dynamic>> suspects) async {
    await _saveData(_suspectKey, json.encode(suspects));
  }
  
  Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    await _saveData(_userKey, json.encode(users));
  }
}
