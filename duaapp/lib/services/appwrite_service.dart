import 'package:appwrite/appwrite.dart';
import 'package:dio/dio.dart';

class AppwriteService {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = '68468efc002bf2afb8f4';
  static const String databaseId = '6847c16600129747707c';
  static const String quotesCollectionId = '6847c17c003a8fabec6f';

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
      print('Attempting login for email: $email');
      final response = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      print('Login successful');
      return {'success': true, 'message': 'Login successful', 'user': response};
    } catch (e) {
      print('Login error: $e');
      print('Error type: ${e.runtimeType}');
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
      print('Attempting registration for email: $email');

      // Create user account
      final response = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: '$firstName $lastName',
      );
      print('User account created successfully');

      // Create email session after registration
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      print('Session created successfully');

      // Update user preferences with additional info
      await account.updatePrefs(
        prefs: {
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        },
      );
      print('User preferences updated successfully');

      return {
        'success': true,
        'message': 'Registration successful',
        'user': response,
      };
    } catch (e) {
      print('Registration error: $e');
      print('Error type: ${e.runtimeType}');
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
      return {'success': true, 'message': 'Logout successful'};
    } catch (e) {
      print('Logout error: $e');
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final user = await account.get();
      return {'success': true, 'user': user};
    } catch (e) {
      print('Get current user error: $e');
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      await account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Quote Management Methods
  Future<Map<String, dynamic>> createQuote({
    required String bengaliText,
    String? arabicText,
    String? englishText,
    required String reference,
    required List<String> moodIds,
  }) async {
    try {
      final user = await account.get();
      final response = await databases.createDocument(
        databaseId: databaseId,
        collectionId: quotesCollectionId,
        documentId: ID.unique(),
        data: {
          'bengaliText': bengaliText,
          'arabicText': arabicText,
          'englishText': englishText,
          'reference': reference,
          'moodIds': moodIds,
          'status': 'pending', // Set default status
          'userEmail': user.email,
          // Removed 'createdAt' since Appwrite handles this automatically with $createdAt
        },
        permissions: [
          Permission.read(Role.user(user.$id)),
          Permission.update(Role.user(user.$id)),
          Permission.delete(Role.user(user.$id)),
          Permission.read(Role.label('admin')),
          Permission.update(Role.label('admin')),
          Permission.delete(Role.label('admin')),
        ],
      );
      return {
        'success': true,
        'quote': response,
        'message': 'Quote added successfully',
      };
    } catch (e) {
      print('Create quote error: $e');
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  Future<Map<String, dynamic>> getUserQuotes() async {
    try {
      final user = await account.get();
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: quotesCollectionId,
        queries: [
          // Remove userId query since we're using permissions instead
          Query.orderDesc('\$createdAt'),
        ],
      );
      return {'success': true, 'quotes': response.documents};
    } catch (e) {
      print('Get user quotes error: $e');
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  Future<Map<String, dynamic>> updateQuote({
    required String quoteId,
    required String bengaliText,
    String? arabicText,
    String? englishText,
    required String reference,
    required List<String> moodIds,
  }) async {
    try {
      final response = await databases.updateDocument(
        databaseId: databaseId,
        collectionId: quotesCollectionId,
        documentId: quoteId,
        data: {
          'bengaliText': bengaliText,
          'arabicText': arabicText,
          'englishText': englishText,
          'reference': reference,
          'moodIds': moodIds,
        },
      );
      return {
        'success': true,
        'quote': response,
        'message': 'Quote updated successfully',
      };
    } catch (e) {
      print('Update quote error: $e');
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  Future<Map<String, dynamic>> deleteQuote(String quoteId) async {
    try {
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: quotesCollectionId,
        documentId: quoteId,
      );
      return {'success': true, 'message': 'Quote deleted successfully'};
    } catch (e) {
      print('Delete quote error: $e');
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      await account.updateName(name: name);

      if (firstName != null || lastName != null || phoneNumber != null) {
        final currentPrefs = await account.getPrefs();
        final newPrefs = Map<String, dynamic>.from(currentPrefs.data);

        if (firstName != null) newPrefs['firstName'] = firstName;
        if (lastName != null) newPrefs['lastName'] = lastName;
        if (phoneNumber != null) newPrefs['phoneNumber'] = phoneNumber;

        await account.updatePrefs(prefs: newPrefs);
      }

      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      print('Update profile error: $e');
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  // Get quotes by mood
  Future<Map<String, dynamic>> getQuotesByMood(String moodId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: quotesCollectionId,
        queries: [
          Query.search('moodIds', moodId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return {'success': true, 'quotes': response.documents};
    } catch (e) {
      print('Get quotes by mood error: $e');
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  // Admin Methods
  Future<Map<String, dynamic>> getAllQuotes() async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: quotesCollectionId,
        queries: [
          Query.orderDesc('\$createdAt'),
          Query.limit(100), // Limit for performance
        ],
      );
      return {'success': true, 'quotes': response.documents};
    } catch (e) {
      print('Get all quotes error: $e');
      return {'success': false, 'message': _getErrorMessage(e.toString())};
    }
  }

  Future<Map<String, dynamic>> updateQuoteStatus(
    String quoteId,
    String status,
  ) async {
    try {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: quotesCollectionId,
        documentId: quoteId,
        data: {
          'status': status,
          // Removed 'updatedAt' since it's not in the collection schema
        },
      );

      return {'success': true, 'message': 'Quote status updated successfully'};
    } catch (e) {
      print('Update quote status error: $e');
      String errorMessage = 'Failed to update quote status';

      if (e.toString().contains('Unknown attribute: "status"')) {
        errorMessage =
            'Database structure error: Please add the "status" attribute to your quotes collection in Appwrite console.\n\n'
            'Steps:\n'
            '1. Go to your Appwrite console\n'
            '2. Navigate to your quotes collection\n'
            '3. Add a new string attribute named "status"\n'
            '4. Set default value to "pending"\n'
            '5. Set size to 20 characters';
      } else if (e.toString().contains('Unknown attribute: "updatedAt"')) {
        errorMessage = 'Database structure error: The updatedAt field is not configured in your collection.';
      }

      return {'success': false, 'message': errorMessage};
    }
  }

  String _getErrorMessage(String error) {
    print('Processing error message: $error');

    // More specific error handling with explicit error codes
    if (error.contains('401') ||
        error.contains('Invalid credentials') ||
        error.contains('invalid-credentials')) {
      return 'Invalid email or password';
    } else if (error.contains('409') ||
        error.contains('user_already_exists') ||
        error.contains('user-already-exists')) {
      return 'User with this email already exists';
    } else if (error.contains('400') &&
        error.contains('document_invalid_structure')) {
      return 'Database structure error. Please contact support.';
    } else if (error.contains('invalid-password') ||
        (error.contains('password') && error.contains('length'))) {
      return 'Password must be at least 8 characters';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address';
    } else if (error.contains('network') ||
        error.contains('NetworkException') ||
        error.contains('connection')) {
      return 'Network error. Please check your connection';
    } else if (error.contains('403') ||
        error.contains('user-unauthorized') ||
        error.contains('unauthorized')) {
      return 'Authentication service not properly configured';
    } else if (error.contains('429') || error.contains('rate-limit')) {
      return 'Too many attempts. Please try again later';
    } else if (error.contains('404') || error.contains('not-found')) {
      return 'Resource not found. Please check your request.';
    } else if (error.contains('permission-denied') ||
        error.contains('insufficient-permissions')) {
      return 'You do not have permission to perform this action.';
    }

    // Return the actual error for debugging
    return 'Error: $error';
  }
}
