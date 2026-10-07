import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/birth_profile.dart';
import '../widgets/astro_widgets.dart';
import 'chart_screen.dart';
import 'home_screen.dart';
import 'match_screen.dart';
import 'profile_screen.dart';
import 'reading_screen.dart';

class AstroShell extends StatefulWidget {
  final BirthProfile profile;
  final int initialTab;
  const AstroShell({super.key, required this.profile, this.initialTab = 0});
  @override
  State<AstroShell> createState() => _AstroShellState();
}

class _AstroShellState extends State<AstroShell> {
  int tab = 0;

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab;
  }

  void go(int value) => setState(() => tab = value);
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(
          profile: widget.profile,
          onChart: () => go(1),
          onReadings: () => go(2)),
      ChartTab(profile: widget.profile),
      const ReadingTab(),
      MatchTab(profile: widget.profile),
      ProfileTab(profile: widget.profile),
    ];
    return Scaffold(
      body: CosmicBackground(
          child: SafeArea(child: IndexedStack(index: tab, children: pages))),
      bottomNavigationBar: _CosmicNavigationBar(index: tab, onSelect: go),
    );
  }
}

class _CosmicNavigationBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const _CosmicNavigationBar({required this.index, required this.onSelect});

  static const items = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home_rounded, 'Нүүр'),
    (Icons.brightness_3_outlined, Icons.brightness_3, 'Зураглал'),
    (Icons.auto_awesome_outlined, Icons.auto_awesome, 'Уншлага'),
    (Icons.favorite_border, Icons.favorite, 'Нийцэл'),
    (Icons.person_outline, Icons.person, 'Профайл'),
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF121126).withOpacity(.97),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: lilac.withOpacity(.13)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = index == i;
              final item = items[i];
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: item.$3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? lilac.withOpacity(.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(selected ? item.$2 : item.$1,
                            size: 20, color: selected ? lilac : muted),
                        const SizedBox(height: 4),
                        Text(item.$3,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected ? lilac : muted)),
                      ]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
}
