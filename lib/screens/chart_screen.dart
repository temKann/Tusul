import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/birth_profile.dart';
import '../widgets/astro_widgets.dart';

class ChartTab extends StatelessWidget {
  final BirthProfile profile;
  const ChartTab({super.key, required this.profile});
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 24), children: [
        const TopLabel(kicker: 'ТАНЫ ОДОД', title: 'Төрсөн зураглал'),
        const SizedBox(height: 14),
        const Text('Төрсөн агшны тэнгэрийн бэлгэдэлт зураглал.',
            style: TextStyle(color: muted, fontSize: 13)),
        const SizedBox(height: 23),
        Container(
            height: 315,
            decoration: BoxDecoration(
                color: panel, borderRadius: BorderRadius.circular(24)),
            child: Stack(alignment: Alignment.center, children: [
              const CustomPaint(
                  size: Size(280, 280), painter: ZodiacWheelPainter()),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text(signGlyphs[signs.indexOf(profile.sunSign)],
                    style: const TextStyle(fontSize: 37, color: lilac)),
                const SizedBox(height: 6),
                Text(profile.sunSign,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Text('Нарны орд',
                    style: TextStyle(fontSize: 11, color: muted))
              ])
            ])),
        const SizedBox(height: 19),
        const Text('ГОЛ ГУРВАЛ',
            style: TextStyle(color: muted, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        PlacementTile(
            glyph: '☉',
            name: 'Нар',
            sign: profile.sunSign,
            meaning: 'Таны мөн чанар ба амьдралын эрч хүч'),
        const SizedBox(height: 9),
        PlacementTile(
            glyph: '☾',
            name: 'Сар',
            sign: 'Төрсөн цаг шаардлагатай',
            meaning: 'Сэтгэл хөдлөл, дотоод хэрэгцээ'),
        const SizedBox(height: 9),
        PlacementTile(
            glyph: '↗',
            name: 'Мандах орд',
            sign: 'Байршил шаардлагатай',
            meaning: 'Бусдад харагдах таны өнгө төрх'),
        const SizedBox(height: 16),
        const Text(
            'Нарны ордыг төрсөн өдрөөр тодорхойлов. Сар болон мандах ордын байрлалыг бодит одон орны тооцоогоор дараагийн хувилбарт нэмнэ.',
            style: TextStyle(color: muted, fontSize: 11, height: 1.5))
      ]);
}
