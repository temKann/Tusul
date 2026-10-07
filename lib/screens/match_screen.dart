import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/birth_profile.dart';
import '../widgets/astro_widgets.dart';

class MatchTab extends StatefulWidget {
  final BirthProfile profile;
  const MatchTab({super.key, required this.profile});
  @override
  State<MatchTab> createState() => _MatchTabState();
}

class _MatchTabState extends State<MatchTab> {
  String other = 'Libra';

  @override
  void initState() {
    super.initState();
    final partnerDate = widget.profile.partnerBirthDate;
    if (partnerDate != null) other = zodiacFor(partnerDate);
  }

  @override
  Widget build(BuildContext context) {
    final score = 64 +
        ((signs.indexOf(widget.profile.sunSign) * 3 +
                signs.indexOf(other) * 7) %
            31);
    return ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        children: [
          const TopLabel(kicker: 'ХОЁР ОДНЫ УУЛЗАЛТ', title: 'Ордны нийцэл'),
          const SizedBox(height: 9),
          const Text('Харилцааны хэмнэлийг зурхайн өнцгөөс тольдоорой.',
              style: TextStyle(color: muted, height: 1.4)),
          const SizedBox(height: 21),
          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: panel, borderRadius: BorderRadius.circular(23)),
              child: Column(children: [
                Row(children: [
                  Expanded(
                      child: SignCircle(
                          glyph:
                              signGlyphs[signs.indexOf(widget.profile.sunSign)],
                          label: widget.profile.sunSign)),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.favorite, color: Color(0xFFFFA8CB))),
                  Expanded(
                      child: SignCircle(
                          glyph: signGlyphs[signs.indexOf(other)],
                          label: other))
                ]),
                const SizedBox(height: 17),
                const Text('Нөгөө хүний орд',
                    style: TextStyle(color: muted, fontSize: 11)),
                const SizedBox(height: 9),
                DropdownButtonFormField<String>(
                    value: other,
                    decoration:
                        inputDecoration('Орд сонгох', Icons.star_outline),
                    dropdownColor: panel,
                    items: signs
                        .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text('${signGlyphs[signs.indexOf(s)]}  $s')))
                        .toList(),
                    onChanged: (v) => setState(() => other = v ?? other))
              ])),
          const SizedBox(height: 16),
          Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                      colors: [Color(0xFF342447), Color(0xFF1B1934)])),
              child: Column(children: [
                const Text('ЗУРХАЙН ТОЛЬ',
                    style: TextStyle(
                        color: lilac, letterSpacing: 1.5, fontSize: 9)),
                const SizedBox(height: 7),
                const Text('Сониуч зан ба ойлголцол',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text(
                    '$other ордтой харилцахад бие биеийнхээ ялгааг таньж мэдэх нь ойртох түлхүүр байж болно. Энэ бэлгэдэлт уншлага нь эцсийн дүгнэлт биш, харин ярилцаж эхлэх нэг санаа юм.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFFD2CDDF), fontSize: 12, height: 1.6))
              ])),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: Colors.white.withOpacity(.06))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                SizedBox(
                    width: 68,
                    height: 68,
                    child: Stack(alignment: Alignment.center, children: [
                      CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 5,
                          backgroundColor: Colors.white.withOpacity(.08),
                          color: const Color(0xFFFFA8CB),
                          strokeCap: StrokeCap.round),
                      Text('$score%',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ])),
                const SizedBox(width: 14),
                const Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Та хоёрын энерги',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(height: 5),
                      Text('Ордны ерөнхий нийцлийн дүр зураг',
                          style: TextStyle(color: muted, fontSize: 10)),
                    ])),
                const Icon(Icons.auto_awesome, color: lilac, size: 17),
              ]),
              const SizedBox(height: 19),
              CompatibilityMeter(
                  label: 'Сэтгэл хөдлөл',
                  value: ((score + 11) % 25 + 70) / 100,
                  color: const Color(0xFFFFA8CB)),
              const SizedBox(height: 12),
              CompatibilityMeter(
                  label: 'Ярилцлага',
                  value: ((score + 7) % 22 + 72) / 100,
                  color: lilac),
              const SizedBox(height: 12),
              CompatibilityMeter(
                  label: 'Итгэлцэл',
                  value: ((score + 2) % 20 + 74) / 100,
                  color: const Color(0xFFFFD27D)),
            ]),
          ),
          const SizedBox(height: 16),
          const Text(
              'Харилцааны нийцлийг зөвхөн нарны ордоор бүрэн тодорхойлох боломжгүй. Энэ бол танилцахад зориулсан хялбаршуулсан тайлбар.',
              style: TextStyle(color: muted, fontSize: 11, height: 1.55))
        ]);
  }
}

class CompatibilityMeter extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const CompatibilityMeter(
      {required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(
            width: 96,
            child: Text(label,
                style: const TextStyle(color: muted, fontSize: 10))),
        Expanded(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    backgroundColor: Colors.white.withOpacity(.08),
                    color: color))),
        const SizedBox(width: 9),
        Text('${(value * 100).round()}%',
            style: const TextStyle(fontSize: 9, color: Colors.white70)),
      ]);
}
