import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../models/mood.dart';
import '../services/appwrite_service.dart';
import 'quotes.dart';
import 'profile/profile.dart';
import 'auth/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  Future<void> _handleContributeClick(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appwrite = AppwriteService();
      final isLoggedIn = await appwrite.isLoggedIn();

      if (context.mounted) {
        if (isLoggedIn) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Profile()),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar style for this screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('How are you feeling?'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SizedBox.expand(
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
                  child: Column(
                    children: [
                      // Header Section - Fixed at top
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Container(
                          decoration: AppTheme.glassMorphicDecoration,
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            children: [
                              Text(
                                'Select Your Mood',
                                style: TextStyle(
                                  color: AppTheme.whiteText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'اختر مزاجك',
                                style: TextStyle(
                                  color: AppTheme.goldAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Find comfort in Islamic wisdom based on how you feel',
                                style: TextStyle(
                                  color: AppTheme.whiteText.withOpacity(0.8),
                                  fontSize: 12.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Mood Grid - Scrollable content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: GridView.builder(
                            padding: EdgeInsets.only(bottom: 20.h),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.0,
                                  crossAxisSpacing: 10.w,
                                  mainAxisSpacing: 10.h,
                                ),
                            itemCount: Mood.allMoods.length + 1,
                            itemBuilder: (context, index) {
                              if (index < Mood.allMoods.length) {
                                final mood = Mood.allMoods[index];
                                return _buildMoodCard(context, mood);
                              } else {
                                return _buildContributionCard(context);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: AppTheme.glassMorphicDecoration,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.goldAccent,
                        ),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: AppTheme.whiteText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContributionCard(BuildContext context) {
    return Container(
      decoration: AppTheme.glassMorphicDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: _isLoading ? null : () => _handleContributeClick(context),
          child: AnimatedOpacity(
            opacity: _isLoading ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_note,
                    size: 24.sp,
                    color: AppTheme.goldAccent,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Want to help us grow?',
                    style: TextStyle(
                      color: AppTheme.whiteText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'هل تريد مساعدتنا؟',
                    style: TextStyle(
                      color: AppTheme.goldAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Contribute quotes',
                    style: TextStyle(
                      color: AppTheme.whiteText.withOpacity(0.8),
                      fontSize: 9.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10.sp,
                    color: AppTheme.primaryGreen,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context, Mood mood) {
    return Container(
      decoration: BoxDecoration(
        color: mood.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: mood.accentColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: mood.primaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuotesScreen(selectedMood: mood),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mood Icon
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [mood.primaryColor, mood.lightColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mood.primaryColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Icon(mood.icon, size: 24.sp, color: Colors.white),
                ),
                SizedBox(height: 8.h),

                // Mood Name
                Text(
                  mood.name,
                  style: TextStyle(
                    color: AppTheme.whiteText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),

                // Arabic Name
                Text(
                  mood.arabicName,
                  style: TextStyle(
                    color: mood.accentColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 11.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.h),

                // Description
                Text(
                  mood.description,
                  style: TextStyle(
                    color: AppTheme.whiteText.withOpacity(0.7),
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
