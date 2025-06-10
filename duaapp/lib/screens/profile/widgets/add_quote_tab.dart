import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/theme.dart';
import '../../../models/mood.dart';
import '../../../services/appwrite_service.dart';

class AddQuoteTab extends StatefulWidget {
  final VoidCallback onQuoteAdded;

  const AddQuoteTab({super.key, required this.onQuoteAdded});

  @override
  State<AddQuoteTab> createState() => _AddQuoteTabState();
}

class _AddQuoteTabState extends State<AddQuoteTab> {
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

    if (_selectedMoodIds.isEmpty) {
      _showSnackBar('Please select at least one mood', isError: true);
      return;
    }

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
      moodIds: _selectedMoodIds,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (result['success']) {
        _clearForm();
        widget.onQuoteAdded();
        _showSnackBar('Quote submitted successfully for review!');
      } else {
        _showSnackBar(result['message'], isError: true);
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Container(
        decoration: AppTheme.glassMorphicDecoration,
        padding: EdgeInsets.all(24.w),
        child: Form(
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
              TextFormField(
                controller: _arabicController,
                style: TextStyle(color: AppTheme.whiteText),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Arabic Text (Optional)',
                  labelStyle: TextStyle(color: AppTheme.goldAccent),
                  hintText: 'Enter Arabic text here...',
                  hintStyle: TextStyle(
                    color: AppTheme.whiteText.withOpacity(0.5),
                  ),
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
                  hintStyle: TextStyle(
                    color: AppTheme.whiteText.withOpacity(0.5),
                  ),
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
              TextFormField(
                controller: _englishController,
                style: TextStyle(color: AppTheme.whiteText),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'English Text (Optional)',
                  labelStyle: TextStyle(color: AppTheme.goldAccent),
                  hintText: 'Enter English text here...',
                  hintStyle: TextStyle(
                    color: AppTheme.whiteText.withOpacity(0.5),
                  ),
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
                  hintStyle: TextStyle(
                    color: AppTheme.whiteText.withOpacity(0.5),
                  ),
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
              Text(
                'Select Moods (Required) *',
                style: TextStyle(
                  color: AppTheme.goldAccent,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedMoodIds.isEmpty
                        ? Colors.red.withOpacity(0.1)
                        : AppTheme.goldAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _selectedMoodIds.isEmpty
                          ? Colors.red.withOpacity(0.5)
                          : AppTheme.goldAccent.withOpacity(0.3),
                    ),
                  ),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedMoodIds.isEmpty)
                        Text(
                          'Please select at least one mood',
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.8),
                            fontSize: 12.sp,
                          ),
                        ),
                      if (_selectedMoodIds.isEmpty) SizedBox(height: 8.h),
                      _buildMoodSelectionGrid(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
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
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : _clearForm,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.goldAccent.withOpacity(0.5),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Clear Form',
                    style: TextStyle(
                      color: AppTheme.whiteText,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(fontSize: 12.sp)),
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
