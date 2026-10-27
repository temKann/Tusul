import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/birth_profile.dart';
import '../widgets/astro_widgets.dart';
import 'app_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final BirthProfile profile = BirthProfile();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final ScrollController contentScrollController = ScrollController();

  int step = 0;
  int transitionDirection = 1;
  bool genderAnimating = false;
  bool locationToNameAnimating = false;
  bool nameToBlackHoleAnimating = false;
  bool nicknameEmerging = false;
  bool relationshipSunEmerging = false;
  bool nameSunBlackHole = false;
  bool dateSelected = true;
  bool timeSelected = true;

  @override
  void dispose() {
    placeController.dispose();
    nameController.dispose();
    nicknameController.dispose();
    contentScrollController.dispose();
    super.dispose();
  }

  bool get hasPartner => const ['Харилцаатай', 'Сүй тавьсан', 'Гэрлэсэн', 'Төвөгтэй']
      .contains(profile.relationshipStatus);

  bool get canContinue {
    switch (step) {
      case 0:
        return profile.gender.isNotEmpty;
      case 1:
        return dateSelected;
      case 2:
        return timeSelected || profile.birthTimeUnknown;
      case 3:
        return placeController.text.trim().isNotEmpty;
      case 4:
        return nameController.text.trim().isNotEmpty;
      case 5:
        return nicknameController.text.trim().isNotEmpty;
      case 6:
        return profile.relationshipStatus.isNotEmpty;
      case 7:
        return profile.partnerBirthDate != null;
      default:
        return false;
    }
  }

  void continueFlow() {
    if (locationToNameAnimating || nameToBlackHoleAnimating || nicknameEmerging || relationshipSunEmerging) return;
    if (!canContinue) return;
    if (step == 6 && !hasPartner) {
      finishOnboarding(openMatch: false);
      return;
    }
    if (step == 7) {
      finishOnboarding(openMatch: true);
      return;
    }
    if (step == 3 && !nameSunBlackHole) {
      setState(() {
        locationToNameAnimating = true;
        nameSunBlackHole = false;
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted || step != 3) return;
        setState(() {
          transitionDirection = 1;
          step = 4;
        });
        resetPageScroll();
      });
      Future.delayed(const Duration(milliseconds: 3400), () {
        if (!mounted) return;
        setState(() {
          locationToNameAnimating = false;
          nameSunBlackHole = step == 4;
        });
      });
      return;
    }
    if (step == 4) {
      setState(() => nameToBlackHoleAnimating = true);
      Future.delayed(const Duration(milliseconds: 2600), () {
        if (!mounted || step != 4) return;
        setState(() {
          transitionDirection = 1;
          step = 5;
          nameToBlackHoleAnimating = false;
          nicknameEmerging = true;
        });
        resetPageScroll();
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          setState(() => nicknameEmerging = false);
        });
      });
      return;
    }
    if (step == 5) {
      setState(() {
        nameSunBlackHole = false;
        relationshipSunEmerging = true;
      });
      Future.delayed(const Duration(milliseconds: 1750), () {
        if (!mounted || step != 5) return;
        setState(() {
          transitionDirection = 1;
          step = 6;
        });
        resetPageScroll();
      });
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (mounted) setState(() => relationshipSunEmerging = false);
      });
      return;
    }
    setState(() {
      transitionDirection = 1;
      step++;
    });
    resetPageScroll();
  }

  void goBack() {
    setState(() {
      transitionDirection = -1;
      step--;
    });
    resetPageScroll();
  }

  void resetPageScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (contentScrollController.hasClients) {
        contentScrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
      }
    });
  }

  void selectGender(String value) {
    if (genderAnimating) return;
    setState(() {
      profile.gender = value;
      genderAnimating = true;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted || step != 0) return;
      setState(() {
        transitionDirection = 1;
        step = 1;
        genderAnimating = false;
      });
      resetPageScroll();
    });
  }

  void finishOnboarding({required bool openMatch}) {
    profile.birthPlace = placeController.text.trim();
    profile.name = nameController.text.trim();
    profile.nickname = nicknameController.text.trim();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _CreatingProfileScreen(profile: profile, openMatch: openMatch),
      ),
    );
  }

  String get continueLabel {
    if (step == 6 && !hasPartner) return 'Профайл руу орох';
    if (step == 7) return 'Нийцлийг харах';
    return 'Үргэлжлүүлэх';
  }

  Widget buildStep() {
    switch (step) {
      case 0:
        return _GenderStep(
          value: profile.gender,
          flying: genderAnimating,
          onChanged: selectGender,
        );
      case 1:
        return _BirthDateStep(
          date: profile.birthDate,
          onChanged: (date) => setState(() {
            profile.birthDate = date;
            dateSelected = true;
          }),
        );
      case 2:
        return _BirthTimeStep(
          time: profile.birthTime,
          unknown: profile.birthTimeUnknown,
          selected: timeSelected,
          onChanged: (time) => setState(() {
            profile.birthTime = time;
            profile.birthTimeUnknown = false;
            timeSelected = true;
          }),
          onUnknownChanged: (value) => setState(() {
            profile.birthTimeUnknown = value;
            if (value) timeSelected = false;
          }),
        );
      case 3:
        return _BirthPlaceStep(
          controller: placeController,
          onChanged: (_) => setState(() {}),
          onSuggestedPlace: (place) {
            placeController.text = place;
            setState(() {});
          },
        );
      case 4:
        return _TextEntryStep(
          title: 'Таны бүтэн нэр',
          subtitle: 'Төрсний гэрчилгээнд бичигдсэн нэрээ оруулна уу.',
          label: 'НЭР',
          hint: 'Таны нэр',
          controller: nameController,
          onChanged: (value) => setState(() => profile.name = value),
          icon: Icons.person_outline,
        );
      case 5:
        return _TextEntryStep(
          title: 'Таныг юу гэж дуудах вэ?',
          subtitle: 'Найз нөхөд, одод таныг ямар нэрээр дуудах вэ?',
          label: 'NICKNAME',
          hint: 'Nickname оруулна уу',
          controller: nicknameController,
          onChanged: (value) => setState(() => profile.nickname = value),
          icon: Icons.waving_hand_outlined,
        );
      case 6:
        return _RelationshipStep(
          value: profile.relationshipStatus,
          onChanged: (value) =>
              setState(() => profile.relationshipStatus = value),
        );
      default:
        return _PartnerBirthDateStep(
          date: profile.partnerBirthDate,
          onChanged: (date) => setState(() => profile.partnerBirthDate = date),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF190726),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: locationToNameAnimating || nameToBlackHoleAnimating || nicknameEmerging || relationshipSunEmerging
              ? null
              : step == 0
              ? () => Navigator.pop(context)
              : goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const SizedBox.shrink(),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
        AnimatedSwitcher(
        duration: const Duration(milliseconds: 620),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          final slidingPage = SlideTransition(
            position: Tween<Offset>(
              begin: Offset(transitionDirection * .055, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
          final revealedPage = step == 6
              ? ClipPath(
                  clipper: _SolarRevealClipper(curved.value),
                  child: slidingPage,
                )
              : slidingPage;
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: step == 1 ? .82 : .96, end: 1).animate(curved),
              alignment: Alignment.topCenter,
              child: revealedPage,
            ),
          );
        },
        child: step == 0
            ? KeyedSubtree(key: const ValueKey('gender-background'), child: buildGenderPage())
            : KeyedSubtree(key: const ValueKey('cosmic-background'), child: CosmicBackground(atmosphere: step,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: contentScrollController,
                    padding: const EdgeInsets.fromLTRB(24, 58, 24, 20),
                    child: Column(
                      children: [
                        _AstroHero(
                          step: step,
                          profile: profile,
                          blackHole: nameSunBlackHole && step >= 3 && step <= 5,
                          hideHeadline: nicknameEmerging,
                          sunEmerging: relationshipSunEmerging && (step == 5 || step == 6),
                        ),
                        const SizedBox(height: 28),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 520),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            final motion = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                              reverseCurve: Curves.easeInCubic,
                            );
                            final revealedChild = step == 6
                                ? ClipPath(
                                    clipper: _SolarRevealClipper(
                                      motion.value,
                                      originY: 0,
                                    ),
                                    child: child,
                                  )
                                : child;
                            return FadeTransition(
                              opacity: animation,
                              child: RotationTransition(
                                turns: Tween<double>(
                                  begin: transitionDirection * .012,
                                  end: 0,
                                ).animate(motion),
                                child: ScaleTransition(
                                  alignment: Alignment.topCenter,
                                  scale: Tween<double>(begin: .78, end: 1).animate(motion),
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(transitionDirection * .035, .025),
                                      end: Offset.zero,
                                    ).animate(motion),
                                    child: revealedChild,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: KeyedSubtree(key: ValueKey(step), child: buildStep()),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: canContinue &&
                              !locationToNameAnimating &&
                              !nameToBlackHoleAnimating &&
                              !nicknameEmerging &&
                              !relationshipSunEmerging
                          ? continueFlow
                          : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(62),
                        backgroundColor: const Color(0xFF3032D2),
                        disabledBackgroundColor: const Color(0xFF3032D2).withOpacity(.35),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(continueLabel,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ))),
        if (locationToNameAnimating) const Positioned.fill(child: _ShootingStarImpact()),
        if (nameToBlackHoleAnimating)
          Positioned.fill(
            child: _NameIntoBlackHoleTransition(name: nameController.text.trim()),
          ),
        if (nicknameEmerging)
          const Positioned.fill(child: _NicknameEmergence()),
        ],
      ),
    );
  }

  Widget buildGenderPage() => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/gender_couple.png', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, .34, .60, 1],
                colors: [
                  Color(0x11110B2D),
                  Color(0x20110B2D),
                  Color(0x99110B38),
                  Color(0xF51C164E),
                ],
              ),
            ),
          ),
          const Positioned.fill(child: _GenderStarAnimation()),
          SafeArea(child: buildStep()),
          if (genderAnimating) _GenderFlyToSun(gender: profile.gender),
      ],
      );
}

