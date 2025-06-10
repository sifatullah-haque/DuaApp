import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appwrite/models.dart';
import '../../constants/theme.dart';
import '../../services/appwrite_service.dart';
import '../../models/user_quote.dart';
import '../../models/mood.dart';
import '../auth/login.dart';
import 'widgets/my_quotes_tab.dart';
import 'widgets/add_quote_tab.dart';
import 'widgets/profile_tab.dart';
import 'widgets/admin_tab.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  Map<String, dynamic>? _userData;
  List<UserQuote> _userQuotes = [];
  List<UserQuote> _allQuotes = []; // For admin
  bool _isLoading = true;
  bool _isAdmin = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final appwrite = AppwriteService();
    final userResult = await appwrite.getCurrentUser();
    final quotesResult = await appwrite.getUserQuotes();

    if (mounted) {
      setState(() {
        if (userResult['success']) {
          final user = userResult['user'];
          if (user is Map<String, dynamic>) {
            _userData = user;
          } else if (user is User) {
            _userData = {
              'name': user.name,
              'email': user.email,
              '\$id': user.$id,
              '\$createdAt': user.$createdAt,
              'prefs': user.prefs.data,
              'labels': user.labels,
            };
          }

          // Check if user is admin
          _isAdmin = _userData?['labels']?.contains('admin') ?? false;

          // Update tab controller based on admin status
          _tabController.dispose();
          _tabController = TabController(length: _isAdmin ? 4 : 3, vsync: this);
        }

        if (quotesResult['success']) {
          _userQuotes = (quotesResult['quotes'] as List).map((quote) {
            if (quote is Document) {
              return UserQuote.fromMap(quote.data);
            } else if (quote is Map<String, dynamic>) {
              return UserQuote.fromMap(quote);
            } else {
              throw Exception('Invalid quote format');
            }
          }).toList();
        }

        _isLoading = false;
      });

      // Load all quotes if admin
      if (_isAdmin) {
        _loadAllQuotes();
      }
    }
  }

  Future<void> _loadAllQuotes() async {
    final appwrite = AppwriteService();
    final result = await appwrite.getAllQuotes();

    if (mounted && result['success']) {
      setState(() {
        _allQuotes = (result['quotes'] as List).map((quote) {
          if (quote is Document) {
            return UserQuote.fromMap(quote.data);
          } else if (quote is Map<String, dynamic>) {
            return UserQuote.fromMap(quote);
          } else {
            throw Exception('Invalid quote format');
          }
        }).toList();
      });
    }
  }

  Future<void> _handleLogout() async {
    final appwrite = AppwriteService();
    final result = await appwrite.logout();

    if (mounted) {
      if (result['success']) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.withOpacity(0.8)
            : AppTheme.goldAccent.withOpacity(0.8),
      ),
    );
  }

  void _onQuoteAdded() {
    _loadUserData();
    _tabController.animateTo(0); // Navigate to My Quotes tab
    _showSnackBar('Quote added successfully!');
  }

  void _onQuoteUpdated() {
    _loadUserData();
    _showSnackBar('Quote updated successfully!');
  }

  void _onQuotesUpdated() {
    _loadAllQuotes();
  }

  void _onProfileUpdated() {
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isAdmin ? 'Admin Panel' : 'Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.goldAccent,
          labelColor: AppTheme.goldAccent,
          unselectedLabelColor: AppTheme.whiteText.withOpacity(0.7),
          isScrollable: _isAdmin,
          tabAlignment: _isAdmin ? TabAlignment.center : null,
          tabs: [
            Tab(icon: Icon(Icons.format_quote), text: 'My Quotes'),
            Tab(icon: Icon(Icons.add), text: 'Add Quote'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            if (_isAdmin)
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin'),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.glassMorphBlack.withOpacity(0.6),
                AppTheme.glassMorphBlack.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.goldAccent,
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      MyQuotesTab(
                        userQuotes: _userQuotes,
                        onQuoteUpdated: _onQuoteUpdated,
                      ),
                      AddQuoteTab(onQuoteAdded: _onQuoteAdded),
                      ProfileTab(
                        userData: _userData,
                        userQuotes: _userQuotes,
                        onProfileUpdated: _onProfileUpdated,
                      ),
                      if (_isAdmin)
                        AdminTab(
                          allQuotes: _allQuotes,
                          onQuotesUpdated: _onQuotesUpdated,
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
