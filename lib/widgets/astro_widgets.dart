import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/birth_profile.dart';

class PlacementTile extends StatelessWidget {
  final String glyph, name, sign, meaning;
  const PlacementTile(
      {required this.glyph,
      required this.name,
      required this.sign,
      required this.meaning});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(14),
      decoration:
          BoxDecoration(color: panel, borderRadius: BorderRadius.circular(15)),
      child: Row(children: [
        Text(glyph, style: const TextStyle(fontSize: 22, color: lilac)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(meaning, style: const TextStyle(fontSize: 10, color: muted))
        ])),
        Text(sign,
            style: TextStyle(
                color: sign.contains('шаардлагатай') ? muted : lilac,
                fontSize: 11))
      ]));
}

class ChartPreview extends StatelessWidget {
  final String sign;
  final VoidCallback onTap;
  const ChartPreview({required this.sign, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: panel, borderRadius: BorderRadius.circular(19)),
          child: Row(children: [
            const SizedBox(
                width: 78,
                height: 78,
                child: CustomPaint(painter: ZodiacWheelPainter())),
            const SizedBox(width: 13),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Төрсөн зураглал',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 5),
                  Text('$sign · Нарны орд',
                      style: const TextStyle(color: muted, fontSize: 11)),
                  const SizedBox(height: 8),
                  const Text('Бусад байрлалыг нээх  →',
                      style: TextStyle(color: lilac, fontSize: 10))
                ]))
          ])));
}

class ReadingTeaser extends StatelessWidget {
  final VoidCallback onTap;
  const ReadingTeaser({required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: panel, borderRadius: BorderRadius.circular(19)),
          child: Row(children: [
            const Icon(Icons.auto_awesome, color: lilac),
            const SizedBox(width: 12),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Асуултаа оддод тавь',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Танд зориулсан зөнг уншаарай',
                      style: TextStyle(color: muted, fontSize: 11))
                ])),
            const Icon(Icons.arrow_forward_ios, size: 13, color: muted)
          ])));
}

class ChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const ChoiceTile(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: selected ? const Color(0xFF282141) : panel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: selected
                      ? lilac.withOpacity(.5)
                      : Colors.white.withOpacity(.06))),
          child: Row(children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 17, color: selected ? lilac : muted),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 13))
          ])));
}

class SignCircle extends StatelessWidget {
  final String glyph, label;
  const SignCircle({required this.glyph, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF302545),
                border: Border.all(color: lilac.withOpacity(.3))),
            alignment: Alignment.center,
            child: Text(glyph,
                style: const TextStyle(color: lilac, fontSize: 32))),
        const SizedBox(height: 7),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))
      ]);
}

class SectionHeading extends StatelessWidget {
  final String title, trailing;
  final VoidCallback? onTap;
  const SectionHeading(
      {super.key, required this.title, required this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600))),
        GestureDetector(
            onTap: onTap,
            child: Text(trailing,
                style: const TextStyle(
                    color: lilac, fontSize: 9, letterSpacing: .5)))
      ]);
}

class TopLabel extends StatelessWidget {
  final String kicker, title;
  const TopLabel({required this.kicker, required this.title});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(kicker,
            style: const TextStyle(
                color: lilac,
                letterSpacing: 1.7,
                fontSize: 9,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        Text(title,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w600))
      ]);
}

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: muted,
              fontSize: 9,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600)));
}

class PickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const PickerTile(
      {required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withOpacity(.07))),
          child: Row(children: [
            Icon(icon, size: 18, color: lilac),
            const SizedBox(width: 11),
            Text(title, style: const TextStyle(fontSize: 13)),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: muted)
          ])));
}

InputDecoration inputDecoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: muted, fontSize: 13),
    prefixIcon: Icon(icon, size: 18, color: lilac),
    filled: true,
    fillColor: panel,
    contentPadding: const EdgeInsets.symmetric(vertical: 15),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: Colors.white.withOpacity(.07))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: lilac)));

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const PrimaryButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 54,
      child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
              backgroundColor: lilac,
              foregroundColor: ink,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Icon(icon, size: 17)
          ])));
}