class _GenderStarAnimation extends StatefulWidget {
  const _GenderStarAnimation();

  @override
  State<_GenderStarAnimation> createState() => _GenderStarAnimationState();
}

class _GenderStarAnimationState extends State<_GenderStarAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _GenderStarsPainter(_controller.value),
            ),
          ),
        ),
      );
}

class _GenderStarsPainter extends CustomPainter {
  final double progress;
  const _GenderStarsPainter(this.progress);

  // Normalized positions keep the twinkles aligned across screen sizes.
  static const _stars = <(double, double, double, double)>[
    (.035, .035, 1.5, .12), (.143, .041, 2.2, .56), (.263, .025, 1.4, .31),
    (.738, .023, 1.7, .67), (.821, .040, 2.3, .24), (.923, .030, 1.4, .81),
    (.064, .112, 2.4, .38), (.178, .096, 1.7, .72), (.335, .128, 2.0, .05),
    (.603, .104, 1.7, .49), (.817, .112, 2.0, .92), (.951, .137, 2.1, .18),
    (.083, .199, 1.8, .83), (.232, .214, 1.6, .27), (.653, .184, 2.0, .61),
    (.813, .208, 1.7, .03), (.956, .238, 1.9, .43), (.041, .307, 1.6, .95),
    (.236, .281, 2.0, .16), (.599, .293, 1.8, .76), (.842, .319, 2.2, .34),
    (.129, .365, 2.0, .58), (.831, .384, 1.8, .09),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (x, y, radius, phase) in _stars) {
      final wave = (math.sin((progress + phase) * math.pi * 2) + 1) / 2;
      final paint = Paint()
        ..color = Colors.white.withOpacity(.12 + wave * .68)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 + wave * 2.2);
      final drift = math.sin((progress + phase) * math.pi * 2) * 2.5;
      canvas.drawCircle(Offset(x * size.width + drift, y * size.height), radius * (.72 + wave * .55), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GenderStarsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _NameIntoBlackHoleTransition extends StatelessWidget {
  final String name;
  const _NameIntoBlackHoleTransition({required this.name});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 2600),
          curve: Curves.easeInOutCubic,
          builder: (context, progress, _) => RepaintBoundary(
            child: CustomPaint(
              painter: _NameIntoBlackHolePainter(name, progress),
            ),
          ),
        ),
      );
}

