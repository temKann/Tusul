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
    if (!canContinue) return;
    if (step == 6 && !hasPartner) {
      finishOnboarding(openMatch: false);
      return;
    }
    if (step == 7) {
      finishOnboarding(openMatch: true);
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
          onPressed: step == 0
              ? () => Navigator.pop(context)
              : goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const SizedBox.shrink(),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 620),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: step == 1 ? .82 : .96, end: 1).animate(curved),
              alignment: Alignment.topCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(transitionDirection * .055, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
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
                        _AstroHero(step: step, profile: profile),
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
                                    child: child,
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
                      onPressed: canContinue ? continueFlow : null,
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
          SafeArea(child: buildStep()),
          if (genderAnimating) _GenderFlyToSun(gender: profile.gender),
      ],
      );
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
  const _AstroHero({required this.step, required this.profile});

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
          if (step >= 3 && step != 6)
            Positioned(left: 8, child: _SignTag(glyph: _zodiacGlyph(sign), label: sign)),
          AnimatedContainer(
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
            child: Center(child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
              child: Text(step == 2 ? '☾' : '✦', key: ValueKey(step == 2), style: TextStyle(color: Colors.white.withOpacity(.22), fontSize: step <= 2 ? 48 : 36)),
            )),
          ),
          if (step >= 3 && step != 6)
            Positioned(right: 8, child: _SignTag(glyph: '♀', label: 'Venus')),
        ]),
      ),
      if (step == 6)
        Text('${_zodiacGlyph(sign)}   $sign', style: const TextStyle(fontSize: 22, color: Colors.white70, fontWeight: FontWeight.w600)),
      const SizedBox(height: 20),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, .12), end: Offset.zero).animate(animation), child: child)),
        child: Text(details.$1, key: ValueKey('headline-$step'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 36, height: 1.15, fontWeight: FontWeight.w800, color: Colors.white)),
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