class CosmicBackground extends StatelessWidget {
  final Widget child;
  final int atmosphere;
  const CosmicBackground({super.key, required this.child, this.atmosphere = 0});
  @override
  Widget build(BuildContext context) {
    final palette = switch (atmosphere % 7) {
      1 => const [Color(0xFF35124A), Color(0xFF260B37), Color(0xFF14071E)],
      2 => const [Color(0xFF35143F), Color(0xFF230A34), Color(0xFF13071D)],
      3 => const [Color(0xFF321045), Color(0xFF210A32), Color(0xFF12071C)],
      4 => const [Color(0xFF301044), Color(0xFF200A35), Color(0xFF12071D)],
      5 => const [Color(0xFF351441), Color(0xFF230A37), Color(0xFF13071E)],
      6 => const [Color(0xFF321247), Color(0xFF210A34), Color(0xFF12071D)],
      _ => const [Color(0xFF111027), ink, ink],
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: palette)),
      child: Stack(children: [
        const Positioned(top: 80, right: -90, child: _Glow(size: 220)),
        Positioned.fill(
            child:
                IgnorePointer(child: CustomPaint(painter: StarFieldPainter()))),
        child
      ]));
  }
}

class _Glow extends StatelessWidget {
  final double size;
  const _Glow({required this.size});
  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [lilac.withOpacity(.08), Colors.transparent])));
}

class OrbitMark extends StatelessWidget {
  final double size;
  const OrbitMark({super.key, required this.size});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: OrbitMarkPainter()));
}

class OrbitMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2), r = size.width * .37;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = lilac.withOpacity(.58);
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c, r * .72, p..color = Colors.white.withOpacity(.18));
    canvas.drawOval(
        Rect.fromCenter(center: c, width: r * 2.35, height: r * .83),
        p..color = lilac.withOpacity(.38));
    canvas.drawCircle(c, r * .15, Paint()..color = const Color(0xFFFFE5B4));
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2 + .35;
      final pt = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      canvas.drawCircle(pt, size.width * .018, Paint()..color = lilac);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarFieldPainter extends CustomPainter {
  const StarFieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < 75; i++) {
      final x = ((i * 67 + 21) % 997) / 997 * size.width;
      final y = ((i * 131 + 39) % 991) / 991 * size.height;
      paint.color = Colors.white.withOpacity(.12 + (i % 4) * .045);
      canvas.drawCircle(Offset(x, y), i % 9 == 0 ? 1.1 : .55, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ZodiacWheelPainter extends CustomPainter {
  const ZodiacWheelPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2),
        r = math.min(size.width, size.height) * .46;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = lilac.withOpacity(.42);
    canvas.drawCircle(c, r, ring);
    canvas.drawCircle(c, r * .72, ring..color = Colors.white.withOpacity(.17));
    canvas.drawCircle(c, r * .34, ring..color = Colors.white.withOpacity(.12));
    final line = Paint()
      ..color = Colors.white.withOpacity(.16)
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 12; i++) {
      final a = -math.pi / 2 + i * math.pi / 6;
      canvas.drawLine(
          Offset(c.dx + math.cos(a) * r * .72, c.dy + math.sin(a) * r * .72),
          Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r),
          line);
      final pos = Offset(c.dx + math.cos(a + math.pi / 12) * r * .84,
          c.dy + math.sin(a + math.pi / 12) * r * .84);
      textPainter.text = TextSpan(
          text: signGlyphs[i],
          style: TextStyle(
              fontSize: size.width * .055,
              color: i == 0 ? lilac : const Color(0xFFD1C5E5)));
      textPainter.layout();
      textPainter.paint(
          canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
    }
    final center = Paint()
      ..color = lilac.withOpacity(.65)
      ..strokeWidth = 1.2;
    for (int i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * math.pi * .4;
      final b = -math.pi / 2 + ((i + 2) % 5) * math.pi * .4;
      canvas.drawLine(
          Offset(c.dx + math.cos(a) * r * .3, c.dy + math.sin(a) * r * .3),
          Offset(c.dx + math.cos(b) * r * .3, c.dy + math.sin(b) * r * .3),
          center);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