class _NameIntoBlackHolePainter extends CustomPainter {
  final String name;
  final double progress;
  const _NameIntoBlackHolePainter(this.name, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final target = Offset(size.width * .5, size.height * .23);
    final start = Offset(size.width * .5, size.height * .60);
    final control = Offset(size.width * .18, size.height * .44);
    final t = Curves.easeInCubic.transform(progress);
    final inverse = 1 - t;
    final position = Offset(
      inverse * inverse * start.dx + 2 * inverse * t * control.dx + t * t * target.dx,
      inverse * inverse * start.dy + 2 * inverse * t * control.dy + t * t * target.dy,
    );
    final emission = .22 + .78 * Curves.easeInCubic.transform(progress);
    final aura = Paint()
      ..color = const Color(0xFFFF8D4C).withOpacity(.20 * emission)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 54);
    canvas.drawCircle(target, 58 + progress * 34, aura);
    for (var i = 0; i < 32; i++) {
      final angle = math.pi * 2 * i / 32 + progress * math.pi * 2.5;
      final inner = 48 + math.sin(progress * math.pi * 4 + i) * 5;
      final outer = inner + 32 + 48 * emission * (i.isEven ? 1 : .62);
      final ray = Paint()
        ..color = (i % 4 == 0 ? const Color(0xFFFFE8B0) : const Color(0xFFFF9B57))
            .withOpacity(.72 * emission)
        ..strokeWidth = (i.isEven ? 3.2 : 1.8) * emission + .4
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, i.isEven ? 4 : 1.5);
      canvas.drawLine(
        target + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        target + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        ray,
      );
    }

    final trail = Paint()
      ..color = const Color(0xFFFFC06C).withOpacity(.9 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * (1 - progress) + .8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, position.dx, position.dy);
    canvas.drawPath(path, trail);

    final scale = 1 - .72 * t;
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          color: Color.lerp(const Color(0xFFFFF3C7), Colors.white, 1 - t)!
              .withOpacity((1 - .82 * t).clamp(0.0, 1.0).toDouble()),
          fontSize: 24 * scale,
          fontWeight: FontWeight.w800,
          shadows: const [Shadow(color: Color(0xFFFFA94D), blurRadius: 16)],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: size.width * .82);
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.scale(1 - .12 * t, 1 - .24 * t);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();

    final swirl = Paint()
      ..color = const Color(0xFFFFAE5E).withOpacity((1 - progress) * .95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawArc(
      Rect.fromCircle(center: target, radius: 26 + progress * 24),
      -math.pi * .35 + progress * math.pi * 7,
      math.pi * 1.45,
      false,
      swirl,
    );
    final pulse = Paint()
      ..color = const Color(0xFFFFC06C).withOpacity(.42 * emission)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34);
    canvas.drawCircle(target, 38 + 30 * math.sin(progress * math.pi * 2), pulse);
  }

  @override
  bool shouldRepaint(covariant _NameIntoBlackHolePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.name != name;
}

