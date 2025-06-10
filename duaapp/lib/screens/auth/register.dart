import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/theme.dart';
import '../../services/appwrite_service.dart';
import '../profile/profile.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appwrite = AppwriteService();
      final result = await appwrite.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (mounted) {
        if (result['success']) {
          _showSuccessSnackBar('Registration successful! Welcome to DuaApp');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Profile()),
          );
        } else {
          _showErrorSnackBar(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryGreen.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 20.h),

                                // Welcome Container
                                Container(
                                  decoration: AppTheme.glassMorphicDecoration,
                                  padding: EdgeInsets.all(24.w),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.person_add_outlined,
                                        size: 48.sp,
                                        color: AppTheme.goldAccent,
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'Join Our Community',
                                        style: TextStyle(
                                          color: AppTheme.whiteText,
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'انضم إلى مجتمعنا',
                                        style: TextStyle(
                                          color: AppTheme.goldAccent,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Create your account to start your spiritual journey',
                                        style: TextStyle(
                                          color: AppTheme.whiteText.withOpacity(
                                            0.8,
                                          ),
                                          fontSize: 14.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 24.h),

                                // Register Form Container
                                Container(
                                  decoration: AppTheme.glassMorphicDecoration,
                                  padding: EdgeInsets.all(24.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // First Name & Last Name Row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _firstNameController,
                                              style: TextStyle(
                                                color: AppTheme.whiteText,
                                                fontSize: 14.sp,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: 'First Name',
                                                hintText: 'Enter first name',
                                                prefixIcon: Icon(
                                                  Icons.person_outline,
                                                  color: AppTheme.goldAccent,
                                                ),
                                                fillColor:
                                                    AppTheme.glassBackground,
                                                labelStyle: TextStyle(
                                                  color: AppTheme.whiteText
                                                      .withOpacity(0.8),
                                                ),
                                                hintStyle: TextStyle(
                                                  color: AppTheme.whiteText
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Required';
                                                }
                                                if (value.length < 2) {
                                                  return 'Too short';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _lastNameController,
                                              style: TextStyle(
                                                color: AppTheme.whiteText,
                                                fontSize: 14.sp,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: 'Last Name',
                                                hintText: 'Enter last name',
                                                prefixIcon: Icon(
                                                  Icons.person_outline,
                                                  color: AppTheme.goldAccent,
                                                ),
                                                fillColor:
                                                    AppTheme.glassBackground,
                                                labelStyle: TextStyle(
                                                  color: AppTheme.whiteText
                                                      .withOpacity(0.8),
                                                ),
                                                hintStyle: TextStyle(
                                                  color: AppTheme.whiteText
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Required';
                                                }
                                                if (value.length < 2) {
                                                  return 'Too short';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 20.h),

                                      // Email Field
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: TextStyle(
                                          color: AppTheme.whiteText,
                                          fontSize: 14.sp,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          hintText: 'Enter your email',
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                            color: AppTheme.goldAccent,
                                          ),
                                          fillColor: AppTheme.glassBackground,
                                          labelStyle: TextStyle(
                                            color: AppTheme.whiteText
                                                .withOpacity(0.8),
                                          ),
                                          hintStyle: TextStyle(
                                            color: AppTheme.whiteText
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(value)) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),

                                      SizedBox(height: 20.h),

                                      // Phone Number Field
                                      TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        style: TextStyle(
                                          color: AppTheme.whiteText,
                                          fontSize: 14.sp,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Phone Number',
                                          hintText: 'Enter your phone number',
                                          prefixIcon: Icon(
                                            Icons.phone_outlined,
                                            color: AppTheme.goldAccent,
                                          ),
                                          fillColor: AppTheme.glassBackground,
                                          labelStyle: TextStyle(
                                            color: AppTheme.whiteText
                                                .withOpacity(0.8),
                                          ),
                                          hintStyle: TextStyle(
                                            color: AppTheme.whiteText
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your phone number';
                                          }
                                          if (value.length < 10) {
                                            return 'Please enter a valid phone number';
                                          }
                                          return null;
                                        },
                                      ),

                                      SizedBox(height: 20.h),

                                      // Password Field
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        style: TextStyle(
                                          color: AppTheme.whiteText,
                                          fontSize: 14.sp,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          hintText: 'Enter your password',
                                          prefixIcon: Icon(
                                            Icons.lock_outline,
                                            color: AppTheme.goldAccent,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                              color: AppTheme.whiteText
                                                  .withOpacity(0.7),
                                            ),
                                            onPressed: () => setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            ),
                                          ),
                                          fillColor: AppTheme.glassBackground,
                                          labelStyle: TextStyle(
                                            color: AppTheme.whiteText
                                                .withOpacity(0.8),
                                          ),
                                          hintStyle: TextStyle(
                                            color: AppTheme.whiteText
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          if (value.length < 8) {
                                            return 'Password must be at least 8 characters';
                                          }
                                          return null;
                                        },
                                      ),

                                      SizedBox(height: 20.h),

                                      // Confirm Password Field
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
                                        style: TextStyle(
                                          color: AppTheme.whiteText,
                                          fontSize: 14.sp,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Confirm Password',
                                          hintText: 'Confirm your password',
                                          prefixIcon: Icon(
                                            Icons.lock_outline,
                                            color: AppTheme.goldAccent,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                              color: AppTheme.whiteText
                                                  .withOpacity(0.7),
                                            ),
                                            onPressed: () => setState(
                                              () => _obscureConfirmPassword =
                                                  !_obscureConfirmPassword,
                                            ),
                                          ),
                                          fillColor: AppTheme.glassBackground,
                                          labelStyle: TextStyle(
                                            color: AppTheme.whiteText
                                                .withOpacity(0.8),
                                          ),
                                          hintStyle: TextStyle(
                                            color: AppTheme.whiteText
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please confirm your password';
                                          }
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),

                                      SizedBox(height: 32.h),

                                      // Register Button
                                      SizedBox(
                                        height: 50.h,
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _handleRegister,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme
                                                .primaryGreen
                                                .withOpacity(0.9),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? SizedBox(
                                                  height: 20.h,
                                                  width: 20.h,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(AppTheme.whiteText),
                                                  ),
                                                )
                                              : Text(
                                                  'Create Account',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.whiteText,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 24.h),

                                // Login Link
                                Container(
                                  decoration: AppTheme.glassMorphicDecoration,
                                  padding: EdgeInsets.all(20.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an account? ",
                                        style: TextStyle(
                                          color: AppTheme.whiteText.withOpacity(
                                            0.8,
                                          ),
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            color: AppTheme.goldAccent,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
