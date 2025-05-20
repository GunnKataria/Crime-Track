import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/evidence.dart';
import 'package:crime_management_system/services/json_storage_service.dart';
import 'package:uuid/uuid.dart';

final evidenceProvider = StateNotifierProvider<EvidenceNotifier, List<Evidence>>((ref) {
  return EvidenceNotifier();
});

class EvidenceNotifier extends StateNotifier<List<Evidence>> {
  EvidenceNotifier() : super([]) {
    loadEvidences();
  }

  final JsonStorageService _storageService = JsonStorageService();
  final Uuid _uuid = const Uuid();
  
  Future<void> loadEvidences() async {
    final evidencesJson = await _storageService.loadEvidences();
    state = evidencesJson.map((json) => Evidence.fromJson(json)).toList();
  }
  
  Future<void> addEvidence(Evidence evidence) async {
    final newEvidence = evidence.copyWith(
      id: _uuid.v4(),
    );
    
    state = [...state, newEvidence];
    await _saveEvidences();
  }
  
  Future<void> updateEvidence(Evidence updatedEvidence) async {
    state = state.map((evidence) {
      return evidence.id == updatedEvidence.id ? updatedEvidence : evidence;
    }).toList();
    
    await _saveEvidences();
  }
  
  Future<void> deleteEvidence(String id) async {
    state = state.where((evidence) => evidence.id != id).toList();
    await _saveEvidences();
  }
  
  Future<void> _saveEvidences() async {
    final evidencesJson = state.map((evidence) => evidence.toJson()).toList();
    await _storageService.saveEvidences(evidencesJson);
  }
  
  List<Evidence> getEvidencesByCrimeId(String crimeId) {
    return state.where((evidence) => evidence.crimeId == crimeId).toList();
  }
  
  List<Evidence> getEvidencesByType(String type) {
    return state.where((evidence) => evidence.type == type).toList();
  }
  
  List<Evidence> getEvidencesByStatus(String status) {
    return state.where((evidence) => evidence.status == status).toList();
  }
  
  Evidence? getEvidenceById(String id) {
    try {
      return state.firstWhere((evidence) => evidence.id == id);
    } catch (e) {
      return null;
    }
  }
}
