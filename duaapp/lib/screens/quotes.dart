import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../models/mood.dart';

class QuotesScreen extends StatefulWidget {
  final Mood selectedMood;

  const QuotesScreen({super.key, required this.selectedMood});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  int currentQuoteIndex = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Set status bar to be completely transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void nextQuote() {
    setState(() {
      currentQuoteIndex =
          (currentQuoteIndex + 1) % widget.selectedMood.quotes.length;
    });
    pageController.animateToPage(
      currentQuoteIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousQuote() {
    setState(() {
      currentQuoteIndex = currentQuoteIndex == 0
          ? widget.selectedMood.quotes.length - 1
          : currentQuoteIndex - 1;
    });
    pageController.animateToPage(
      currentQuoteIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.getMoodTheme(
        widget.selectedMood.primaryColor,
        widget.selectedMood.lightColor,
        widget.selectedMood.darkColor,
        widget.selectedMood.accentColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.selectedMood.name} Quotes'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        extendBodyBehindAppBar: true,
        body: SizedBox.expand(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: Container(
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 8.h),

                    // Header Section - Made smaller and responsive
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        decoration: AppTheme.getMoodGlassMorphicDecoration(
                          widget.selectedMood.accentColor,
                        ),
                        padding: EdgeInsets.all(18.w),
                        child: Row(
                          children: [
                            // Mood Icon - Made smaller
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    widget.selectedMood.primaryColor,
                                    widget.selectedMood.lightColor,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.selectedMood.primaryColor
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: Offset(0, 3.h),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.selectedMood.icon,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12.w),

                            // Text Content - Made more compact
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Feeling ${widget.selectedMood.name}',
                                    style: TextStyle(
                                      color: AppTheme.whiteText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  Text(
                                    widget.selectedMood.arabicName,
                                    style: TextStyle(
                                      color: widget.selectedMood.accentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Main Quote Container - More space allocated
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: PageView.builder(
                          controller: pageController,
                          onPageChanged: (index) {
                            setState(() {
                              currentQuoteIndex =
                                  index % widget.selectedMood.quotes.length;
                            });
                          },
                          itemBuilder: (context, index) {
                            final quoteIndex =
                                index % widget.selectedMood.quotes.length;
                            return Container(
                              decoration:
                                  AppTheme.getMoodGlassMorphicDecoration(
                                    widget.selectedMood.accentColor,
                                  ),
                              padding: EdgeInsets.all(20.w),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Arabic Quote
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(18.w),
                                      decoration: BoxDecoration(
                                        color: widget.selectedMood.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        border: Border.all(
                                          color: widget.selectedMood.accentColor
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Arabic | العربية',
                                            style: TextStyle(
                                              color: widget
                                                  .selectedMood
                                                  .accentColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          SizedBox(height: 12.h),
                                          Text(
                                            widget
                                                .selectedMood
                                                .arabicQuotes[quoteIndex],
                                            style: TextStyle(
                                              color: AppTheme.whiteText,
                                              height: 1.8,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 18.h),

                                    // Bangla Quote
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(18.w),
                                      decoration: BoxDecoration(
                                        color: widget.selectedMood.lightColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        border: Border.all(
                                          color: widget.selectedMood.accentColor
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Bengali | বাংলা',
                                            style: TextStyle(
                                              color: widget
                                                  .selectedMood
                                                  .accentColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          SizedBox(height: 12.h),
                                          Text(
                                            widget
                                                .selectedMood
                                                .banglaQuotes[quoteIndex],
                                            style: TextStyle(
                                              color: AppTheme.whiteText,
                                              height: 1.6,
                                              fontSize: 14.sp,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 18.h),

                                    // English Quote
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(18.w),
                                      decoration: BoxDecoration(
                                        color: widget.selectedMood.darkColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        border: Border.all(
                                          color: widget.selectedMood.accentColor
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'English',
                                            style: TextStyle(
                                              color: widget
                                                  .selectedMood
                                                  .accentColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          SizedBox(height: 12.h),
                                          Text(
                                            widget
                                                .selectedMood
                                                .quotes[quoteIndex],
                                            style: TextStyle(
                                              color: AppTheme.whiteText,
                                              height: 1.6,
                                              fontSize: 14.sp,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 16.h),

                                    // Source
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '- Quran & Hadith',
                                          style: TextStyle(
                                            color: AppTheme.whiteText
                                                .withOpacity(0.7),
                                            fontStyle: FontStyle.italic,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Navigation Buttons
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Previous Button
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.selectedMood.primaryColor
                                      .withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: previousQuote,
                              icon: Icon(Icons.arrow_back_ios, size: 16.sp),
                              label: Text(
                                'Previous',
                                style: TextStyle(fontSize: 13.sp),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget
                                    .selectedMood
                                    .primaryColor
                                    .withOpacity(0.9),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ),

                          // Next Button
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.selectedMood.primaryColor
                                      .withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: nextQuote,
                              icon: Icon(Icons.arrow_forward_ios, size: 16.sp),
                              label: Text(
                                'Next',
                                style: TextStyle(fontSize: 13.sp),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget
                                    .selectedMood
                                    .primaryColor
                                    .withOpacity(0.9),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
