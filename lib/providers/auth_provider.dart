import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/user.dart';
import 'package:crime_management_system/services/json_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null) {
    _loadCurrentUser();
  }

  final JsonStorageService _storageService = JsonStorageService();

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');
    
    if (userId != null) {
      final users = await _storageService.loadUsers();
      final currentUser = users.firstWhere(
        (user) => user['id'] == userId,
        orElse: () => <String, dynamic>{},
      );
      
      if (currentUser.isNotEmpty) {
        state = User.fromJson(currentUser);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    // In a real app, you would validate the password
    // Here we're just checking if the user exists with the given email
    final users = await _storageService.loadUsers();
    final userJson = users.firstWhere(
      (user) => user['email'] == email,
      orElse: () => <String, dynamic>{},
    );
    
    if (userJson.isNotEmpty) {
      final user = User.fromJson(userJson);
      state = user;
      
      // Save current user ID to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', user.id);
      
      return true;
    }
    
    return false;
  }

  Future<void> logout() async {
    state = null;
    
    // Clear current user ID from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
  }

  bool get isAuthenticated => state != null;
  bool get isOfficer => state?.role == UserRole.officer || state?.role == UserRole.admin;
  bool get isAdmin => state?.role == UserRole.admin;
}
