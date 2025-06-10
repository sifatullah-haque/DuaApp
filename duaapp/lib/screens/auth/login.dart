import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/theme.dart';
import '../../services/appwrite_service.dart';
import 'register.dart';
import '../profile/profile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appwrite = AppwriteService();
      final result = await appwrite.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result['success']) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                                SizedBox(height: 40.h),

                                // Welcome Container
                                Container(
                                  decoration: AppTheme.glassMorphicDecoration,
                                  padding: EdgeInsets.all(24.w),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.mosque,
                                        size: 48.sp,
                                        color: AppTheme.goldAccent,
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'Welcome Back',
                                        style: TextStyle(
                                          color: AppTheme.whiteText,
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'أهلاً بعودتك',
                                        style: TextStyle(
                                          color: AppTheme.goldAccent,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Sign in to continue your spiritual journey',
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

                                SizedBox(height: 32.h),

                                // Login Form Container
                                Container(
                                  decoration: AppTheme.glassMorphicDecoration,
                                  padding: EdgeInsets.all(24.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
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

                                      SizedBox(height: 32.h),

                                      // Login Button
                                      SizedBox(
                                        height: 50.h,
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _handleLogin,
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
                                                  'Login',
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

                                // Register Link
                                Container(
                                  decoration: AppTheme.glassMorphicDecoration,
                                  padding: EdgeInsets.all(20.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: TextStyle(
                                          color: AppTheme.whiteText.withOpacity(
                                            0.8,
                                          ),
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RegisterScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Register',
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
