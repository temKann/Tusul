import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../widgets/astro_widgets.dart';

class ReadingTab extends StatefulWidget {
  const ReadingTab({super.key});
  @override
  State<ReadingTab> createState() => _ReadingTabState();
}

class _ReadingTabState extends State<ReadingTab> {
  int choice = 0, reading = 0;
  final prompts = ['Өнөөдрийн удирдамж', 'Хайр ба харилцаа', 'Ажил ба зорилго'];
  final insights = [
    'Өнөөдөр нэг алхам ухарч, юунд эрч хүчээ зориулж байгаагаа ажигла. Жижиг, тогтвортой шийдвэр таныг илүү зөв чиглэлд хүргэнэ.',
    'Харилцаанд чин сэтгэлийн яриа ойр дотно байдлыг нэмнэ. Хариулахын өмнө нөгөө хүнийхээ үгийг дуустал сонсоорой.',
    'Тууштай байдал өнөөдөр таны давуу тал. Нэг ажлыг сонгон дуусгах нь олон санаа эхлүүлэхээс илүү үр дүнтэй.',
  ];
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 24), children: [
        const TopLabel(kicker: 'ОДДЫН УДИРДАМЖ', title: 'Хувийн уншлага'),
        const SizedBox(height: 9),
        const Text('Өнөөдөр юунд анхаармаар байна?',
            style: TextStyle(color: muted)),
        const SizedBox(height: 17),
        ...List.generate(
          prompts.length,
          (i) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: ChoiceTile(
                  label: prompts[i],
                  selected: choice == i,
                  onTap: () => setState(() => choice = i))),
        ),
        const SizedBox(height: 12),
        Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: [Color(0xFF2A2144), panel]),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: lilac.withOpacity(.16))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.auto_awesome, color: lilac),
              const SizedBox(height: 16),
              Text(prompts[choice],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 11),
              Text(insights[reading],
                  style: const TextStyle(
                      color: Color(0xFFD2CDDF), height: 1.7, fontSize: 14)),
              const SizedBox(height: 17),
              const Text('Үүнийг өөртөө тусгах асуулт',
                  style: TextStyle(
                      fontSize: 11, color: lilac, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              const Text('Өнөөдөр миний хувьд үнэхээр чухал зүйл юу вэ?',
                  style: TextStyle(color: muted, fontSize: 12))
            ])),
        const SizedBox(height: 15),
        PrimaryButton(
            label: 'Өөр уншлага авах',
            icon: Icons.refresh_rounded,
            onPressed: () =>
                setState(() => reading = (reading + 1) % insights.length)),
        const SizedBox(height: 11),
        const Center(
            child: Text('Тунгаан бодоход зориулсан бэлгэдэлт зурхай',
                style: TextStyle(color: muted, fontSize: 10)))
      ]);
}