class _NicknameEmergence extends StatelessWidget {
  const _NicknameEmergence();

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (context, progress, _) => LayoutBuilder(
            builder: (context, constraints) {
              final travel = Curves.easeOutCubic.transform(progress);
              final centerY = constraints.maxHeight * (.23 + .18 * travel);
              final centerX = constraints.maxWidth *
                  (.5 + .025 * math.sin(progress * math.pi));
              final scale = .22 + .78 * Curves.easeOutBack.transform(progress);
              final opacity = ((progress - .025) / .28).clamp(0.0, 1.0).toDouble();
              return Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(child: CustomPaint(painter: _NicknameFlarePainter(progress))),
                  Positioned(
                    left: 18 + (centerX - constraints.maxWidth * .5),
                    right: 18 - (centerX - constraints.maxWidth * .5),
                    top: centerY - 26,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: const Text(
                          'My nickname is',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Color(0xFFFFC477), blurRadius: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
}

class _NicknameFlarePainter extends CustomPainter {
  final double progress;
  const _NicknameFlarePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * .5, size.height * .23);
    final flashProgress = (progress / .72).clamp(0.0, 1.0).toDouble();
    final flare = Paint()
      ..color = const Color(0xFFFFB65A).withOpacity((1 - flashProgress) * .94)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 52);
    canvas.drawCircle(origin, 18 + flashProgress * 112, flare);
    final whiteFlash = Paint()
      ..color = const Color(0xFFFFF1CA).withOpacity((1 - flashProgress) * .85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(origin, 12 + 22 * (1 - flashProgress), whiteFlash);

    final ring = Paint()
      ..color = const Color(0xFFFFD181).withOpacity((1 - flashProgress) * .98)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * (1 - flashProgress) + .7
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(origin, 10 + flashProgress * 150, ring);
    final secondRing = Paint()
      ..color = const Color(0xFFFF9D4D).withOpacity((1 - flashProgress) * .68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * (1 - flashProgress) + .4;
    canvas.drawCircle(origin, 24 + flashProgress * 118, secondRing);

    for (var i = 0; i < 36; i++) {
      final angle = math.pi * 2 * i / 36 + progress * math.pi * 1.1;
      final inner = 18 + flashProgress * 26;
      final outer = inner + 34 + flashProgress * (i.isEven ? 120 : 82);
      final spark = Paint()
        ..color = (i % 4 == 0 ? const Color(0xFFFFF1CA) : const Color(0xFFFFA24E))
            .withOpacity((1 - flashProgress) * .96)
        ..strokeWidth = (i.isEven ? 4 : 2.4) * (1 - flashProgress) + .5
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, i.isEven ? 5 : 2);
      canvas.drawLine(
        origin + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        origin + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        spark,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NicknameFlarePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SolarRevealClipper extends CustomClipper<Path> {
  final double progress;
  final double originY;
  const _SolarRevealClipper(this.progress, {this.originY = .23});

  @override
  Path getClip(Size size) {
    final origin = Offset(size.width * .5, size.height * originY);
    final radius = math.sqrt(size.width * size.width + size.height * size.height) * progress;
    return Path()..addOval(Rect.fromCircle(center: origin, radius: radius));
  }

  @override
  bool shouldReclip(covariant _SolarRevealClipper oldClipper) =>
      oldClipper.progress != progress;
}

class _BlackHoleToSun extends StatelessWidget {
  const _BlackHoleToSun();

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 3000),
        curve: Curves.easeInOutCubic,
        builder: (context, progress, _) => SizedBox(
          width: 124,
          height: 124,
          child: CustomPaint(painter: _BlackHoleToSunPainter(progress)),
        ),
      );
}

class _BlackHoleToSunPainter extends CustomPainter {
  final double progress;
  const _BlackHoleToSunPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final sunReveal = ((progress - .16) / .84).clamp(0.0, 1.0).toDouble();
    final sunGrowth = Curves.easeOutCubic.transform(sunReveal);
    final sunCenter = center + Offset(17 * (1 - sunGrowth), -3 * (1 - sunGrowth));
    final sunRadius = 55 * sunGrowth;
    final holeDissolve = ((progress - .72) / .28).clamp(0.0, 1.0).toDouble();
    final holeOpacity = 1 - Curves.easeInOutCubic.transform(holeDissolve);
    const holeRadius = 42.0;

    // The sun lights up behind the event horizon before the black center fades.
    final corona = Paint()
      ..color = const Color(0xFFFF963F).withOpacity(.18 + .48 * sunGrowth)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 19 + 35 * sunGrowth);
    canvas.drawCircle(sunCenter, 24 + sunRadius * .9, corona);
    if (sunRadius > .1) {
      for (var i = 0; i < 32; i++) {
        final angle = math.pi * 2 * i / 32 + progress * .35;
        final inner = sunRadius * .88;
        final outer = inner + 9 + 27 * sunGrowth * (i.isEven ? 1 : .55);
        final ray = Paint()
          ..color = const Color(0xFFFFD58A).withOpacity(.48 * sunGrowth)
          ..strokeWidth = (i.isEven ? 2.1 : 1.1) * sunGrowth
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, i.isEven ? 3 : 1);
        canvas.drawLine(
          sunCenter + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
          sunCenter + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
          ray,
        );
      }
      canvas.drawCircle(
        sunCenter,
        sunRadius,
        Paint()
          ..shader = ui.Gradient.radial(
            sunCenter,
            sunRadius,
            const [Color(0xFFFFF0AF), Color(0xFFFFAD36), Color(0xFFEF4920)],
          ),
      );
    }

    // A rotating, flattened accretion disk makes the dark center feel heavy.
    if (holeOpacity > .005) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(1, .34);
      final diskRadius = holeRadius + 9 + 14 * progress;
      for (var i = 0; i < 3; i++) {
        final disk = Paint()
          ..color = (i == 1 ? const Color(0xFFFFE0A0) : const Color(0xFFFF7A32))
              .withOpacity(holeOpacity * (i == 1 ? .85 : .58))
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 1 ? 2.4 : 4.5
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, i == 1 ? 3 : 8);
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: diskRadius + i * 4),
          progress * math.pi * (i.isEven ? 2.2 : -1.6) + i * 2,
          math.pi * (1.2 + i * .2),
          false,
          disk,
        );
      }
      canvas.restore();

      canvas.drawCircle(
        center,
        holeRadius,
        Paint()
          ..shader = ui.Gradient.radial(center, holeRadius, [
            const Color(0xFF090611).withOpacity(holeOpacity),
            Colors.black.withOpacity(holeOpacity),
          ]),
      );

      // Dust spirals inward and vanishes behind the event horizon.
      for (var i = 0; i < 18; i++) {
        final angle = math.pi * 2 * i / 18 + progress * math.pi * 3.2;
        final orbitRadius = 72 - progress * 30 + math.sin(angle * 2) * 3;
        if (orbitRadius <= holeRadius + 2) continue;
        final point = center + Offset(math.cos(angle) * orbitRadius, math.sin(angle) * orbitRadius);
        final dust = Paint()
          ..color = const Color(0xFFFFD99B).withOpacity((.25 + .65 * (1 - progress)) * holeOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
        canvas.drawCircle(point, i.isEven ? 1.8 : 1.2, dust);
      }
    }

    // The sun's core becomes visible only after it has cleared the darkness.
    if (holeOpacity < .18) {
      final sunTextOpacity = (1 - holeOpacity / .18).clamp(0.0, 1.0).toDouble();
      final sunText = TextPainter(
        text: TextSpan(
          text: '☀',
          style: TextStyle(
            color: Colors.white.withOpacity(sunTextOpacity),
            fontSize: 39 * sunTextOpacity,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      sunText.paint(
        canvas,
        Offset(center.dx - sunText.width / 2, center.dy - sunText.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BlackHoleToSunPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _BlackHole extends StatelessWidget {
  const _BlackHole();

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 124,
        height: 124,
        child: CustomPaint(painter: _BlackHolePainter()),
      );
}

class _BlackHolePainter extends CustomPainter {
  const _BlackHolePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      51,
      Paint()
        ..color = const Color(0xFFFF743D).withOpacity(.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
    canvas.drawCircle(
      center,
      47,
      Paint()
        ..color = const Color(0xFFFFC16A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );
    canvas.drawCircle(
      center,
      42,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          42,
          const [Color(0xFF10091C), Color(0xFF000000)],
        ),
    );
    canvas.drawCircle(
      center,
      40,
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _BlackHolePainter oldDelegate) => false;
}

class _ShootingStarImpact extends StatelessWidget {
  const _ShootingStarImpact();

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 3000),
          curve: Curves.easeInOutCubic,
          builder: (context, progress, _) => RepaintBoundary(
            child: CustomPaint(painter: _ShootingStarPainter(progress)),
          ),
        ),
      );
}

class _ShootingStarPainter extends CustomPainter {
  final double progress;
  const _ShootingStarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final source = Offset(size.width * .50, size.height * .23);
    final upperRight = Offset(size.width * 1.06, size.height * .045);
    final upperLeft = Offset(-size.width * .06, size.height * .045);
    final target = Offset(size.width * .50, size.height * .23);
    Offset? head;
    Offset? trailOrigin;
    var starOpacity = 1.0;
    if (progress <= .30) {
      final flight = Curves.easeInCubic.transform(progress / .30);
      head = Offset.lerp(source, upperRight, flight);
      trailOrigin = source;
      starOpacity = (1 - (flight * .45)).clamp(0.0, 1.0).toDouble();
    } else if (progress < .54) {
      head = upperRight;
      trailOrigin = upperRight;
    } else if (progress >= .54 && progress < .82) {
      final flight = Curves.easeInOutCubic.transform((progress - .54) / .28);
      head = Offset.lerp(upperLeft, target, flight);
      trailOrigin = upperLeft;
    }

    if (head != null && trailOrigin != null) {
      final tail = Offset.lerp(head, trailOrigin, .16)!;
      final trail = Paint()
        ..shader = ui.Gradient.linear(
          tail,
          head,
          [Colors.transparent, const Color(0xFFFFB85A).withOpacity(.95 * starOpacity)],
        )
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(tail, head, trail);
      final glow = Paint()
        ..color = const Color(0xFFFFD078).withOpacity(.75 * starOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(head, 8, glow);
      _drawSpark(canvas, head, 9, const Color(0xFFFFF4C2).withOpacity(starOpacity));
    }

    if (progress >= .82) {
      final impact = ((progress - .82) / .10).clamp(0.0, 1.0).toDouble();
      final blastFade = ((.93 - progress) / .11).clamp(0.0, 1.0).toDouble();
      final radius = 18 + impact * 185;
      final ringPaint = Paint()
        ..color = const Color(0xFFFFD978).withOpacity((1 - impact) * .95 * blastFade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7 * (1 - impact) + .8;
      canvas.drawCircle(target, radius, ringPaint);
      final shockwave = Paint()
        ..color = const Color(0xFFFF7B3B).withOpacity(.20 * blastFade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48);
      canvas.drawCircle(target, 35 + impact * 245, shockwave);
      final flash = Paint()
        ..color = const Color(0xFFFFE5A0).withOpacity((1 - impact) * .9 * blastFade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 42);
      canvas.drawCircle(target, 24 + impact * 70, flash);

      for (var i = 0; i < 32; i++) {
        final angle = math.pi * 2 * i / 32;
        final inner = 9 + impact * 9;
        final outer = 24 + impact * (i.isEven ? 145 : 95);
        final a = target + Offset(math.cos(angle) * inner, math.sin(angle) * inner);
        final b = target + Offset(math.cos(angle) * outer, math.sin(angle) * outer);
        final ray = Paint()
          ..color = (i % 3 == 0 ? const Color(0xFFFFFFFF) : const Color(0xFFFFA34E)).withOpacity((1 - impact) * blastFade)
          ..strokeWidth = (i.isEven ? 4 : 2.5) * (1 - impact) + .5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(a, b, ray);
        if (impact < .88 && blastFade > 0) {
          final dot = Offset(
            target.dx + math.cos(angle) * (outer + 8),
            target.dy + math.sin(angle) * (outer + 8),
          );
          canvas.drawCircle(dot, 2.4 * (1 - impact) + .4, ray);
        }
      }
      _drawSpark(canvas, target, 12 + impact * 8,
          const Color(0xFFFFF4C2).withOpacity((1 - impact * .5) * blastFade));
    }

    if (progress >= .92) {
      final holeProgress = ((progress - .92) / .08).clamp(0.0, 1.0).toDouble();
      final holeRadius = 57 * Curves.easeOutCubic.transform(holeProgress);
      final outerGlow = Paint()
        ..color = const Color(0xFFFF9D52).withOpacity(.82)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13);
      canvas.drawCircle(target, holeRadius + 3, outerGlow);
      canvas.drawCircle(
        target,
        holeRadius,
        Paint()
          ..shader = ui.Gradient.radial(
            target,
            holeRadius < 1 ? 1.0 : holeRadius,
            const [Color(0xFF090512), Color(0xFF000000)],
          ),
      );
      final accretionRing = Paint()
        ..color = const Color(0xFFFFC06C).withOpacity(.95 * holeProgress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawCircle(target, holeRadius, accretionRing);
    }
  }

  void _drawSpark(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx + radius * .15, center.dy - radius * .15, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx + radius * .15, center.dy + radius * .15, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx - radius * .15, center.dy + radius * .15, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx - radius * .15, center.dy - radius * .15, center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ShootingStarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CreatingProfileScreen extends StatefulWidget {
  final BirthProfile profile;
  final bool openMatch;
  const _CreatingProfileScreen({required this.profile, required this.openMatch});
  @override
  State<_CreatingProfileScreen> createState() => _CreatingProfileScreenState();
}

class _CreatingProfileScreenState extends State<_CreatingProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AstroShell(
        profile: widget.profile,
        initialTab: widget.openMatch ? 3 : 4,
      )));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CosmicBackground(child: SafeArea(child: Column(children: [
      const Spacer(),
      Container(width: 250, height: 250, decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(colors: [Color(0xFFFFD64A), Color(0xFFF18A16), Color(0xFFBD321E)]),
        boxShadow: [BoxShadow(color: const Color(0xFFFFA42A).withOpacity(.35), blurRadius: 70, spreadRadius: 10)],
      ), child: const Center(child: Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFE9A6), size: 74))),
      const Spacer(),
      Text('${widget.profile.nickname.isEmpty ? widget.profile.name : widget.profile.nickname}, let’s explore your unique personality',
        textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, height: 1.18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 34),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: ClipRRect(borderRadius: BorderRadius.circular(18), child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1), duration: const Duration(milliseconds: 1800),
        builder: (context, value, _) => LinearProgressIndicator(value: value, minHeight: 54, backgroundColor: Colors.white.withOpacity(.13), color: const Color(0xFF514CD9)),
      ))),
      const SizedBox(height: 18),
      const Text('Creating your profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const Spacer(),
    ]))),
  );
}

