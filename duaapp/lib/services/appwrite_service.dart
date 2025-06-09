import 'package:appwrite/appwrite.dart';
import 'package:dio/dio.dart';

class AppwriteService {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = '68468efc002bf2afb8f4';

  late Client client;
  late Account account;
  late Databases databases;
  late Dio dio;

  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  void init() {
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId)
        .setSelfSigned(status: true); // Remove in production

    account = Account(client);
    databases = Databases(client);

    // Initialize Dio for direct HTTP requests
    dio = Dio();
  }

  Future<bool> ping() async {
    try {
      // Test connection by trying to get current user (will return 401 if not logged in, but that's expected)
      await account.get();
      return true; // If we get here, user is logged in
    } catch (e) {
      print('Account check: $e');
      // Check if it's just an authentication error (401) - this means connection works
      if (e.toString().contains('401') ||
          e.toString().contains('unauthorized')) {
        print(
          'Connection successful - just not authenticated (this is expected)',
        );
        return true;
      }
      // Any other error means real connection issues
      return false;
    }
  }

  // Authentication Methods
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return {'success': true, 'message': 'Login successful', 'user': response};
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // Create user account
      final response = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: '$firstName $lastName',
      );

      // Create email session after registration
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Update user preferences with additional info
      await account.updatePrefs(
        prefs: {
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        },
      );

      return {
        'success': true,
        'message': 'Registration successful',
        'user': response,
      };
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
      return {'success': true, 'message': 'Logout successful'};
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final user = await account.get();
      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid credentials')) {
      return 'Invalid email or password';
    } else if (error.contains('user_already_exists')) {
      return 'User with this email already exists';
    } else if (error.contains('password')) {
      return 'Password must be at least 8 characters';
    } else if (error.contains('email')) {
      return 'Please enter a valid email address';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection';
    }
    return 'Something went wrong. Please try again';
  }
}
