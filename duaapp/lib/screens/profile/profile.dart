import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appwrite/models.dart';
import '../../constants/theme.dart';
import '../../services/appwrite_service.dart';
import '../auth/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final appwrite = AppwriteService();
    final result = await appwrite.getCurrentUser();

    if (mounted) {
      setState(() {
        if (result['success']) {
          // Handle both Map and User object cases
          final user = result['user'];
          if (user is Map<String, dynamic>) {
            _userData = user;
          } else if (user is User) {
            // Convert User object to Map
            _userData = {
              'name': user.name,
              'email': user.email,
              '\$id': user.$id,
              '\$createdAt': user.$createdAt,
              'prefs': user.prefs.data,
            };
          }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
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
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  children: [
                                    SizedBox(height: 20.h),

                                    // Profile Header
                                    Container(
                                      decoration:
                                          AppTheme.glassMorphicDecoration,
                                      padding: EdgeInsets.all(24.w),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 40.r,
                                            backgroundColor: AppTheme.goldAccent
                                                .withOpacity(0.2),
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
                                            style: TextStyle(
                                              color: AppTheme.goldAccent,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 24.h),

                                    // User Details
                                    Container(
                                      decoration:
                                          AppTheme.glassMorphicDecoration,
                                      padding: EdgeInsets.all(24.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Account Information',
                                            style: TextStyle(
                                              color: AppTheme.whiteText,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 16.h),
                                          _buildInfoRow(
                                            'Email',
                                            _userData?['email'] ?? 'N/A',
                                          ),
                                          _buildInfoRow(
                                            'User ID',
                                            _userData?['\$id'] ?? 'N/A',
                                          ),
                                          _buildInfoRow(
                                            'Account Created',
                                            _userData?['\$createdAt'] != null
                                                ? DateTime.parse(
                                                    _userData!['\$createdAt'],
                                                  ).toLocal().toString().split(
                                                    ' ',
                                                  )[0]
                                                : 'N/A',
                                          ),
                                          if (_userData?['prefs'] != null) ...[
                                            _buildInfoRow(
                                              'First Name',
                                              _userData!['prefs']['firstName'] ??
                                                  'N/A',
                                            ),
                                            _buildInfoRow(
                                              'Last Name',
                                              _userData!['prefs']['lastName'] ??
                                                  'N/A',
                                            ),
                                            _buildInfoRow(
                                              'Phone',
                                              _userData!['prefs']['phoneNumber'] ??
                                                  'N/A',
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 24.h),

                                    // Logout Button
                                    Container(
                                      width: double.infinity,
                                      decoration:
                                          AppTheme.glassMorphicDecoration,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          onTap: _handleLogout,
                                          child: Padding(
                                            padding: EdgeInsets.all(20.w),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.logout,
                                                  color: Colors.red,
                                                  size: 20.sp,
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  'Logout',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppTheme.whiteText.withOpacity(0.7),
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.whiteText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