class _AstroHero extends StatefulWidget {
  final int step;
  final BirthProfile profile;
  final bool blackHole;
  final bool hideHeadline;
  final bool sunEmerging;
  const _AstroHero({
    required this.step,
    required this.profile,
    required this.blackHole,
    required this.hideHeadline,
    required this.sunEmerging,
  });

  @override
  State<_AstroHero> createState() => _AstroHeroState();
}

class _AstroHeroState extends State<_AstroHero> with SingleTickerProviderStateMixin {
  late final AnimationController orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    orbit.dispose();
    super.dispose();
  }

  Widget _orbitingIdentity(String glyph, String label, double phase,
      {required bool inFront}) =>
      AnimatedBuilder(
        animation: orbit,
        builder: (context, _) {
          final angle = orbit.value * math.pi * 2 + phase;
          final depth = math.sin(angle);
          final visible = inFront ? depth >= 0 : depth < 0;
          final x = math.cos(angle) * 86;
          final y = depth * 29;
          final scale = .76 + ((depth + 1) / 2) * .24;
          return Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(x, y),
              child: Opacity(
                opacity: visible ? (inFront ? 1 : .72) : 0,
                child: Transform.scale(
                  scale: scale,
                  child: _SignTag(glyph: glyph, label: label),
                ),
              ),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final profile = widget.profile;
    final sign = profile.sunSign;
    final partnerLabel = profile.nickname.isEmpty
        ? 'Partner'
        : "${profile.nickname}'s partner";
    final details = switch (step) {
      1 => ('I was born on', 'Date determines your zodiac sign and compatibility'),
      2 => ('I was born at', 'Time of birth is important to determine your Rising Sign (Ascendant, AC)'),
      3 => ('My birth location is', 'Place of birth determines angles and houses in your Birth Chart'),
      4 => ('My Name is', ''),
      5 => ('My nickname is', ''),
      6 => (profile.nickname.isEmpty ? 'Your current relationship status is' : '${profile.nickname}, your current relationship status is', ''),
      _ => ('$partnerLabel zodiac sign', 'Zodiac sign unlocks compatibility insights'),
    };
    return Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
        height: step <= 2 ? 164 : 205,
        child: Stack(alignment: Alignment.center, children: [
          RotationTransition(
            turns: orbit,
            child: OrbitMark(size: step <= 2 ? 190 : 148),
          ),
          if (step == 3) ...[
            _orbitingIdentity(_zodiacGlyph(sign), sign, 0, inFront: false),
            _orbitingIdentity(
              profile.gender == 'Эмэгтэй' ? '♀' : profile.gender == 'Эрэгтэй' ? '♂' : '✦',
              'Gender', math.pi, inFront: false,
            ),
          ],
          AnimatedAlign(
            duration: const Duration(milliseconds: 760),
            curve: Curves.easeInOutCubic,
            alignment: step == 2 ? const Alignment(-.43, 0) : Alignment.center,
            child: widget.sunEmerging
                ? const _BlackHoleToSun()
                : widget.blackHole
                    ? const _BlackHole()
                    : AnimatedContainer(
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeInOutCubic,
              width: step <= 2 ? 148 : 112,
              height: step <= 2 ? 148 : 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  step == 2 ? const Color(0xFFFFC44F) : const Color(0xFFFF6B24),
                  step == 2 ? const Color(0xFFE89A23) : const Color(0xFFD92E16),
                ]),
                boxShadow: [BoxShadow(color: const Color(0xFFFF762F).withOpacity(.24), blurRadius: 38, spreadRadius: 12)],
              ),
              child: Center(child: Text('☀', style: TextStyle(color: Colors.white.withOpacity(.22), fontSize: step <= 2 ? 48 : 36))),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 760),
            curve: Curves.easeInOutCubic,
            alignment: step == 2 ? const Alignment(.43, 0) : Alignment.center,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 760),
              curve: Curves.easeOutBack,
              scale: step == 2 ? 1 : .35,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 420),
                opacity: step == 2 ? 1 : 0,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [Color(0xFFF4EDCF), Color(0xFFAAA8B8), Color(0xFF69677F)]),
                    boxShadow: [BoxShadow(color: const Color(0xFFD9D6FF).withOpacity(.35), blurRadius: 28, spreadRadius: 3)],
                  ),
                  child: const Center(child: Text('☾', style: TextStyle(fontSize: 44, color: Color(0xFF77758C)))),
                ),
              ),
            ),
          ),
          if (step == 3) ...[
            _orbitingIdentity(_zodiacGlyph(sign), sign, 0, inFront: true),
            _orbitingIdentity(
              profile.gender == 'Эмэгтэй' ? '♀' : profile.gender == 'Эрэгтэй' ? '♂' : '✦',
              'Gender', math.pi, inFront: true,
            ),
          ],
        ]),
      ),
      if (step == 6)
        Text('${_zodiacGlyph(sign)}   $sign', style: const TextStyle(fontSize: 22, color: Colors.white70, fontWeight: FontWeight.w600)),
      const SizedBox(height: 20),
      AnimatedOpacity(
        duration: widget.hideHeadline
            ? Duration.zero
            : const Duration(milliseconds: 260),
        opacity: widget.hideHeadline ? 0 : 1,
        child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, .12), end: Offset.zero).animate(animation), child: child)),
        child: Text(details.$1, key: ValueKey('headline-$step'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 36, height: 1.15, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
      ),
      if (details.$2.isNotEmpty) ...[
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 340),
          child: Text(details.$2, key: ValueKey('subtitle-$step'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.35, color: Color(0xFFD6CDE4), fontWeight: FontWeight.w500)),
        ),
      ],
    ]);
  }
}

