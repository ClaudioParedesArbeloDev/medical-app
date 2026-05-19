import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medical_app/screens/home_screen.dart';
import 'package:medical_app/core/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late final AnimationController _mainCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;


  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;


  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;


  late final AnimationController _particleCtrl;

  static const _particles = 18;
  final List<_Particle> _particleList = List.generate(
    _particles,
    (i) => _Particle.random(i),
  );

  @override
  void initState() {
    super.initState();

    // Main entrance
    _mainCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOutCubic));

    // Pulse
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Shimmer
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _shimmerAnim =
        Tween<double>(begin: -1.5, end: 2.5).animate(_shimmerCtrl);

    // Particles
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat();

    _mainCtrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, _) => const Home(),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }


  double _layoutWidth(BoxConstraints c) => math.min(c.maxWidth, 520);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final lw = _layoutWidth(constraints);
          final isDesktop = constraints.maxWidth > 800;
          final lottieSz = isDesktop ? 240.0 : 180.0;
          final titleSz  = isDesktop ?  38.0 :  28.0;
          final subtitleSz = isDesktop ? 16.0 : 13.0;

          return Stack(
            children: [

              _GradientBackground(pulseAnim: _pulseAnim),


              AnimatedBuilder(
                animation: _particleCtrl,
                builder: (_, _) => CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _ParticlePainter(
                    particles: _particleList,
                    progress: _particleCtrl.value,
                  ),
                ),
              ),


              Center(
                child: SizedBox(
                  width: lw,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 48.0 : 32.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            _MedicalCrossDecor(size: isDesktop ? 28.0 : 22.0),

                            const SizedBox(height: 24),


                            _LottieHalo(
                              pulseAnim: _pulseAnim,
                              lottieSz: lottieSz,
                            ),

                            const SizedBox(height: 32),


                            Text(
                              'Salud al Día',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: titleSz,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),

                            const SizedBox(height: 10),


                            AnimatedBuilder(
                              animation: _shimmerAnim,
                              builder: (_, _) => ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: const [
                                    AppColors.accent,
                                    AppColors.textPrimary,
                                    AppColors.accent,
                                  ],
                                  stops: [
                                    _shimmerAnim.value - 0.4,
                                    _shimmerAnim.value,
                                    _shimmerAnim.value + 0.4,
                                  ].map((s) => s.clamp(0.0, 1.0)).toList(),
                                ).createShader(bounds),
                                child: Text(
                                  'Tu bienestar, siempre presente',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: subtitleSz,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.6,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 48),


                            _LoadingDots(),

                            SizedBox(height: isDesktop ? 40 : 24),


                            _VersionBadge(fontSize: subtitleSz - 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),


              if (isDesktop)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _GridPainter(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _GradientBackground({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, _) => Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            radius: 1.2 * pulseAnim.value,
            colors: const [
              Color(0xFF2a2133),
              AppColors.background,
            ],
          ),
        ),
      ),
    );
  }
}


class _LottieHalo extends StatelessWidget {
  final Animation<double> pulseAnim;
  final double lottieSz;
  const _LottieHalo({required this.pulseAnim, required this.lottieSz});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, child) => Container(
        width: lottieSz + 40,
        height: lottieSz + 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent
                  .withValues(alpha: 0.15 * pulseAnim.value),
              blurRadius: 60 * pulseAnim.value,
              spreadRadius: 20 * pulseAnim.value,
            ),
          ],
        ),
        child: child,
      ),
      child: Container(
        width: lottieSz + 40,
        height: lottieSz + 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.backgroundLight.withValues(alpha: 0.15),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Lottie.asset(
            'assets/animations/doctor.json',
            width: lottieSz,
            height: lottieSz,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}


class _MedicalCrossDecor extends StatelessWidget {
  final double size;
  const _MedicalCrossDecor({required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _thinLine(),
        const SizedBox(width: 12),
        Icon(
          Icons.add,
          color: AppColors.accent,
          size: size,
        ),
        const SizedBox(width: 12),
        _thinLine(),
      ],
    );
  }

  Widget _thinLine() => Container(
        width: 40,
        height: 1,
        color: AppColors.accent.withValues(alpha: 0.4),
      );
}


class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final phase = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
          final scale =
              math.sin(phase * math.pi).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.scale(
              scale: 0.5 + scale * 0.5,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    AppColors.accent.withValues(alpha: 0.3),
                    AppColors.accent,
                    scale,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}


class _VersionBadge extends StatelessWidget {
  final double fontSize;
  const _VersionBadge({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.2),
        ),
        color: AppColors.accent.withValues(alpha: 0.05),
      ),
      child: Text(
        'v1.0.0  •  Salud al Día',
        style: TextStyle(
          fontSize: fontSize,
          color: AppColors.textSecondary.withValues(alpha: 0.8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}


class _Particle {
  final double x, y, radius, speed, angle, opacity;
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.angle,
    required this.opacity,
  });

  factory _Particle.random(int seed) {
    final rng = math.Random(seed * 1337);
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      radius: 1.0 + rng.nextDouble() * 2.5,
      speed: 0.04 + rng.nextDouble() * 0.06,
      angle: rng.nextDouble() * math.pi * 2,
      opacity: 0.1 + rng.nextDouble() * 0.35,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  const _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed * 10 + p.angle) % (math.pi * 2);
      final dx = math.cos(t) * 80;
      final dy = math.sin(t) * 50;
      final cx = p.x * size.width + dx;
      final cy = p.y * size.height + dy;

      canvas.drawCircle(
        Offset(cx, cy),
        p.radius,
        Paint()
          ..color = AppColors.accent.withValues(alpha: p.opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.progress != progress;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.backgroundLight.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    const step = 80.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}