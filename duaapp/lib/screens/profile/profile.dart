import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appwrite/models.dart';
import '../../constants/theme.dart';
import '../../services/appwrite_service.dart';
import '../../models/user_quote.dart';
import '../../models/mood.dart';
import '../auth/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _userData;
  List<UserQuote> _userQuotes = [];
  bool _isLoading = true;
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
            };
          }
        }

        if (quotesResult['success']) {
          _userQuotes = (quotesResult['quotes'] as List)
              .map((quote) => UserQuote.fromMap(quote))
              .toList();
        }

        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.format_quote), text: 'My Quotes'),
            Tab(icon: Icon(Icons.add), text: 'Add Quote'),
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
                      _buildProfileTab(),
                      _buildQuotesTab(),
                      _buildAddQuoteTab(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          // Profile Header
          Container(
            decoration: AppTheme.glassMorphicDecoration,
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: AppTheme.goldAccent.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: 40.sp,
                    color: AppTheme.goldAccent,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  _userData?['name'] ?? 'User',
                  style: TextStyle(
                    color: AppTheme.whiteText,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _userData?['email'] ?? '',
                  style: TextStyle(color: AppTheme.goldAccent, fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: () => _showEditProfileDialog(),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldAccent,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Statistics
          Container(
            decoration: AppTheme.glassMorphicDecoration,
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics',
                  style: TextStyle(
                    color: AppTheme.whiteText,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Total Quotes',
                      _userQuotes.length.toString(),
                    ),
                    _buildStatCard(
                      'Account Created',
                      _userData?['\$createdAt'] != null
                          ? DateTime.parse(
                              _userData!['\$createdAt'],
                            ).toLocal().toString().split(' ')[0]
                          : 'N/A',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.goldAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppTheme.goldAccent,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.whiteText.withOpacity(0.7),
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuotesTab() {
    if (_userQuotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_quote,
              size: 64.sp,
              color: AppTheme.whiteText.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'No quotes added yet',
              style: TextStyle(
                color: AppTheme.whiteText.withOpacity(0.7),
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap "Add Quote" to share your first quote',
              style: TextStyle(
                color: AppTheme.whiteText.withOpacity(0.5),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _userQuotes.length,
      itemBuilder: (context, index) {
        final quote = _userQuotes[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: AppTheme.glassMorphicDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (quote.arabicText != null &&
                        quote.arabicText!.isNotEmpty) ...[
                      Text(
                        'Arabic',
                        style: TextStyle(
                          color: AppTheme.goldAccent,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        quote.arabicText!,
                        style: TextStyle(
                          color: AppTheme.whiteText,
                          fontSize: 16.sp,
                          height: 1.5,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      SizedBox(height: 12.h),
                    ],
                    Text(
                      'Bengali',
                      style: TextStyle(
                        color: AppTheme.goldAccent,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      quote.bengaliText,
                      style: TextStyle(
                        color: AppTheme.whiteText,
                        fontSize: 14.sp,
                        height: 1.5,
                      ),
                    ),
                    if (quote.englishText != null &&
                        quote.englishText!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Text(
                        'English',
                        style: TextStyle(
                          color: AppTheme.goldAccent,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        quote.englishText!,
                        style: TextStyle(
                          color: AppTheme.whiteText,
                          fontSize: 14.sp,
                          height: 1.5,
                        ),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    Text(
                      '- ${quote.reference}',
                      style: TextStyle(
                        color: AppTheme.whiteText.withOpacity(0.7),
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      quote.createdAt.toLocal().toString().split(' ')[0],
                      style: TextStyle(
                        color: AppTheme.whiteText.withOpacity(0.6),
                        fontSize: 11.sp,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 18.sp),
                          color: AppTheme.goldAccent,
                          onPressed: () => _showEditQuoteDialog(quote),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 18.sp),
                          color: Colors.red,
                          onPressed: () => _deleteQuote(quote.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddQuoteTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Container(
        decoration: AppTheme.glassMorphicDecoration,
        padding: EdgeInsets.all(24.w),
        child: AddQuoteForm(
          onQuoteAdded: () {
            _loadUserData();
            _tabController.animateTo(1);
            _showSnackBar('Quote added successfully!');
          },
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(
      text: _userData?['name'] ?? '',
    );
    final firstNameController = TextEditingController(
      text: _userData?['prefs']?['firstName'] ?? '',
    );
    final lastNameController = TextEditingController(
      text: _userData?['prefs']?['lastName'] ?? '',
    );
    final phoneController = TextEditingController(
      text: _userData?['prefs']?['phoneNumber'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.glassMorphBlack,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: AppTheme.whiteText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: AppTheme.whiteText),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: AppTheme.goldAccent),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.goldAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.goldAccent.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: firstNameController,
              style: TextStyle(color: AppTheme.whiteText),
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: TextStyle(color: AppTheme.goldAccent),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.goldAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.goldAccent.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: lastNameController,
              style: TextStyle(color: AppTheme.whiteText),
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: TextStyle(color: AppTheme.goldAccent),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.goldAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.goldAccent.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: phoneController,
              style: TextStyle(color: AppTheme.whiteText),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: AppTheme.goldAccent),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.goldAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.goldAccent.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.whiteText)),
          ),
          ElevatedButton(
            onPressed: () async {
              final appwrite = AppwriteService();
              final result = await appwrite.updateProfile(
                name: nameController.text,
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                phoneNumber: phoneController.text,
              );

              if (mounted) {
                Navigator.pop(context);
                if (result['success']) {
                  _loadUserData();
                  _showSnackBar('Profile updated successfully!');
                } else {
                  _showSnackBar(result['message'], isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditQuoteDialog(UserQuote quote) {
    final arabicController = TextEditingController(
      text: quote.arabicText ?? '',
    );
    final bengaliController = TextEditingController(text: quote.bengaliText);
    final englishController = TextEditingController(
      text: quote.englishText ?? '',
    );
    final referenceController = TextEditingController(text: quote.reference);

    List<String> selectedMoodIds = List<String>.from(quote.moodIds);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: AppTheme.glassMorphBlack,
          title: Text(
            'Edit Quote',
            style: TextStyle(color: AppTheme.whiteText),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: arabicController,
                  style: TextStyle(color: AppTheme.whiteText),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Arabic Text (Optional)',
                    labelStyle: TextStyle(color: AppTheme.goldAccent),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.goldAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.goldAccent.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: bengaliController,
                  style: TextStyle(color: AppTheme.whiteText),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Bengali Text (Required)',
                    labelStyle: TextStyle(color: AppTheme.goldAccent),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.goldAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.goldAccent.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: englishController,
                  style: TextStyle(color: AppTheme.whiteText),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'English Text (Optional)',
                    labelStyle: TextStyle(color: AppTheme.goldAccent),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.goldAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.goldAccent.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: referenceController,
                  style: TextStyle(color: AppTheme.whiteText),
                  decoration: InputDecoration(
                    labelText: 'Reference (Required)',
                    labelStyle: TextStyle(color: AppTheme.goldAccent),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.goldAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.goldAccent.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  'Select Moods:',
                  style: TextStyle(color: AppTheme.goldAccent, fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppTheme.goldAccent.withOpacity(0.3),
                    ),
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: Mood.allMoods.map((mood) {
                      final isSelected = selectedMoodIds.contains(mood.id);
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              selectedMoodIds.remove(mood.id);
                            } else {
                              selectedMoodIds.add(mood.id);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? mood.primaryColor.withOpacity(0.7)
                                : AppTheme.glassMorphBlack.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected
                                  ? mood.accentColor
                                  : AppTheme.goldAccent.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                mood.icon,
                                size: 14.sp,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.whiteText.withOpacity(0.7),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                mood.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.whiteText.withOpacity(0.7),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.whiteText),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (bengaliController.text.trim().isEmpty ||
                    referenceController.text.trim().isEmpty) {
                  _showSnackBar(
                    'Bengali text and reference are required',
                    isError: true,
                  );
                  return;
                }

                final appwrite = AppwriteService();
                final result = await appwrite.updateQuote(
                  quoteId: quote.id,
                  bengaliText: bengaliController.text.trim(),
                  arabicText: arabicController.text.trim().isEmpty
                      ? null
                      : arabicController.text.trim(),
                  englishText: englishController.text.trim().isEmpty
                      ? null
                      : englishController.text.trim(),
                  reference: referenceController.text.trim(),
                  moodIds: selectedMoodIds.isEmpty
                      ? ['general']
                      : selectedMoodIds,
                );

                if (mounted) {
                  Navigator.pop(context);
                  if (result['success']) {
                    _loadUserData();
                    _showSnackBar('Quote updated successfully!');
                  } else {
                    _showSnackBar(result['message'], isError: true);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteQuote(String quoteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.glassMorphBlack,
        title: Text(
          'Delete Quote',
          style: TextStyle(color: AppTheme.whiteText),
        ),
        content: Text(
          'Are you sure you want to delete this quote?',
          style: TextStyle(color: AppTheme.whiteText.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.whiteText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final appwrite = AppwriteService();
      final result = await appwrite.deleteQuote(quoteId);

      if (mounted) {
        if (result['success']) {
          _loadUserData();
          _showSnackBar('Quote deleted successfully!');
        } else {
          _showSnackBar(result['message'], isError: true);
        }
      }
    }
  }
}

class AddQuoteForm extends StatefulWidget {
  final VoidCallback onQuoteAdded;

  const AddQuoteForm({super.key, required this.onQuoteAdded});

  @override
  State<AddQuoteForm> createState() => _AddQuoteFormState();
}

class _AddQuoteFormState extends State<AddQuoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _arabicController = TextEditingController();
  final _bengaliController = TextEditingController();
  final _englishController = TextEditingController();
  final _referenceController = TextEditingController();
  bool _isSubmitting = false;
  List<String> _selectedMoodIds = [];

  @override
  void dispose() {
    _arabicController.dispose();
    _bengaliController.dispose();
    _englishController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final appwrite = AppwriteService();
    final result = await appwrite.createQuote(
      bengaliText: _bengaliController.text.trim(),
      arabicText: _arabicController.text.trim().isEmpty
          ? null
          : _arabicController.text.trim(),
      englishText: _englishController.text.trim().isEmpty
          ? null
          : _englishController.text.trim(),
      reference: _referenceController.text.trim(),
      moodIds: _selectedMoodIds.isEmpty ? ['general'] : _selectedMoodIds,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (result['success']) {
        _clearForm();
        widget.onQuoteAdded();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      }
    }
  }

  void _clearForm() {
    _arabicController.clear();
    _bengaliController.clear();
    _englishController.clear();
    _referenceController.clear();
    _formKey.currentState?.reset();
    setState(() {
      _selectedMoodIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Quote',
            style: TextStyle(
              color: AppTheme.whiteText,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),

          // Arabic Text Field
          TextFormField(
            controller: _arabicController,
            style: TextStyle(color: AppTheme.whiteText),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Arabic Text (Optional)',
              labelStyle: TextStyle(color: AppTheme.goldAccent),
              hintText: 'Enter Arabic text here...',
              hintStyle: TextStyle(color: AppTheme.whiteText.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppTheme.goldAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.goldAccent.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppTheme.goldAccent),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Bengali Text Field
          TextFormField(
            controller: _bengaliController,
            style: TextStyle(color: AppTheme.whiteText),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Bengali text is required';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Bengali Text (Required) *',
              labelStyle: TextStyle(color: AppTheme.goldAccent),
              hintText: 'বাংলা টেক্সট এখানে লিখুন...',
              hintStyle: TextStyle(color: AppTheme.whiteText.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppTheme.goldAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.goldAccent.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppTheme.goldAccent),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // English Text Field
          TextFormField(
            controller: _englishController,
            style: TextStyle(color: AppTheme.whiteText),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'English Text (Optional)',
              labelStyle: TextStyle(color: AppTheme.goldAccent),
              hintText: 'Enter English text here...',
              hintStyle: TextStyle(color: AppTheme.whiteText.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppTheme.goldAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.goldAccent.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppTheme.goldAccent),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Reference Text Field
          TextFormField(
            controller: _referenceController,
            style: TextStyle(color: AppTheme.whiteText),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Reference is required';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Reference (Required) *',
              labelStyle: TextStyle(color: AppTheme.goldAccent),
              hintText: 'e.g., Quran 2:255, Sahih Bukhari 123',
              hintStyle: TextStyle(color: AppTheme.whiteText.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppTheme.goldAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.goldAccent.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppTheme.goldAccent),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Mood Selection
          Text(
            'Select Moods (Optional)',
            style: TextStyle(
              color: AppTheme.goldAccent,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.goldAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
            ),
            padding: EdgeInsets.all(16.w),
            child: _buildMoodSelectionGrid(),
          ),

          SizedBox(height: 24.h),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitQuote,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldAccent,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      'Add Quote',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 12.h),

          // Clear Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : _clearForm,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.5)),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Clear Form',
                style: TextStyle(color: AppTheme.whiteText, fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelectionGrid() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: Mood.allMoods.map((mood) {
        final isSelected = _selectedMoodIds.contains(mood.id);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedMoodIds.remove(mood.id);
              } else {
                _selectedMoodIds.add(mood.id);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? mood.primaryColor.withOpacity(0.7)
                  : AppTheme.glassMorphBlack.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? mood.accentColor
                    : AppTheme.goldAccent.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  mood.icon,
                  size: 16.sp,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.whiteText.withOpacity(0.7),
                ),
                SizedBox(width: 4.w),
                Text(
                  mood.name,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppTheme.whiteText.withOpacity(0.7),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