class _SignTag extends StatelessWidget {
  final String glyph, label;
  const _SignTag({required this.glyph, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    AnimatedSwitcher(duration: const Duration(milliseconds: 360), child: Text(glyph, key: ValueKey(glyph), style: const TextStyle(fontSize: 48, color: Colors.white))),
    AnimatedSwitcher(duration: const Duration(milliseconds: 360), child: Text(label, key: ValueKey(label), style: const TextStyle(fontSize: 13, color: Color(0xFFD4C8E1), fontWeight: FontWeight.w600))),
  ]);
}

String _zodiacGlyph(String sign) => const {
  'Aries':'♈','Taurus':'♉','Gemini':'♊','Cancer':'♋','Leo':'♌','Virgo':'♍',
  'Libra':'♎','Scorpio':'♏','Sagittarius':'♐','Capricorn':'♑','Aquarius':'♒','Pisces':'♓'
}[sign] ?? '✦';

class _StepHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StepHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 29, fontWeight: FontWeight.w800, height: 1.15)),
          if (subtitle.isNotEmpty) const SizedBox(height: 9),
          if (subtitle.isNotEmpty) Text(subtitle, textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFD6CDE4), fontSize: 14, height: 1.4)),
          const SizedBox(height: 16),
        ],
      );
}

class _GenderStep extends StatelessWidget {
  final String value;
  final bool flying;
  final ValueChanged<String> onChanged;
  const _GenderStep({required this.value, required this.flying, required this.onChanged});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const Spacer(flex: 7),
              const Text('I am', style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800, height: 1)),
              const SizedBox(height: 16),
              const Text('Select your gender identity', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFFDCD5F2), fontWeight: FontWeight.w600)),
              const SizedBox(height: 42),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GenderOption(label: 'Female', symbol: '♀', selected: value == 'Эмэгтэй', flying: flying && value == 'Эмэгтэй', onTap: () => onChanged('Эмэгтэй')),
                  const SizedBox(width: 24),
                  _GenderOption(label: 'Male', symbol: '♂', selected: value == 'Эрэгтэй', flying: flying && value == 'Эрэгтэй', onTap: () => onChanged('Эрэгтэй')),
                ],
              ),
              const SizedBox(height: 18),
              TextButton(onPressed: () => onChanged('Бусад'), child: const Text('Other / prefer not to say', style: TextStyle(color: Color(0xFFC9BDE8), fontSize: 12))),
              const Spacer(flex: 2),
            ],
          ),
        ),
      );
}

