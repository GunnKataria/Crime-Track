import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/witness.dart';
import 'package:crime_management_system/services/json_storage_service.dart';
import 'package:uuid/uuid.dart';

final witnessProvider = StateNotifierProvider<WitnessNotifier, List<Witness>>((ref) {
  return WitnessNotifier();
});

class WitnessNotifier extends StateNotifier<List<Witness>> {
  WitnessNotifier() : super([]) {
    loadWitnesses();
  }

  final JsonStorageService _storageService = JsonStorageService();
  final Uuid _uuid = const Uuid();
  
  Future<void> loadWitnesses() async {
    final witnessesJson = await _storageService.loadWitnesses();
    state = witnessesJson.map((json) => Witness.fromJson(json)).toList();
  }
  
  Future<void> addWitness(Witness witness) async {
    final newWitness = witness.copyWith(
      id: _uuid.v4(),
    );
    
    state = [...state, newWitness];
    await _saveWitnesses();
  }
  
  Future<void> updateWitness(Witness updatedWitness) async {
    state = state.map((witness) {
      return witness.id == updatedWitness.id ? updatedWitness : witness;
    }).toList();
    
    await _saveWitnesses();
  }
  
  Future<void> deleteWitness(String id) async {
    state = state.where((witness) => witness.id != id).toList();
    await _saveWitnesses();
  }
  
  Future<void> _saveWitnesses() async {
    final witnessesJson = state.map((witness) => witness.toJson()).toList();
    await _storageService.saveWitnesses(witnessesJson);
  }
  
  List<Witness> getWitnessesByCrimeId(String crimeId) {
    return state.where((witness) => witness.relatedCrimeIds.contains(crimeId)).toList();
  }
  
  List<Witness> getWitnessesByCredibility(String credibility) {
    return state.where((witness) => witness.credibilityRating == credibility).toList();
  }
  
  Witness? getWitnessById(String id) {
    try {
      return state.firstWhere((witness) => witness.id == id);
    } catch (e) {
      return null;
    }
  }
}
