import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _startAnimations();

    // Navigate to home screen after delay
    _navigateToHome();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      _scaleController.forward();
    });
  }

  void _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  AppTheme.glassMorphBlack.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _fadeController,
                    _scaleController,
                  ]),
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          decoration: AppTheme.glassMorphicDecoration,
                          padding: EdgeInsets.all(40.w),
                          margin: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // App Icon/Logo
                              Container(
                                width: 80.w,
                                height: 80.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryGreen,
                                      AppTheme.lightGreen,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen.withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 15,
                                      offset: Offset(0, 5.h),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.auto_stories,
                                  size: 40.sp,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // App Name
                              Text(
                                'Dua App',
                                style: TextStyle(
                                  color: AppTheme.whiteText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 8.h),

                              // Arabic Name
                              Text(
                                'تطبيق الدعاء',
                                style: TextStyle(
                                  color: AppTheme.goldAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 16.h),

                              // Subtitle
                              Text(
                                'Find peace through Islamic wisdom',
                                style: TextStyle(
                                  color: AppTheme.whiteText.withOpacity(0.8),
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 24.h),

                              // Loading indicator
                              SizedBox(
                                width: 30.w,
                                height: 30.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.goldAccent,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
