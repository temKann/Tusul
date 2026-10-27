import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../app_colors.dart';
import '../models/birth_profile.dart';
import '../widgets/astro_widgets.dart';

class HomeTab extends StatefulWidget {
  final BirthProfile profile;
  final VoidCallback onChart, onReadings;
  const HomeTab(
      {super.key,
      required this.profile,
      required this.onChart,
      required this.onReadings});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int forecastPeriod = 0;
  final periods = const ['ӨНӨӨДӨР', 'МАРГААШ', '7 ХОНОГ', 'САР', 'ЖИЛ'];

  @override
  Widget build(BuildContext context) {
    final firstName = widget.profile.nickname.isEmpty
        ? widget.profile.name.split(' ').first
        : widget.profile.nickname;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      children: [
        Row(children: [
          const OrbitMark(size: 36),
          const SizedBox(width: 9),
          const Text('ASTRA',
              style: TextStyle(
                  letterSpacing: 3.2,
                  color: lilac,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          RoundIconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
        ]),
        const SizedBox(height: 23),
        Text('Сайн уу, $firstName',
            style: const TextStyle(
                fontSize: 25, fontWeight: FontWeight.w600, letterSpacing: -.4)),
        const SizedBox(height: 5),
        Row(children: [
          const Icon(Icons.location_on_outlined, size: 13, color: lilac),
          const SizedBox(width: 4),
          Text(
              '${widget.profile.birthPlace}  ·  ${_weekday(DateTime.now().weekday)}, ${DateTime.now().month}-р сарын ${DateTime.now().day}',
              style: const TextStyle(color: muted, fontSize: 11)),
        ]),
        const SizedBox(height: 22),
        ForecastPeriodTabs(
            periods: periods,
            selected: forecastPeriod,
            onSelected: (i) => setState(() => forecastPeriod = i)),
        const SizedBox(height: 13),
        HeroCard(sign: widget.profile.sunSign, period: periods[forecastPeriod])
            .animate()
            .fadeIn(duration: 550.ms)
            .slideY(begin: .06, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 23),
        const SectionHeading(title: 'ОДДЫН ӨНӨӨДРИЙН ТӨЛӨВ', trailing: 'БҮГД'),
        const SizedBox(height: 12),
        Row(children: const [
          Expanded(
              child: MetricCard(
                  icon: Icons.bolt_rounded,
                  title: 'Энерги',
                  value: 'Өндөр',
                  color: Color(0xFFFFD27D))),
          SizedBox(width: 9),
          Expanded(
              child: MetricCard(
                  icon: Icons.favorite_rounded,
                  title: 'Хайр',
                  value: 'Нээлттэй',
                  color: Color(0xFFFFA8CB))),
          SizedBox(width: 9),
          Expanded(
              child: MetricCard(
                  icon: Icons.palette_outlined,
                  title: 'Өнгө',
                  value: 'Лаванда',
                  color: lilac)),
        ]).animate().fadeIn(duration: 450.ms).slideY(begin: .08, end: 0),
        const SizedBox(height: 23),
        const SectionHeading(title: 'БИОРИТМ', trailing: 'ЭНЭ 7 ХОНОГ'),
        const SizedBox(height: 10),
        const BiorhythmCard(),
        const SizedBox(height: 25),
        const SectionHeading(
            title: 'Танд зориулсан зурхай', trailing: 'ХУВИЙН'),
        const SizedBox(height: 11),
        HoroscopeFeatureCard(
          icon: Icons.favorite_rounded,
          title: 'Хайр ба харилцаа',
          subtitle: 'Өнөөдөр сэтгэлээ нээхэд тохиромжтой өдөр.',
          accent: const Color(0xFFFFA8CB),
          onTap: widget.onReadings,
        )
            .animate()
            .fadeIn(delay: 80.ms, duration: 400.ms)
            .slideX(begin: .04, end: 0),
        const SizedBox(height: 10),
        HoroscopeFeatureCard(
          icon: Icons.auto_awesome_rounded,
          title: 'Хувийн зурхай',
          subtitle: '${widget.profile.sunSign} ордны өдөр тутмын тайлал.',
          accent: lilac,
          onTap: widget.onReadings,
        )
            .animate()
            .fadeIn(delay: 150.ms, duration: 400.ms)
            .slideX(begin: .04, end: 0),
        const SizedBox(height: 24),
        SectionHeading(
            title: 'Төрсөн зураглал', trailing: 'НЭЭХ', onTap: widget.onChart),
        const SizedBox(height: 11),
        ChartPreview(sign: widget.profile.sunSign, onTap: widget.onChart),
        const SizedBox(height: 24),
        const SectionHeading(title: 'Өдрийн зөн', trailing: 'ASTRA AI'),
        const SizedBox(height: 11),
        InsightCard(sign: widget.profile.sunSign),
        const SizedBox(height: 16),
        ReadingTeaser(onTap: widget.onReadings),
      ],
    );
  }
}

String _weekday(int n) => const [
      '',
      'Даваа',
      'Мягмар',
      'Лхагва',
      'Пүрэв',
      'Баасан',
      'Бямба',
      'Ням'
    ][n];

class HeroCard extends StatelessWidget {
  final String sign, period;
  const HeroCard({required this.sign, required this.period});
  @override
  Widget build(BuildContext context) => Container(
        height: 225,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF34234F),
                Color(0xFF171832),
                Color(0xFF10152B)
              ]),
          border: Border.all(color: lilac.withOpacity(.2)),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF6E4EA3).withOpacity(.16),
                blurRadius: 30,
                offset: const Offset(0, 12))
          ],
        ),
        child: Stack(children: [
          const Positioned.fill(
              child: IgnorePointer(
                  child: CustomPaint(painter: StarFieldPainter()))),
          Positioned(
              right: -8,
              top: 5,
              child: Opacity(opacity: .72, child: OrbitMark(size: 166))),
          Positioned(
              right: 26,
              top: 29,
              child: PlanetDot(size: 9, color: const Color(0xFFFFDCA0))),
          Positioned(
              right: 127, top: 73, child: PlanetDot(size: 5, color: lilac)),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 17, 19, 15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.auto_awesome, size: 13, color: lilac),
                const SizedBox(width: 6),
                Text('${period.toUpperCase()}  ·  ${DateTime.now().year}',
                    style: const TextStyle(
                        letterSpacing: 1.1,
                        color: lilac,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.2),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(.1))),
                    child: const Row(children: [
                      Icon(Icons.wb_sunny_outlined,
                          size: 11, color: Color(0xFFFFDCA0)),
                      SizedBox(width: 4),
                      Text('COSMIC WEATHER',
                          style: TextStyle(
                              fontSize: 7,
                              letterSpacing: .7,
                              color: Colors.white70))
                    ])),
              ]),
              const SizedBox(height: 22),
              Text('${signGlyphs[signs.indexOf(sign)]}  $sign',
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.3)),
              const SizedBox(height: 5),
              const SizedBox(
                  width: 204,
                  child: Text(
                      'Өнөөдөр таны зөн совин шинэ боломжийг анзаарахад тусална.',
                      style: TextStyle(
                          color: Color(0xFFD5D1E2),
                          fontSize: 11,
                          height: 1.45))),
              const Spacer(),
              Row(children: [
                const SkyPlacement(glyph: '☉', label: 'НАР', value: 'Gemini'),
                const SizedBox(width: 6),
                const SkyPlacement(glyph: '☾', label: 'САР', value: 'Pisces'),
                const SizedBox(width: 6),
                SkyPlacement(glyph: '↗', label: 'МАНДАХ', value: sign),
                const Spacer(),
                Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.09),
                        border:
                            Border.all(color: Colors.white.withOpacity(.12))),
                    child: const Icon(Icons.arrow_forward_rounded,
                        size: 15, color: Colors.white)),
              ]),
            ]),
          ),
        ]),
      );
}

