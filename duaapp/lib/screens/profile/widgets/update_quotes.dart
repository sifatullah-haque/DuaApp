import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/theme.dart';
import '../../../models/user_quote.dart';
import '../../../models/mood.dart';
import '../../../services/appwrite_service.dart';

class UpdateQuotesDialog extends StatefulWidget {
  final UserQuote quote;
  final VoidCallback onQuoteUpdated;
  final bool isAdminView;

  const UpdateQuotesDialog({
    super.key,
    required this.quote,
    required this.onQuoteUpdated,
    this.isAdminView = false,
  });

  @override
  State<UpdateQuotesDialog> createState() => _UpdateQuotesDialogState();
}

class _UpdateQuotesDialogState extends State<UpdateQuotesDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _arabicController;
  late TextEditingController _bengaliController;
  late TextEditingController _englishController;
  late TextEditingController _referenceController;
  
  List<String> _selectedMoodIds = [];
  bool _isLoading = false;
  String _currentStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _arabicController = TextEditingController(text: widget.quote.arabicText ?? '');
    _bengaliController = TextEditingController(text: widget.quote.bengaliText);
    _englishController = TextEditingController(text: widget.quote.englishText ?? '');
    _referenceController = TextEditingController(text: widget.quote.reference);
    _selectedMoodIds = List<String>.from(widget.quote.moodIds);
    _currentStatus = widget.quote.status;
  }

  @override
  void dispose() {
    _arabicController.dispose();
    _bengaliController.dispose();
    _englishController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(12.w),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        decoration: BoxDecoration(
          color: AppTheme.glassMorphBlack.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppTheme.goldAccent.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextSection(),
                      SizedBox(height: 20.h),
                      _buildMoodSelection(),
                      if (widget.isAdminView) ...[
                        SizedBox(height: 20.h),
                        _buildStatusSection(),
                      ],
                      SizedBox(height: 20.h),
                      _buildQuotePreview(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.goldAccent.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.goldAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.goldAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.edit_note,
              color: AppTheme.goldAccent,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isAdminView ? 'Admin: Update Quote' : 'Update Quote',
                  style: TextStyle(
                    color: AppTheme.whiteText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Edit your Islamic quote',
                  style: TextStyle(
                    color: AppTheme.whiteText.withOpacity(0.7),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: AppTheme.whiteText,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quote Content', Icons.format_quote),
        SizedBox(height: 12.h),
        _buildTextFormField(
          controller: _arabicController,
          label: 'Arabic Text (العربية)',
          hint: 'Enter Arabic text (optional)',
          maxLines: 3,
          isRequired: false,
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: _bengaliController,
          label: 'Bengali Text (বাংলা) *',
          hint: 'Enter Bengali text (required)',
          maxLines: 4,
          isRequired: true,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: _englishController,
          label: 'English Text',
          hint: 'Enter English text (optional)',
          maxLines: 3,
          isRequired: false,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: _referenceController,
          label: 'Reference *',
          hint: 'e.g., Quran 2:286, Hadith Bukhari...',
          maxLines: 1,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.goldAccent, size: 16.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            color: AppTheme.goldAccent,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
    required bool isRequired,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return Container(
      decoration: AppTheme.glassMorphicDecoration,
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: AppTheme.whiteText, fontSize: 12.sp),
        textDirection: textDirection,
        maxLines: maxLines,
        validator: isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: AppTheme.goldAccent,
            fontSize: 12.sp,
          ),
          hintStyle: TextStyle(
            color: AppTheme.whiteText.withOpacity(0.5),
            fontSize: 11.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(16.w),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildMoodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select Relevant Moods', Icons.mood),
        SizedBox(height: 12.h),
        Container(
          decoration: AppTheme.glassMorphicDecoration,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose moods that match your quote:',
                style: TextStyle(
                  color: AppTheme.whiteText.withOpacity(0.8),
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? mood.primaryColor.withOpacity(0.3)
                            : AppTheme.glassMorphBlack.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? mood.accentColor
                              : AppTheme.goldAccent.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            mood.icon,
                            size: 14.sp,
                            color: isSelected
                                ? mood.accentColor
                                : AppTheme.whiteText.withOpacity(0.7),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            mood.name,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.whiteText
                                  : AppTheme.whiteText.withOpacity(0.7),
                              fontSize: 11.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quote Status', Icons.admin_panel_settings),
        SizedBox(height: 12.h),
        Container(
          decoration: AppTheme.glassMorphicDecoration,
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildStatusOption('pending', 'Pending Review', Icons.pending, Colors.orange),
              _buildStatusOption('approved', 'Approved', Icons.check_circle, Colors.green),
              _buildStatusOption('rejected', 'Rejected', Icons.cancel, Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOption(String value, String label, IconData icon, Color color) {
    return RadioListTile<String>(
      value: value,
      groupValue: _currentStatus,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _currentStatus = newValue;
          });
        }
      },
      activeColor: color,
      title: Row(
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.whiteText,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Preview', Icons.preview),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.goldAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.goldAccent.withOpacity(0.2),
            ),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_arabicController.text.trim().isNotEmpty) ...[
                Text(
                  'Arabic:',
                  style: TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _arabicController.text.trim(),
                  style: TextStyle(
                    color: AppTheme.whiteText,
                    fontSize: 12.sp,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 8.h),
              ],
              if (_bengaliController.text.trim().isNotEmpty) ...[
                Text(
                  'Bengali:',
                  style: TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _bengaliController.text.trim(),
                  style: TextStyle(
                    color: AppTheme.whiteText,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 8.h),
              ],
              if (_englishController.text.trim().isNotEmpty) ...[
                Text(
                  'English:',
                  style: TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _englishController.text.trim(),
                  style: TextStyle(
                    color: AppTheme.whiteText,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 8.h),
              ],
              if (_referenceController.text.trim().isNotEmpty) ...[
                Text(
                  'Reference:',
                  style: TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '- ${_referenceController.text.trim()}',
                  style: TextStyle(
                    color: AppTheme.whiteText.withOpacity(0.8),
                    fontSize: 11.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.goldAccent.withOpacity(0.05),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.goldAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  side: BorderSide(
                    color: AppTheme.whiteText.withOpacity(0.3),
                  ),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.whiteText,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateQuote,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldAccent,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 16.h,
                      width: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      'Update Quote',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuote() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMoodIds.isEmpty) {
      _showSnackBar('Please select at least one mood', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appwrite = AppwriteService();
      
      // Update quote content
      Map<String, dynamic> result = await appwrite.updateQuote(
        quoteId: widget.quote.id,
        bengaliText: _bengaliController.text.trim(),
        arabicText: _arabicController.text.trim().isEmpty
            ? null
            : _arabicController.text.trim(),
        englishText: _englishController.text.trim().isEmpty
            ? null
            : _englishController.text.trim(),
        reference: _referenceController.text.trim(),
        moodIds: _selectedMoodIds,
      );

      // If admin is updating status and it's different from current
      if (widget.isAdminView && _currentStatus != widget.quote.status) {
        final statusResult = await appwrite.updateQuoteStatus(
          widget.quote.id,
          _currentStatus,
        );
        if (!statusResult['success']) {
          result = statusResult;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          widget.onQuoteUpdated();
          Navigator.pop(context);
          _showSnackBar('Quote updated successfully!');
        } else {
          _showSnackBar(result['message'] ?? 'Failed to update quote', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('An error occurred: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(fontSize: 12.sp),
          ),
          backgroundColor: isError
              ? Colors.red.withOpacity(0.8)
              : AppTheme.goldAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }
  }
}
