import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../models/mood.dart';
import 'quotes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How are you feeling?'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: AppTheme.backgroundContainer(
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                    ),
                    itemCount: Mood.allMoods.length,
                    itemBuilder: (context, index) {
                      final mood = Mood.allMoods[index];
                      return _buildMoodCard(context, mood);
                    },
                  ),
                ),
              ),
            ],
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
