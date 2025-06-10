import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/theme.dart';
import '../../../models/user_quote.dart';
import '../../../services/appwrite_service.dart';

class ProfileTab extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final List<UserQuote> userQuotes;
  final VoidCallback onProfileUpdated;

  const ProfileTab({
    super.key,
    required this.userData,
    required this.userQuotes,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
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
                  'Edit Profile',
                  style: TextStyle(
                    color: AppTheme.whiteText,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildEditableProfileForm(context),
              ],
            ),
          ),
          SizedBox(height: 24.h),
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
                      userQuotes.length.toString(),
                    ),
                    _buildStatCard(
                      'Account Created',
                      userData?['\$createdAt'] != null
                          ? DateTime.parse(
                              userData!['\$createdAt'],
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

  Widget _buildEditableProfileForm(BuildContext context) {
    final nameController = TextEditingController(text: userData?['name'] ?? '');
    final firstNameController = TextEditingController(
      text: userData?['prefs']?['firstName'] ?? '',
    );
    final lastNameController = TextEditingController(
      text: userData?['prefs']?['lastName'] ?? '',
    );
    final phoneController = TextEditingController(
      text: userData?['prefs']?['phoneNumber'] ?? '',
    );

    return Column(
      children: [
        TextField(
          controller: nameController,
          style: TextStyle(color: AppTheme.whiteText),
          decoration: InputDecoration(
            labelText: 'Full Name',
            labelStyle: TextStyle(color: AppTheme.goldAccent),
            prefixIcon: Icon(Icons.person, color: AppTheme.goldAccent),
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
        TextField(
          controller: firstNameController,
          style: TextStyle(color: AppTheme.whiteText),
          decoration: InputDecoration(
            labelText: 'First Name',
            labelStyle: TextStyle(color: AppTheme.goldAccent),
            prefixIcon: Icon(Icons.person_outline, color: AppTheme.goldAccent),
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
        TextField(
          controller: lastNameController,
          style: TextStyle(color: AppTheme.whiteText),
          decoration: InputDecoration(
            labelText: 'Last Name',
            labelStyle: TextStyle(color: AppTheme.goldAccent),
            prefixIcon: Icon(Icons.person_outline, color: AppTheme.goldAccent),
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
        TextField(
          controller: phoneController,
          style: TextStyle(color: AppTheme.whiteText),
          decoration: InputDecoration(
            labelText: 'Phone Number',
            labelStyle: TextStyle(color: AppTheme.goldAccent),
            prefixIcon: Icon(Icons.phone, color: AppTheme.goldAccent),
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
          userData?['email'] ?? '',
          style: TextStyle(
            color: AppTheme.goldAccent,
            fontSize: 14.sp,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final appwrite = AppwriteService();
              final result = await appwrite.updateProfile(
                name: nameController.text,
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                phoneNumber: phoneController.text,
              );

              if (context.mounted) {
                if (result['success']) {
                  onProfileUpdated();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: AppTheme.goldAccent.withOpacity(0.8),
                    ),
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Update Profile',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
}
