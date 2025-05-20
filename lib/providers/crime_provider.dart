import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/crime.dart';
import 'package:crime_management_system/services/json_storage_service.dart';
import 'package:uuid/uuid.dart';

final crimeProvider = StateNotifierProvider<CrimeNotifier, List<Crime>>((ref) {
  return CrimeNotifier();
});

class CrimeNotifier extends StateNotifier<List<Crime>> {
  CrimeNotifier() : super([]) {
    loadCrimes();
  }

  final JsonStorageService _storageService = JsonStorageService();
  final Uuid _uuid = const Uuid();
  
  Future<void> loadCrimes() async {
    final crimesJson = await _storageService.loadCrimes();
    state = crimesJson.map((json) => Crime.fromJson(json)).toList();
  }
  
  Future<void> addCrime(Crime crime) async {
    final newCrime = crime.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    
    state = [...state, newCrime];
    await _saveCrimes();
  }
  
  Future<void> updateCrime(Crime updatedCrime) async {
    state = state.map((crime) {
      return crime.id == updatedCrime.id ? updatedCrime : crime;
    }).toList();
    
    await _saveCrimes();
  }
  
  Future<void> deleteCrime(String id) async {
    state = state.where((crime) => crime.id != id).toList();
    await _saveCrimes();
  }
  
  Future<void> _saveCrimes() async {
    final crimesJson = state.map((crime) => crime.toJson()).toList();
    await _storageService.saveCrimes(crimesJson);
  }
  
  List<Crime> getCrimesByStatus(String status) {
    return state.where((crime) => crime.status == status).toList();
  }
  
  List<Crime> getCrimesByType(String type) {
    return state.where((crime) => crime.type == type).toList();
  }
  
  List<Crime> getCrimesByOfficer(String officerId) {
    return state.where((crime) => crime.assignedOfficer == officerId).toList();
  }
  
  Crime? getCrimeById(String id) {
    try {
      return state.firstWhere((crime) => crime.id == id);
    } catch (e) {
      return null;
    }
  }
}
