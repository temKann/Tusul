import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/birth_profile.dart';
import '../widgets/astro_widgets.dart';

class ProfileTab extends StatelessWidget {
  final BirthProfile profile;
  const ProfileTab({super.key, required this.profile});
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 24), children: [
        const TopLabel(kicker: 'ТАНЫ ХУВИЙН ОРОН ЗАЙ', title: 'Профайл'),
        const SizedBox(height: 21),
        Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: panel, borderRadius: BorderRadius.circular(21)),
            child: Row(children: [
              const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF342447),
                  child: Icon(Icons.person_outline, color: lilac, size: 28)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(profile.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(profile.nickname,
                        style: const TextStyle(color: lilac, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                        '${signGlyphs[signs.indexOf(profile.sunSign)]} ${profile.sunSign} · ${profile.birthPlace}',
                        style: const TextStyle(color: muted, fontSize: 12))
                  ]))
            ])),
        const SizedBox(height: 20),
        const FieldLabel('ТӨРСӨН МЭДЭЭЛЭЛ'),
        ProfileRow(
            label: 'Хүйс', value: profile.gender, icon: Icons.person_outline),
        ProfileRow(
            icon: Icons.calendar_month_outlined,
            label: 'Төрсөн өдөр',
            value:
                '${profile.birthDate.year}.${profile.birthDate.month.toString().padLeft(2, '0')}.${profile.birthDate.day.toString().padLeft(2, '0')}'),
        ProfileRow(
            icon: Icons.schedule_outlined,
            label: 'Төрсөн цаг',
            value: profile.birthTimeUnknown
                ? "I'm not sure"
                : profile.birthTime.format(context)),
        ProfileRow(
            icon: Icons.place_outlined,
            label: 'Төрсөн газар',
            value: profile.birthPlace),
        ProfileRow(
            icon: Icons.favorite_border,
            label: 'Харилцааны төлөв',
            value: profile.relationshipStatus),
        if (profile.partnerBirthDate != null)
          ProfileRow(
            icon: Icons.favorite,
            label: 'Хамтрагчийн төрсөн өдөр',
            value:
                '${profile.partnerBirthDate!.year}.${profile.partnerBirthDate!.month.toString().padLeft(2, '0')}.${profile.partnerBirthDate!.day.toString().padLeft(2, '0')}',
          ),
        const SizedBox(height: 18),
        const FieldLabel('ТУХАЙ'),
        const ProfileRow(
            icon: Icons.info_outline,
            label: 'ASTRA',
            value: 'Таны дотоод оддын газрын зураг'),
        const SizedBox(height: 18),
        const Text(
            'MVP загвар · Зарим тайлбар жишээ агуулга бөгөөд бодит AI эсвэл эфемерисийн тооцоо хийгдээгүй.',
            style: TextStyle(color: muted, fontSize: 11, height: 1.55))
      ]);
}

class ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const ProfileRow(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 11),
      child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: panel, borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
            Icon(icon, color: lilac, size: 17),
            const SizedBox(width: 11),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
            Text(value, style: const TextStyle(color: muted, fontSize: 11))
          ])));
}
