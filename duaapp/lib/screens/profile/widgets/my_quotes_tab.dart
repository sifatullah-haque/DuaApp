import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/theme.dart';
import '../../../models/user_quote.dart';
import '../../../models/mood.dart';
import '../../../services/appwrite_service.dart';
import 'update_quotes.dart';

class MyQuotesTab extends StatelessWidget {
  final List<UserQuote> userQuotes;
  final VoidCallback onQuoteUpdated;

  const MyQuotesTab({
    super.key,
    required this.userQuotes,
    required this.onQuoteUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (userQuotes.isEmpty) {
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
      itemCount: userQuotes.length,
      itemBuilder: (context, index) {
        final quote = userQuotes[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: AppTheme.glassMorphicDecoration,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => _showQuoteUpdateDialog(context, quote),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quote.createdAt.toLocal().toString().split(' ')[0],
                            style: TextStyle(
                              color: AppTheme.whiteText.withOpacity(0.6),
                              fontSize: 11.sp,
                            ),
                          ),
                          Text(
                            'Status: ${quote.status.toUpperCase()}',
                            style: TextStyle(
                              color: _getStatusColor(quote.status),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, size: 18.sp),
                            color: AppTheme.goldAccent,
                            onPressed: () => _showQuoteUpdateDialog(context, quote),
                            tooltip: 'Edit quote',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQuoteUpdateDialog(BuildContext context, UserQuote quote) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateQuotesDialog(
        quote: quote,
        isAdminView: false,
        onQuoteUpdated: onQuoteUpdated,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