class SkyPlacement extends StatelessWidget {
  final String glyph, label, value;
  const SkyPlacement(
      {required this.glyph, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(.19),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(.08))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(glyph, style: const TextStyle(color: lilac, fontSize: 13)),
          const SizedBox(width: 5),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 6, color: muted, letterSpacing: .8)),
            Text(value,
                style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.w600))
          ]),
        ]),
      );
}

class ForecastPeriodTabs extends StatelessWidget {
  final List<String> periods;
  final int selected;
  final ValueChanged<int> onSelected;
  const ForecastPeriodTabs(
      {required this.periods,
      required this.selected,
      required this.onSelected});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: const Color(0xFF15142B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(.055))),
        child: Row(
            children: List.generate(
                periods.length,
                (i) => Expanded(
                        child: GestureDetector(
                      onTap: () => onSelected(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: selected == i
                                ? const Color(0xFF30274A)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: selected == i
                                ? [
                                    BoxShadow(
                                        color: lilac.withOpacity(.08),
                                        blurRadius: 10)
                                  ]
                                : null),
                        alignment: Alignment.center,
                        child: Text(periods[i],
                            style: TextStyle(
                                fontSize: 8,
                                letterSpacing: .7,
                                color: selected == i ? lilac : muted,
                                fontWeight: selected == i
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                      ),
                    )))),
      );
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const RoundIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
      color: const Color(0xFF1C1A34),
      shape: const CircleBorder(),
      child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, size: 19, color: const Color(0xFFDDD8E9)))));
}