class _GenderOption extends StatelessWidget {
  final String label;
  final String symbol;
  final bool selected;
  final bool flying;
  final VoidCallback onTap;
  const _GenderOption({required this.label, required this.symbol, required this.selected, required this.flying, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedOpacity(opacity: flying ? .15 : 1, duration: const Duration(milliseconds: 240), child: Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: selected ? const Color(0x886B48A0) : const Color(0x664F338B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? const Color(0xFFE9D7FF) : Colors.white.withOpacity(.12), width: selected ? 1.5 : 1),
            ),
            child: Center(child: Text(symbol, style: const TextStyle(fontSize: 62, color: Colors.white, fontWeight: FontWeight.w300, height: 1))),
          ),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ])),
      );
}

class _GenderFlyToSun extends StatelessWidget {
  final String gender;
  const _GenderFlyToSun({required this.gender});

  @override
  Widget build(BuildContext context) {
    final start = Alignment(
      gender == 'Эмэгтэй' ? -.38 : gender == 'Эрэгтэй' ? .38 : 0,
      gender == 'Бусад' ? .62 : .42,
    );
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 660),
          curve: Curves.easeInOutCubic,
          builder: (context, value, _) {
            final alignment = Alignment.lerp(start, const Alignment(0, -.83), value)!;
            final size = 48 - (24 * value);
            return Align(
              alignment: alignment,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF8B48),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFA03D).withOpacity(.9 * (1 - value * .35)),
                      blurRadius: 16 + 28 * value,
                      spreadRadius: 2 + 7 * value,
                    ),
                  ],
                ),
                child: Center(child: Text(gender == 'Эмэгтэй' ? '♀' : gender == 'Эрэгтэй' ? '♂' : '✦',
                    style: const TextStyle(color: Colors.white, fontSize: 23, height: 1))),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DateWheel extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const _DateWheel({required this.date, required this.onChanged});
  @override
  State<_DateWheel> createState() => _DateWheelState();
}

class _DateWheelState extends State<_DateWheel> {
  late int day = widget.date.day;
  late int month = widget.date.month;
  late int year = widget.date.year;
  static const monthNames = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  void update({int? d, int? m, int? y}) {
    setState(() {
      day = d ?? day;
      month = m ?? month;
      year = y ?? year;
      final maxDay = DateTime(year, month + 1, 0).day;
      if (day > maxDay) day = maxDay;
    });
    widget.onChanged(DateTime(year, month, day));
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 244,
    child: Stack(alignment: Alignment.center, children: [
      Positioned(left: 0, right: 0, child: Container(height: 48,
        decoration: BoxDecoration(color: Colors.white.withOpacity(.09), borderRadius: BorderRadius.circular(28)))),
      Row(children: [
        Expanded(child: _WheelColumn<int>(value: day, values: List.generate(DateTime(year, month + 1, 0).day, (i) => i + 1), label: (v) => '$v', onSelected: (v) => update(d: v))),
        Expanded(flex: 2, child: _WheelColumn<int>(value: month, values: List.generate(12, (i) => i + 1), label: (v) => monthNames[v - 1], onSelected: (v) => update(m: v))),
        Expanded(flex: 2, child: _WheelColumn<int>(value: year, values: List.generate(DateTime.now().year - 1919, (i) => DateTime.now().year - i), label: (v) => '$v', onSelected: (v) => update(y: v))),
      ]),
    ]),
  );
}

class _WheelColumn<T> extends StatefulWidget {
  final T value;
  final List<T> values;
  final String Function(T) label;
  final ValueChanged<T> onSelected;
  const _WheelColumn({required this.value, required this.values, required this.label, required this.onSelected});
  @override
  State<_WheelColumn<T>> createState() => _WheelColumnState<T>();
}

class _WheelColumnState<T> extends State<_WheelColumn<T>> {
  late FixedExtentScrollController controller;
  @override
  void initState() {
    super.initState();
    controller = FixedExtentScrollController(initialItem: _index);
  }
  int get _index => widget.values.indexOf(widget.value).clamp(0, widget.values.length - 1);
  @override
  void didUpdateWidget(covariant _WheelColumn<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.values.length != widget.values.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && controller.hasClients && controller.selectedItem != _index) {
          controller.jumpToItem(_index);
        }
      });
    }
  }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      itemExtent: 48,
      perspective: .002,
      diameterRatio: 2.2,
      physics: const FixedExtentScrollPhysics(),
      controller: controller,
      onSelectedItemChanged: (index) => widget.onSelected(widget.values[index]),
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: widget.values.length,
        builder: (context, index) => Center(child: Text(widget.label(widget.values[index]),
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: widget.values[index] == widget.value ? 27 : 21,
              fontWeight: widget.values[index] == widget.value ? FontWeight.w600 : FontWeight.w400,
              color: widget.values[index] == widget.value ? Colors.white : const Color(0xFF8E789F)))),
      ),
    );
  }
}

class _TimeWheels extends StatefulWidget {
  final TimeOfDay time;
  final bool selected;
  final ValueChanged<TimeOfDay> onChanged;
  const _TimeWheels({required this.time, required this.selected, required this.onChanged});
  @override
  State<_TimeWheels> createState() => _TimeWheelsState();
}

class _TimeWheelsState extends State<_TimeWheels> {
  late int hour = widget.time.hour;
  late int minute = widget.time.minute;
  @override
  Widget build(BuildContext context) => SizedBox(height: 244, child: Stack(alignment: Alignment.center, children: [
    Positioned(left: 22, right: 22, child: Container(height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(.09), borderRadius: BorderRadius.circular(28)))),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(width: 130, child: _WheelColumn<int>(value: hour, values: List.generate(24, (i) => i), label: (v) => v.toString().padLeft(2, '0'), onSelected: (v) { setState(() => hour = v); widget.onChanged(TimeOfDay(hour: hour, minute: minute)); })),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text(':', style: TextStyle(fontSize: 28, color: Colors.white70))),
      SizedBox(width: 130, child: _WheelColumn<int>(value: minute, values: List.generate(60, (i) => i), label: (v) => v.toString().padLeft(2, '0'), onSelected: (v) { setState(() => minute = v); widget.onChanged(TimeOfDay(hour: hour, minute: minute)); })),
    ]),
  ]));
}

