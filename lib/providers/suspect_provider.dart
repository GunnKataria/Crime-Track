import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/suspect.dart';
import 'package:crime_management_system/services/json_storage_service.dart';
import 'package:uuid/uuid.dart';

final suspectProvider = StateNotifierProvider<SuspectNotifier, List<Suspect>>((ref) {
  return SuspectNotifier();
});

class SuspectNotifier extends StateNotifier<List<Suspect>> {
  SuspectNotifier() : super([]) {
    loadSuspects();
  }

  final JsonStorageService _storageService = JsonStorageService();
  final Uuid _uuid = const Uuid();
  
  Future<void> loadSuspects() async {
    final suspectsJson = await _storageService.loadSuspects();
    state = suspectsJson.map((json) => Suspect.fromJson(json)).toList();
  }
  
  Future<void> addSuspect(Suspect suspect) async {
    final newSuspect = suspect.copyWith(
      id: _uuid.v4(),
    );
    
    state = [...state, newSuspect];
    await _saveSuspects();
  }
  
  Future<void> updateSuspect(Suspect updatedSuspect) async {
    state = state.map((suspect) {
      return suspect.id == updatedSuspect.id ? updatedSuspect : suspect;
    }).toList();
    
    await _saveSuspects();
  }
  
  Future<void> deleteSuspect(String id) async {
    state = state.where((suspect) => suspect.id != id).toList();
    await _saveSuspects();
  }
  
  Future<void> _saveSuspects() async {
    final suspectsJson = state.map((suspect) => suspect.toJson()).toList();
    await _storageService.saveSuspects(suspectsJson);
  }
  
  List<Suspect> getSuspectsByCrimeId(String crimeId) {
    return state.where((suspect) => suspect.relatedCrimeIds.contains(crimeId)).toList();
  }
  
  List<Suspect> getSuspectsByStatus(String status) {
    return state.where((suspect) => suspect.status == status).toList();
  }
  
  Suspect? getSuspectById(String id) {
    try {
      return state.firstWhere((suspect) => suspect.id == id);
    } catch (e) {
      return null;
    }
  }
}