class PlanetDot extends StatelessWidget {
  final double size;
  final Color color;
  const PlanetDot({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color.withOpacity(.6), blurRadius: 12)
          ]));
}

class HoroscopeFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color accent;
  final VoidCallback onTap;
  const HoroscopeFeatureCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.accent,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(.065))),
            child: Row(children: [
              Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                      color: accent.withOpacity(.13),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: accent, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: muted, fontSize: 10))
                  ])),
              const SizedBox(width: 8),
              Container(
                  width: 29,
                  height: 29,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.07)),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 18)),
            ]),
          ),
        ),
      );
}

class BiorhythmCard extends StatelessWidget {
  const BiorhythmCard();

  static const days = ['Д', 'М', 'Л', 'П', 'Б', 'Б', 'Н'];

  @override
  Widget build(BuildContext context) => Container(
        height: 190,
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 10),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: Colors.white.withOpacity(.06)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(
                child: Text('Таны эрч хүч',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            BioLegend(color: lilac, label: 'Сэтгэл'),
            const SizedBox(width: 9),
            BioLegend(color: const Color(0xFFFFB6D6), label: 'Энерги'),
          ]),
          const SizedBox(height: 5),
          const Text('Долоо хоногийн хэмнэл',
              style: TextStyle(color: muted, fontSize: 9)),
          const SizedBox(height: 7),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withOpacity(.07), strokeWidth: .6),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 18,
                      getTitlesWidget: (value, meta) {
                        final i = value.round();
                        if (i < 0 || i >= days.length)
                          return const SizedBox.shrink();
                        return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(days[i],
                                style: const TextStyle(
                                    color: muted, fontSize: 8)));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 44),
                      FlSpot(1, 58),
                      FlSpot(2, 52),
                      FlSpot(3, 72),
                      FlSpot(4, 64),
                      FlSpot(5, 81),
                      FlSpot(6, 75)
                    ],
                    isCurved: true,
                    curveSmoothness: .3,
                    color: lilac,
                    barWidth: 2.3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              lilac.withOpacity(.2),
                              lilac.withOpacity(0)
                            ])),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 65),
                      FlSpot(1, 50),
                      FlSpot(2, 62),
                      FlSpot(3, 48),
                      FlSpot(4, 69),
                      FlSpot(5, 58),
                      FlSpot(6, 86)
                    ],
                    isCurved: true,
                    curveSmoothness: .3,
                    color: const Color(0xFFFFB6D6),
                    barWidth: 1.7,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
            ),
          ),
        ]),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: .05, end: 0);
}

class BioLegend extends StatelessWidget {
  final Color color;
  final String label;
  const BioLegend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: muted, fontSize: 8))
      ]);
}

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String title, value;
  final Color color;
  const MetricCard(
      {required this.icon,
      required this.title,
      required this.value,
      required this.color});
  @override
  Widget build(BuildContext context) => Container(
      height: 103,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(.055))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 17),
        const Spacer(),
        Text(title, style: const TextStyle(fontSize: 10, color: muted)),
        const SizedBox(height: 3),
        FittedBox(
            alignment: Alignment.centerLeft,
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)))
      ]));
}

class InsightCard extends StatelessWidget {
  final String sign;
  const InsightCard({required this.sign});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: Colors.white.withOpacity(.06))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
                color: lilac.withOpacity(.13), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, size: 17, color: lilac)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Дотоод мэдрэмжээ сонс',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
              '$sign ордны хувьд өнөөдөр яаралгүй ажиглаж, өөртөө чухал зүйлд орон зай гаргах өдөр.',
              style: const TextStyle(color: muted, height: 1.5, fontSize: 12))
        ]))
      ]));
}