class _RelationshipOption extends StatelessWidget {
  final String label, icon, value, selected;
  final ValueChanged<String> onTap;
  const _RelationshipOption({required this.label, required this.icon, required this.value, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(
    borderRadius: BorderRadius.circular(20), onTap: () => onTap(value),
    child: Column(children: [
      AnimatedContainer(duration: const Duration(milliseconds: 160), width: 100, height: 100,
        decoration: BoxDecoration(color: selected == value ? const Color(0xFF563C86) : const Color(0xFF34235E), borderRadius: BorderRadius.circular(19), border: Border.all(color: selected == value ? const Color(0xFFFFA06A) : Colors.white.withOpacity(.05))),
        child: Center(child: AnimatedScale(
          scale: selected == value ? 1.16 : 1,
          duration: const Duration(milliseconds: 420),
          curve: Curves.elasticOut,
          child: Text(icon, style: const TextStyle(fontSize: 43)),
        )),
      ),
      const SizedBox(height: 10),
      Text(label, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
    ]),
  ));
}

class _BirthDateStep extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const _BirthDateStep(
      {required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _DateWheel(date: date, onChanged: onChanged),
      ]);
}

class _BirthTimeStep extends StatelessWidget {
  final TimeOfDay time;
  final bool unknown;
  final bool selected;
  final ValueChanged<TimeOfDay> onChanged;
  final ValueChanged<bool> onUnknownChanged;
  const _BirthTimeStep(
      {required this.time,
      required this.unknown,
      required this.selected,
      required this.onChanged,
      required this.onUnknownChanged});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _TimeWheels(time: time, selected: selected, onChanged: onChanged),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: unknown
                      ? lilac.withOpacity(.5)
                      : Colors.white.withOpacity(.06))),
          child: CheckboxListTile(
            value: unknown,
            onChanged: (value) => onUnknownChanged(value ?? false),
            activeColor: lilac,
            checkColor: ink,
            title: const Text("I'm not sure",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Төрсөн цагаа мэдэхгүй байна',
                style: TextStyle(color: muted, fontSize: 11)),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
      ]);
}

class _BirthPlaceStep extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSuggestedPlace;
  const _BirthPlaceStep(
      {required this.controller,
      required this.onChanged,
      required this.onSuggestedPlace});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          textCapitalization: TextCapitalization.words,
          decoration: inputDecoration(
              'Жишээ нь: Улаанбаатар', Icons.location_on_outlined),
        ),
        const SizedBox(height: 18),
        const Text('САНАЛ БОЛГОХ',
            style: TextStyle(color: muted, fontSize: 9, letterSpacing: 1.4)),
        const SizedBox(height: 9),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Улаанбаатар', 'Эрдэнэт', 'Дархан']
                .map((place) => ActionChip(
                    label: Text(place),
                    onPressed: () => onSuggestedPlace(place),
                    backgroundColor: panel,
                    side: BorderSide(color: Colors.white.withOpacity(.08))))
                .toList()),
      ]);
}

class _TextEntryStep extends StatelessWidget {
  final String title, subtitle, label, hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final IconData icon;
  const _TextEntryStep(
      {required this.title,
      required this.subtitle,
      required this.label,
      required this.hint,
      required this.controller,
      required this.onChanged,
      required this.icon});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FieldLabel(label),
        TextField(
          controller: controller,
          onChanged: onChanged,
          textCapitalization: TextCapitalization.words,
          decoration: inputDecoration(hint, icon),
        ),
      ]);
}

class _RelationshipStep extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _RelationshipStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _RelationshipOption(label: 'In a relationship', icon: '🌷', value: 'Харилцаатай', selected: value, onTap: onChanged),
          const SizedBox(width: 12),
          _RelationshipOption(label: 'Engaged', icon: '💍', value: 'Сүй тавьсан', selected: value, onTap: onChanged),
          const SizedBox(width: 12),
          _RelationshipOption(label: 'Married', icon: '🧡', value: 'Гэрлэсэн', selected: value, onTap: onChanged),
        ]),
        const SizedBox(height: 24),
        Row(children: [
          _RelationshipOption(label: 'Looking for love', icon: '💘', value: 'Хайр дурлал хайж байна', selected: value, onTap: onChanged),
          const SizedBox(width: 12),
          _RelationshipOption(label: 'Not looking', icon: '❌', value: 'Хайр дурлал хайхгүй', selected: value, onTap: onChanged),
          const SizedBox(width: 12),
          _RelationshipOption(label: "It's complicated", icon: '💬', value: 'Төвөгтэй', selected: value, onTap: onChanged),
        ]),
      ]);
}

class _PartnerBirthDateStep extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onChanged;
  const _PartnerBirthDateStep({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) => _DateWheel(
      date: date ?? DateTime(2000, 1, 1),
        onChanged: onChanged,
      );
}

class _DateCard extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final String label;
  final VoidCallback onTap;
  const _DateCard(
      {required this.date,
      required this.selected,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) => _TapCard(
        icon: Icons.calendar_month_rounded,
        title: selected
            ? '${date.day} ${_monthName(date.month)} ${date.year}'
            : 'Өдөр, сар, жил сонгох',
        subtitle: label,
        onTap: onTap,
      );
}

String _monthName(int month) => const [
      '1-р сар',
      '2-р сар',
      '3-р сар',
      '4-р сар',
      '5-р сар',
      '6-р сар',
      '7-р сар',
      '8-р сар',
      '9-р сар',
      '10-р сар',
      '11-р сар',
      '12-р сар'
    ][month - 1];

class _TapCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _TapCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: panel,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: Colors.white.withOpacity(.07))),
            child: Row(children: [
              Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: lilac.withOpacity(.13),
                      borderRadius: BorderRadius.circular(13)),
                  child: Icon(icon, color: lilac, size: 20)),
              const SizedBox(width: 13),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(subtitle,
                        style: const TextStyle(
                            color: muted, fontSize: 9, letterSpacing: .7)),
                    const SizedBox(height: 5),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600))
                  ])),
              const Icon(Icons.keyboard_arrow_down_rounded, color: muted),
            ]),
          ),
        ),
      );
}

class _SelectCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SelectCard(
      {required this.title,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? const Color(0xFF29213F) : panel,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: selected
                        ? lilac.withOpacity(.55)
                        : Colors.white.withOpacity(.07))),
            child: Row(children: [
              Icon(icon, color: selected ? lilac : muted, size: 19),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              selected ? Colors.white : const Color(0xFFD5D1E2),
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400))),
              Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? lilac : muted,
                  size: 18),
            ]),
          ),
        ),
      );
}
