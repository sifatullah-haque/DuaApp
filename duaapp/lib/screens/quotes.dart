import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../models/mood.dart';
import '../services/appwrite_service.dart';
import '../models/user_quote.dart';

class QuotesScreen extends StatefulWidget {
  final Mood selectedMood;

  const QuotesScreen({super.key, required this.selectedMood});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  int currentQuoteIndex = 0;
  PageController pageController = PageController();
  List<UserQuote> userQuotes = [];
  List<Map<String, String>> allQuotes = [];
  bool isLoadingUserQuotes = false;

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
    _loadUserQuotesByMood();
    _combineQuotes();
  }

  Future<void> _loadUserQuotesByMood() async {
    setState(() {
      isLoadingUserQuotes = true;
    });

    final appwrite = AppwriteService();
    final result = await appwrite.getQuotesByMood(widget.selectedMood.id);

    if (mounted && result['success']) {
      setState(() {
        userQuotes = (result['quotes'] as List)
            .map((quote) => UserQuote.fromMap(quote.data ?? {}))
            .toList();
        isLoadingUserQuotes = false;
      });
      _combineQuotes();
    } else {
      setState(() {
        isLoadingUserQuotes = false;
      });
    }
  }

  void _combineQuotes() {
    // Combine default quotes with user quotes
    List<Map<String, String>> combined = [];

    // Add default quotes
    for (int i = 0; i < widget.selectedMood.quotes.length; i++) {
      combined.add({
        'type': 'default',
        'arabic': widget.selectedMood.arabicQuotes[i],
        'bengali': widget.selectedMood.banglaQuotes[i],
        'english': widget.selectedMood.quotes[i],
        'reference': 'Quran & Hadith',
      });
    }

    // Add approved user quotes
    for (UserQuote userQuote in userQuotes) {
      combined.add({
        'type': 'user',
        'arabic': userQuote.arabicText ?? '',
        'bengali': userQuote.bengaliText,
        'english': userQuote.englishText ?? '',
        'reference': userQuote.reference,
      });
    }

    setState(() {
      allQuotes = combined;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void nextQuote() {
    setState(() {
      currentQuoteIndex = (currentQuoteIndex + 1) % allQuotes.length;
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
          ? allQuotes.length - 1
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

                    // Header Section
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

                            // Quote counter
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: widget.selectedMood.accentColor
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '${currentQuoteIndex + 1}/${allQuotes.length}',
                                style: TextStyle(
                                  color: widget.selectedMood.accentColor,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Main Quote Container
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: isLoadingUserQuotes
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: widget.selectedMood.accentColor,
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'Loading quotes...',
                                      style: TextStyle(
                                        color: AppTheme.whiteText,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : allQuotes.isEmpty
                            ? Center(
                                child: Text(
                                  'No quotes available for this mood',
                                  style: TextStyle(
                                    color: AppTheme.whiteText.withOpacity(0.7),
                                    fontSize: 14.sp,
                                  ),
                                ),
                              )
                            : PageView.builder(
                                controller: pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentQuoteIndex =
                                        index % allQuotes.length;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final quoteIndex = index % allQuotes.length;
                                  final quote = allQuotes[quoteIndex];

                                  return Container(
                                    decoration:
                                        AppTheme.getMoodGlassMorphicDecoration(
                                          widget.selectedMood.accentColor,
                                        ),
                                    padding: EdgeInsets.all(20.w),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Quote type indicator
                                          if (quote['type'] == 'user')
                                            Container(
                                              margin: EdgeInsets.only(
                                                bottom: 12.h,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.w,
                                                vertical: 4.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: widget
                                                    .selectedMood
                                                    .accentColor
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: Text(
                                                'Community Quote',
                                                style: TextStyle(
                                                  color: widget
                                                      .selectedMood
                                                      .accentColor,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                          // Arabic Quote
                                          if (quote['arabic']!.isNotEmpty) ...[
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(18.w),
                                              decoration: BoxDecoration(
                                                color: widget
                                                    .selectedMood
                                                    .primaryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                                border: Border.all(
                                                  color: widget
                                                      .selectedMood
                                                      .accentColor
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                  SizedBox(height: 12.h),
                                                  Text(
                                                    quote['arabic']!,
                                                    style: TextStyle(
                                                      color: AppTheme.whiteText,
                                                      height: 1.8,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 18.h),
                                          ],

                                          // Bengali Quote
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(18.w),
                                            decoration: BoxDecoration(
                                              color: widget
                                                  .selectedMood
                                                  .lightColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              border: Border.all(
                                                color: widget
                                                    .selectedMood
                                                    .accentColor
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
                                                  quote['bengali']!,
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

                                          // English Quote
                                          if (quote['english']!.isNotEmpty) ...[
                                            SizedBox(height: 18.h),
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(18.w),
                                              decoration: BoxDecoration(
                                                color: widget
                                                    .selectedMood
                                                    .darkColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                                border: Border.all(
                                                  color: widget
                                                      .selectedMood
                                                      .accentColor
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                  SizedBox(height: 12.h),
                                                  Text(
                                                    quote['english']!,
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
                                          ],

                                          SizedBox(height: 16.h),

                                          // Reference
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '- ${quote['reference']}',
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
                              onPressed: allQuotes.isNotEmpty
                                  ? previousQuote
                                  : null,
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
                              onPressed: allQuotes.isNotEmpty
                                  ? nextQuote
                                  : null,
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
