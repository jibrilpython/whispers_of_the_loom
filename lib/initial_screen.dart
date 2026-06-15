import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whispers_of_the_loom/providers/user_provider.dart';
import 'package:whispers_of_the_loom/utils/const.dart';

class _Feature {
  final IconData icon;
  final String title;
  final String body;
  const _Feature(this.icon, this.title, this.body);
}

const _features = [
  _Feature(
    Icons.inventory_2_outlined,
    'Hearth Archive',
    'Catalog drop spindles, walking wheels, carding paddles, and skein winders with full provenance and artisan hallmarks.',
  ),
  _Feature(
    Icons.blur_on_outlined,
    'Thread Field',
    'A living constellation — your tools orbit a central whorl, linked by flowing thread.',
  ),
  _Feature(
    Icons.analytics_outlined,
    'Archive Ledger',
    'Track fiber specifications, craft classifications, and mechanical soundness across your entire collection.',
  ),
];

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _entryController.forward();
    });

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) setState(() => _currentPage = page);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entryController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _enter() {
    HapticFeedback.mediumImpact();
    ref.read(userProvider).setFirstTimeUser(false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (_, _) => CustomPaint(
                painter: _ThreadFieldPainter(t: _bgController.value),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 48.h),
                              _buildWordmark(),
                              SizedBox(height: 32.h),
                              _buildPager(),
                              SizedBox(height: 24.h),
                              _buildDots(),
                              const Spacer(),
                              _buildCta(),
                              SizedBox(height: 36.h),
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
        ],
      ),
    );
  }

  Widget _buildWordmark() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HEARTH FIBER ARCHIVE',
            style: GoogleFonts.ibmPlexMono(
              color: kAccent.withAlpha(160),
              fontSize: 8.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.4,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Whispers',
            style: GoogleFonts.lora(
              color: kPrimaryText,
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
          Text(
            'of the Loom',
            style: GoogleFonts.lora(
              color: kPrimaryText,
              fontSize: 44.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
              height: 0.92,
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            width: 44.w,
            height: 1.5,
            color: kAccent.withAlpha(120),
          ),
          SizedBox(height: 14.h),
          Text(
            'Quiet tools of the hearth,\ndigitally archived.',
            style: GoogleFonts.inter(
              color: kSecondaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPager() {
    return SizedBox(
      height: 160.h,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _features.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          final f = _features[i];
          final isActive = i == _currentPage;
          return AnimatedOpacity(
            duration: kTransitionDuration,
            opacity: isActive ? 1.0 : 0.45,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: kCardSurface.withAlpha(isActive ? 240 : 200),
                  borderRadius: BorderRadius.circular(kRadiusStandard),
                  border: Border.all(
                    color: isActive ? kAccent.withAlpha(80) : kOutline,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: kAccent.withAlpha(isActive ? 31 : 15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kAccent.withAlpha(50)),
                      ),
                      child: Icon(f.icon, color: kAccent, size: 20.sp),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            style: GoogleFonts.lora(
                              color: kPrimaryText,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            f.body,
                            style: GoogleFonts.inter(
                              color: kSecondaryText,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w300,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDots() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Row(
        children: List.generate(_features.length, (i) {
          final isActive = i == _currentPage;
          return AnimatedContainer(
            duration: kTransitionDuration,
            margin: EdgeInsets.only(right: 6.w),
            width: isActive ? 20.w : 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: isActive ? kAccent : kOutline,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCta() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: _enter,
            child: Container(
              width: double.infinity,
              height: 54.h,
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(kRadiusPill),
                boxShadow: [
                  BoxShadow(
                    color: kAccent.withAlpha(50),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ENTER THE ARCHIVE',
                    style: GoogleFonts.ibmPlexMono(
                      color: kCardSurface,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward_rounded,
                      color: kCardSurface.withAlpha(200), size: 16.sp),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'For keepers of folk-art heritage.',
            style: GoogleFonts.lora(
              color: kSecondaryText.withAlpha(150),
              fontSize: 12.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadFieldPainter extends CustomPainter {
  final double t;
  _ThreadFieldPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.72;
    final cy = size.height * 0.22;

    for (int i = 0; i < 5; i++) {
      final r = 40.0 + i * 28;
      final angle = t * math.pi * 2 * (0.15 + i * 0.04);
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = kAccent.withAlpha((8 + i * 3).clamp(5, 22))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );

      final bobAngle = angle + i * 1.2;
      final bx = cx + r * math.cos(bobAngle);
      final by = cy + r * 0.7 * math.sin(bobAngle);
      canvas.drawCircle(
        Offset(bx, by),
        3 + i * 0.4,
        Paint()..color = kAccent.withAlpha(40 + i * 15),
      );

      final path = Path();
      final segments = 24;
      for (int s = 0; s <= segments; s++) {
        final frac = s / segments;
        final a = angle + frac * math.pi * 0.5;
        final px = cx + r * frac * math.cos(a);
        final wave = math.sin(frac * math.pi * 4 + t * math.pi * 6 + i) * 6;
        final py = cy + r * 0.7 * frac * math.sin(a) + wave;
        if (s == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = kHerbGreen.withAlpha(25 + i * 8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    canvas.drawCircle(
      Offset(cx, cy),
      5,
      Paint()..color = kAccent.withAlpha(80),
    );
  }

  @override
  bool shouldRepaint(covariant _ThreadFieldPainter old) => old.t != t;
}
