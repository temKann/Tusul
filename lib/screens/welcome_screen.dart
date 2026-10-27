import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../widgets/astro_widgets.dart';
import 'onboarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: CosmicBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                children: [
                  const Spacer(),
                  const OrbitMark(size: 178),
                  const SizedBox(height: 34),
                  const Text('ASTRA',
                      style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 7,
                          color: lilac,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  const Text('Тэнгэрээс өөрийгөө\nтаньж эхэл',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 34,
                          height: 1.18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  const Text(
                      'Төрсөн зураглал, өдөр тутмын зурхай\nтанд зориулсан нэг орон зайд.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: muted, fontSize: 15, height: 1.5)),
                  const Spacer(),
                  PrimaryButton(
                      label: 'Эхлэх',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OnboardingScreen()))),
                  const SizedBox(height: 14),
                  const Text('ОДДЫН ХЭЛЭХИЙГ ӨӨРИЙНХӨӨРӨӨ МЭДЭР',
                      style: TextStyle(
                          color: muted, fontSize: 9, letterSpacing: 1.4)),
                ],
              ),
            ),
          ),
        ),
      );
}
